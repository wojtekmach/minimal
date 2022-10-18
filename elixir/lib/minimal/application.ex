defmodule Bridge.NIF do
  @moduledoc false
  @on_load {:__init__, 0}

  def __init__ do
    :erlang.load_nif(~c"bridge_nif", 0)
  end

  def command(_command) do
    :erlang.nif_error("NIF library not loaded")
  end
end

defmodule Minimal.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task,
       fn ->
         text = ~c"""
         elixir=#{System.version()}
         arch=#{:erlang.system_info(:system_architecture)}
         """

         for i <- 5..1//-1 do
           IO.puts("[#{inspect(__MODULE__)}] #{i}")
           text = text ++ ~c"\nQuitting in #{i}..."
           Bridge.NIF.command({:set_label, text})
           Process.sleep(1000)
         end

         System.stop()
       end}
    ]

    opts = [strategy: :one_for_one, name: Minimal.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
