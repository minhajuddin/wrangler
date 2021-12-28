defmodule Wrangler.Tcp do
  defmodule Server do
    use GenServer
    require Logger

    @doc false
    def start_link(opts) do
      GenServer.start_link(__MODULE__, opts)
    end

    @impl true
    def init(opts) do
      {:ok, sock} = :gen_tcp.listen(0, [:binary, {:active, :once}])
      {:ok, port} = :inet.port(sock)
      Logger.info(log_code: "tcp_server_started", port: port)
      {:ok, Map.merge(opts, %{sock: sock, port: port})}
    end
  end

  defmodule Client do
    use GenServer

    @doc false
    def start_link(opts) do
      GenServer.start_link(__MODULE__, opts)
    end

    @impl true
    def init(state) do
      {:ok, state}
    end
  end

  def play(wire_proto_mod, server_proto) do
    {:ok, server} =
      Server.start_link(%{
        wire_proto_mod: wire_proto_mod,
        port: server_proto
      })

    {:ok, client} =
      Client.start_link(%{
        wire_proto_mod: wire_proto_mod,
        port: server_proto
      })

    {:ok, %{server: server, client: client}}
  end
end
