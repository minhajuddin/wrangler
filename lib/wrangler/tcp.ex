defmodule Wrangler.Tcp do
  defmodule Server do
    require Logger

    def start do
      Task.async(fn -> init(SimpleWire) end)
    end

    def init(wire_proto_mod) do
      {:ok, listener} = :gen_tcp.listen(0, [:binary, {:packet, 4}, {:active, false}])
      {:ok, port} = :inet.port(listener)
      Logger.info(log_code: "listener.started", port: port)
      accept_loop({listener, wire_proto_mod})
    end

    # TODO: make this parallely accept
    defp accept_loop({listener, wire_proto_mod}) do
      {:ok, sock} = :gen_tcp.accept(listener)
      spawn(fn -> setup_handler(sock, wire_proto_mod) end)
      accept_loop({listener, wire_proto_mod})
    end

    defp setup_handler(sock, wire_proto_mod) do
      {:ok, peername} = :inet.peername(sock)
      Logger.info(log_code: "tcp.accepted", peername: peername)
      serve(sock, wire_proto_mod)
    end

    defp serve(sock, wire_proto_mod) do
      case :gen_tcp.recv(sock, 0, :infinity) do
        {:ok, frame} ->
          handle_frame(frame, wire_proto_mod)
          serve(sock, wire_proto_mod)

        {:error, :timeout} ->
          serve(sock, wire_proto_mod)

        {:error, error} ->
          Logger.error(error_code: "recv.error", error: error)
          :gen_tcp.close(sock)
      end
    end

    defp handle_frame(frame, wire_proto_mod) do
      {:ok, message} = wire_proto_mod.parse_frame(frame)
      Logger.info(log_code: "received.packet", frame: frame, message: message)
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
