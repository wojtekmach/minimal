defmodule Mix.Tasks.App do
  use Mix.Task

  @impl true
  def run([]) do
    run(["macos"])
  end

  def run([target]) when target in ["macos", "iossimulator"] do
    Mix.Task.run("release", ["--overwrite"])
    build_path = Mix.Project.build_path()
    name = "Minimal-#{target}-#{arch()}"
    app = "#{build_path}/#{name}.app"

    case target do
      "macos" ->
        log = "#{build_path}/#{name}.log"
        File.write!(log, "")
        {:ok, log_pid} = File.open(log, [:read])

        shell!(
          "/System/Library/Frameworks/CoreServices.framework" <>
            "/Versions/A/Frameworks/LaunchServices.framework" <>
            "/Versions/A/Support/lsregister -f #{app}"
        )

        shell!("open --stdout=#{log} --stderr=#{log} #{app}")
        connect(log_pid)

      "iossimulator" ->
        device = simulator_id()
        shell!("open -a Simulator")
        shell!("xcrun simctl boot #{device} || true")
        shell!("xcrun simctl install #{device} #{app}")
        shell!("xcrun simctl launch --console #{device} minimal")
    end
  end

  defp connect(log_pid) do
    {:ok, hostname} = :inet.gethostname()
    random = :crypto.strong_rand_bytes(3) |> Base.encode16(case: :lower)
    {:ok, _} = Node.start(:"app_#{random}@#{hostname}", :shortnames)

    Node.set_cookie(
      node(),
      "#{System.user_home!()}/.erlang.cookie" |> File.read!() |> String.to_atom()
    )

    app_node = :"app@#{hostname}"
    IO.write("connecting to #{app_node}...")
    connect_with_retries(app_node)

    Task.start_link(fn ->
      gets(log_pid)
    end)

    :ok = :net_kernel.monitor_nodes(true)

    receive do
      {:nodedown, ^app_node} ->
        :ok
    end
  end

  defp connect_with_retries(app_node) do
    if Node.connect(app_node) do
      IO.puts("")
      :ok
    else
      Process.sleep(100)
      IO.write(".")
      connect_with_retries(app_node)
    end
  end

  defp gets(pid) do
    data = IO.gets(pid, "")

    if data != :eof do
      IO.write(data)
    end

    gets(pid)
  end

  defp arch do
    case :erlang.system_info(:system_architecture) do
      ~c"aarch64" ++ _ -> "aarch64"
      _ -> "x86_64"
    end
  end

  defp shell!(cmd, opts \\ []) do
    {_, 0} = System.shell(cmd, [into: IO.stream()] ++ opts)
  end

  defp simulator_id do
    path = "#{Mix.Project.build_path()}/simulator_id"

    unless File.exists?(path) do
      shell!("xcrun simctl create 'iPhone' 'iPhone 13' > #{path}")
    end

    File.read!(path) |> String.trim()
  end
end
