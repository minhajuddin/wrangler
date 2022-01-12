defmodule TCPSpeedTest do
  defmodule Server do
    require Logger

    def start(port \\ 5555) do
      {:ok, listener} = :gen_tcp.listen(port, [:binary, {:active, false}])
      accept_loop(listener)
    end

    def accept_loop(listener) do
      {:ok, sock} = :gen_tcp.accept(listener)
      spawn(fn -> serve_sock(sock, conn_id(sock), 0) end)
      accept_loop(listener)
    end

    defp conn_id(sock) do
      {:ok, peername} = :inet.peername(sock)
      peername
    end

    defp serve_sock(sock, conn_id, rx_bytes) do
      # Logger.info log_code: "RX_BYTES", rx_bytes: rx_bytes, conn_id: conn_id
      case :gen_tcp.recv(sock, 0, 1000) do
        {:ok, data} ->
          serve_sock(sock, conn_id, rx_bytes + byte_size(data))
        {:error, :timeout} ->
          serve_sock(sock, conn_id, rx_bytes)
        {:error, err} ->
          Logger.error log_code: "sock.error", rx_bytes: rx_bytes, conn_id: conn_id, error: err
      end
    end
  end

  defmodule Client do
    def start(host, port \\ 5555) do
    end
  end
end
