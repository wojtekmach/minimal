defmodule Foo.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    dbg(:erlang.system_info(:system_architecture))

    for i <- 5..1 do
      IO.write("#{i}... ")
      Process.sleep(1000)
    end

    System.stop()
    children = []
    opts = [strategy: :one_for_one, name: Foo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
