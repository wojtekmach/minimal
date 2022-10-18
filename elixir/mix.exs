defmodule Minimal.MixProject do
  use Mix.Project

  def project do
    [
      app: :minimal,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      preferred_cli_env: [
        app: :prod
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Minimal.Application, []}
    ]
  end

  defp deps do
    []
  end

  defp releases do
    [
      minimal: [
        # include_erts: false,
        targets: [
          "macos-aarch64",
          "macos-x86_64",
          "ios-aarch64",
          "iossimulator-aarch64",
          "iossimulator-x86_64"
        ],
        bootstrap: [
          openssl_version: "1.1.1k",
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
    app_path = Path.join(Mix.Project.build_path(), "Minimal-#{target}.app")
    File.rm_rf!(app_path)

    tmp_dir = Path.join(release.path, "tmp")
    File.mkdir_p!(tmp_dir)
    launcher_source_path = Path.join(tmp_dir, "launcher.m")

    launcher_bin_path =
      case target do
        "macos" <> _ -> Path.join([app_path, "Contents", "MacOS", "app"])
        "ios" <> _ -> Path.join([app_path, "app"])
      end

    rel_path =
      case target do
        "macos" <> _ -> Path.join([app_path, "Contents", "Resources", "rel"])
        "ios" <> _ -> Path.join([app_path, "rel"])
      end

    info_plist_path =
      case target do
        "macos" <> _ -> Path.join([app_path, "Contents", "Info.plist"])
        "ios" <> _ -> Path.join([app_path, "Info.plist"])
      end

    File.mkdir_p!(Path.dirname(launcher_bin_path))
    File.mkdir_p!(Path.dirname(rel_path))

    File.write!(launcher_source_path, launcher(release))
    File.cp_r!(release.path, rel_path)
    File.write!(info_plist_path, info_plist(release))

    flags =
      case target do
        "macos" <> _ -> "-framework AppKit -lc++"
        "ios" <> _ -> "-framework UIKit"
      end

    shell!("""
    #{cc(target)} \\
      -framework Foundation \\
      -I`elixir -e 'IO.puts "#{:code.root_dir()}/usr/include"'` \\
      #{flags} \\
      -L#{otp_target_dir(release, target)}/usr/lib -lerl \\
      -o #{launcher_bin_path} #{launcher_source_path}
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
    url = "https://github.com/openssl/openssl"

    ref =
      if match?("3" <> _, version) do
        "openssl-#{version}"
      else
        "OpenSSL_" <> String.replace(version, ".", "_")
      end

    source_dir = Path.expand("_build/openssl/openssl-src-#{version}")
    target_dir = Path.expand("_build/openssl/openssl-rel-#{version}-#{target}")
    shell!("scripts/openssl/build_openssl.sh #{url} #{ref} #{source_dir} #{target_dir} #{target}")
    release
  end

  defp build_otp(release, target) do
    version = release.options[:bootstrap][:otp_version]

    if version != otp_version() do
      raise "#{version} != #{otp_version()}"
    end

    ref = "OTP-#{version}"
    openssl_version = release.options[:bootstrap][:openssl_version]
    source_dir = Path.expand("_build/otp/otp-src-#{version}-#{target}")
    target_dir = otp_target_dir(release, target)
    ssl_dir = Path.expand("_build/openssl/openssl-rel-#{openssl_version}-#{target}")
    bridge_dir = Path.expand("_build/bridge/bridge-#{target}")
    File.mkdir_p!(bridge_dir)

    otp_target =
      case target do
        "macos-aarch64" -> "aarch64-apple-macos"
        "macos-x86_64" -> "x86_64-apple-macos"
        "ios-aarch64" -> "aarch64-apple-ios"
        "iossimulator-aarch64" -> "aarch64-apple-iossimulator"
        "iossimulator-x86_64" -> "x86_64-apple-iossimulator"
      end

    shell!("""
    #{cc(target)} \
      -c \
      -I`elixir -e 'IO.puts "#{:code.root_dir()}/usr/include"'` \
      -o #{bridge_dir}/bridge_nif.o c_src/bridge_nif.m
    libtool -static -o #{bridge_dir}/bridge_nif.a #{bridge_dir}/bridge_nif.o
    """)

    git_source_dir = Path.expand("_build/otp/otp-src-#{version}")

    unless File.dir?(git_source_dir) do
      shell!(
        "git clone --depth 1 https://github.com/erlang/otp --branch #{ref} #{git_source_dir}"
      )
    end

    shell!("""
    scripts/otp/build_otp.sh \\
      file://#{git_source_dir} \\
      #{ref} \\
      #{source_dir} \\
      #{target_dir} \\
      #{otp_target} \\
      #{ssl_dir} \\
      $PWD/scripts/otp/xcomp/#{target}.conf \\
      #{bridge_dir}/bridge_nif.a
    """)

    release
  end

  # From https://github.com/fishcakez/dialyze/blob/6698ae582c77940ee10b4babe4adeff22f1b7779/lib/mix/tasks/dialyze.ex#L168
  defp otp_version do
    major = :erlang.system_info(:otp_release) |> List.to_string()
    vsn_file = Path.join([:code.root_dir(), "releases", major, "OTP_VERSION"])

    try do
      {:ok, contents} = File.read(vsn_file)
      String.split(contents, "\n", trim: true)
    else
      [full] -> full
      _ -> major
    catch
      :error, _ -> major
    end
  end

  defp otp_target_dir(release, target) do
    version = release.options[:bootstrap][:otp_version]
    Path.expand("_build/otp/otp-rel-#{version}-#{target}")
  end

  require EEx

  EEx.function_from_file(:defp, :launcher, "launcher.m.eex", [:release])

  EEx.function_from_file(:defp, :info_plist, "Info.plist.eex", [:release])

  defp shell!(cmd, opts \\ []) do
    IO.puts(cmd)
    {_, 0} = System.shell(cmd, [into: IO.stream()] ++ opts)
  end

  defp cc(target) do
    sdk =
      case target do
        "macos" <> _ -> "macosx"
        "iossimulator" <> _ -> "iphonesimulator"
        "ios" <> _ -> "iphoneos"
      end

    flags =
      case target do
        "macos-aarch64" ->
          "--target=arm64-apple-macos11.0"

        "macos-x86_64" ->
          "--target=x86_64-apple-macos10.15"

        "ios-aarch64" ->
          "--target=arm64-apple-ios14.0"

        "iossimulator-aarch64" ->
          "--target=arm64-apple-ios14.0-simulator"

        "iossimulator-x86_64" ->
          "--target=x86_64-apple-ios14.0-simulator"
      end

    "xcrun -sdk #{sdk} cc #{flags} "
  end
end
