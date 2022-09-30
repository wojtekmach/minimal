defmodule Foo.MixProject do
  use Mix.Project

  def project do
    [
      app: :foo,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Foo.Application, []}
    ]
  end

  defp deps do
    []
  end

  defp releases do
    [
      foo: [
        # include_erts: false,
        targets: [
          "macos-aarch64",
          "macos-x86_64",
          # "ios-aarch64",
          "iossimulator-aarch64",
          "iossimulator-x86_64"
        ],
        bootstrap: [
          # openssl_version: "3.0.5",
          otp_version: "25.1.1"
        ],
        steps: [
          :assemble,
          &bootstrap/1,
          &build_launcher/1
        ]
      ]
    ]
  end

  defp build_launcher(release) do
    Enum.reduce(release.options[:targets], release, &build_launcher/2)
  end

  defp build_launcher(target, release) do
    app_path = Path.join(Mix.Project.build_path(), "app-#{target}")
    File.mkdir_p!(Path.join(app_path, "bin"))

    tmp_dir = Path.join(release.path, "tmp")
    File.mkdir_p!(tmp_dir)
    launcher_cpp_path = Path.join(tmp_dir, "launcher.m")
    launcher_bin_path = Path.join([app_path, "bin", "app"])

    File.write!(launcher_cpp_path, launcher(release))
    File.cp_r!(release.path, Path.join(app_path, "rel"))

    sdk =
      case target do
        "macos-" <> _ -> "macosx"
        "iossimulator" <> _ -> "iphonesimulator"
        "ios" <> _ -> "iphoneos"
      end

    flags =
      case target do
        "macos-aarch64" ->
          "--target=arm64-apple-darwin -lc++"

        "macos-x86_64" ->
          "--target=x86_64-apple-darwin -lc++"

        "ios-aarch64" ->
          "--target=arm64-apple-ios14.0 -mios-version-min=14.0"

        "iossimulator-aarch64" ->
          "--target=arm64-apple-ios14.0-simulator -mios-simulator-version-min=14.0"

        "iossimulator-x86_64" ->
          "--target=x86_64-apple-ios14.0-simulator -mios-simulator-version-min=14.0"
      end

    otp_target =
      case target do
        "macos-aarch64" -> "aarch64-apple-darwin"
        "macos-x86_64" -> "x86_64-apple-darwin"
        "ios-aarch64" -> "aarch64-apple-ios"
        "iossimulator-aarch64" -> "aarch64-apple-iossimulator"
        "iossimulator-x86_64" -> "x86_64-apple-iossimulator"
      end

    otp_version = release.options[:bootstrap][:otp_version]
    otp_source_dir = Path.expand("_build/tmp/otp-#{otp_version}")

    shell!("""
    clang \
      -isysroot `xcrun -sdk #{sdk} --show-sdk-path` \
      -framework Foundation \
      #{flags} \
      -L#{otp_source_dir}/erts/emulator/ryu/obj/#{otp_target}/opt \
      -L#{otp_source_dir}/erts/emulator/zlib/obj/#{otp_target}/opt \
      -L#{otp_source_dir}/erts/emulator/pcre/obj/#{otp_target}/opt \
      -L#{otp_source_dir}/erts/lib/internal/#{otp_target} \
      -L#{otp_source_dir}/bin/#{otp_target} \
      -lryu -lz -lepcre -lerts_internal -lethread -lbeam \
      -o #{launcher_bin_path} #{launcher_cpp_path}
      # #{flags} \
    """)

    release
  end

  defp bootstrap(release) do
    Enum.reduce(release.options[:targets], release, &bootstrap/2)
  end

  defp bootstrap(target, release) do
    release
    |> build_openssl(target)
    |> build_otp(target)
  end

  defp build_openssl(release, target) do
    if version = release.options[:bootstrap][:openssl_version] do
      build_openssl(release, target, version)
    else
      release
    end
  end

  defp build_openssl(release, target, version) do
    source_dir = Path.expand("_build/tmp/openssl-#{version}")
    target_dir = Path.expand("_build/openssl-#{version}-#{target}")

    openssl_target =
      case target do
        "macos-aarch64" -> "darwin64-arm64-cc"
        "macos-x86_64" -> "darwin64-x86_64-cc"
        "ios-aarch64" -> "ios64-xcrun"
        "iossimulator-aarch64" -> "iossimulator-aarch64-xcrun"
        "iossimulator-x86_64" -> "iossimulator-x86_64-xcrun"
      end

    shell!("scripts/build_openssl.sh #{version} #{source_dir} #{target_dir} #{openssl_target}")
    release
  end

  defp build_otp(release, target) do
    version = release.options[:bootstrap][:otp_version]
    openssl_version = release.options[:bootstrap][:openssl_version]
    source_dir = Path.expand("_build/tmp/otp-#{version}")
    target_dir = otp_target_dir(release, target)
    openssl_dir = Path.expand("_build/openssl-#{openssl_version}-#{target}")

    otp_target =
      case target do
        "macos-aarch64" -> "aarch64-apple-darwin"
        "macos-x86_64" -> "x86_64-apple-darwin"
        "ios-aarch64" -> "aarch64-apple-ios"
        "iossimulator-aarch64" -> "aarch64-apple-iossimulator"
        "iossimulator-x86_64" -> "x86_64-apple-iossimulator"
      end

    shell!("""
    scripts/build_otp.sh \\
      #{version} \\
      #{source_dir} \\
      #{target_dir} \\
      #{otp_target} \\
      #{openssl_dir} \\
      $PWD/scripts/xcomp/#{target}.conf
    """)

    release
  end

  defp otp_target_dir(release, target) do
    version = release.options[:bootstrap][:otp_version]
    Path.expand("_build/otp-#{version}-#{target}")
  end

  require EEx

  launcher = ~S"""
  #include <Foundation/Foundation.h>
  #include <stdlib.h>

  extern void erl_start(int argc, char **argv);

  void do_erl_start(
    const char* rootdir,
    const char* bindir,
    const char* configdir,
    const char* bootdir,
    const char* libdir
  );

  int main(int argc, char *argv[]) {
      NSString* rootdir;
      if ([[NSBundle mainBundle] bundleIdentifier]) {
        // rootdir = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/rel"];
        rootdir = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/rel"];
      } else {
        // if we're not in a .app bundle, bundlePath will return path to this executable, bin/app
        rootdir = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/../rel"];
      }
      NSString* bindir = [rootdir stringByAppendingString:@"/erts-<%= release.erts_version %>/bin"];
      NSString* configdir = [rootdir stringByAppendingString:@"/releases/<%= release.version %>/sys"];
      NSString* bootdir = [rootdir stringByAppendingString:@"/releases/<%= release.version %>/start"];
      NSString* libdir = [rootdir stringByAppendingString:@"/lib"];

      // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          do_erl_start(
              [rootdir UTF8String],
              [bindir UTF8String],
              [configdir UTF8String],
              [bootdir UTF8String],
              [libdir UTF8String]
          );
      // });
      printf("about to quit\n");
  }

  void do_erl_start(
    const char* rootdir,
    const char* bindir,
    const char* configdir,
    const char* bootdir,
    const char* libdir) {

    setenv("BINDIR", bindir, 0);
    const char *args[] = {
        "app",
        // "-sbwt",
        // "none",
        "--",
        // "-start_epmd",
        // "false",
        // "-home",
        // "/tmp",
        // "-sname",
        // "app",
        "-root",
        rootdir,
        "-bindir",
        bindir,
        "-config",
        configdir,
        "-boot",
        bootdir,
        "-boot_var",
        "RELEASE_LIB",
        libdir,
        "-noshell",
    };
    erl_start(sizeof(args) / sizeof(args[0]), (char **)args);
  }
  """

  EEx.function_from_string(:defp, :launcher, launcher, [:release])

  defp shell!(cmd, opts \\ []) do
    {_, 0} = System.shell(cmd, [into: IO.stream()] ++ opts)
  end
end
