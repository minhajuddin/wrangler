# SimpleWire is a simple, and fast, wire protocol to transport binary data.

#   Wire format
#   +-------------------+------+------+--------------------------------------+
#   |    length         |  V   |   T  |        payload                       |
#   +-------------------+------+------+--------------------------------------+
#   |      4            |  1   |  1   |        length-2 bytes                |
#   +-------------------+------+------+--------------------------------------+
#
#   V       | version           | unsigned byte
#   T       | type              | unsigned byte
#   length  | length of payload | unsigned int32
#   payload | binary payload    | binary

## Version
# The current version of the wire protocol is 3 it is a single byte and
# dictates how the wire protocol is interpreted.

## Type
# The type of the wire protocol is a single byte, it currently has 3 types
# 0 - heartbeat (no payload)
# 1 - request
# 2 - response

defmodule SimpleWire do
  @version 3
  @types %{
    0 => :heartbeat,
    1 => :request,
    2 => :response
  }

  def build_frame(:heartbeat) do
    build(:heartbeat, <<>>)
  end

  def build_frame(:request, payload) when is_binary(payload) do
    build(:request, payload)
  end

  def build_frame(:response, payload) when is_binary(payload) do
    build(:response, payload)
  end

  defp build(type, payload) do
    packet_size = byte_size(payload) + 2
    [<<packet_size::size(32)>>, @version, build_type(type), payload]
  end

  def parse_frame(<<@version::unsigned-size(8), wire_type::unsigned-size(8), payload::binary>>) do
    {:ok, %{type: parse_type(wire_type), version: @version, payload: payload}}
  end

  for {wire_type, type} <- @types do
    defp build_type(unquote(type)), do: unquote(wire_type)
  end

  for {wire_type, type} <- @types do
    defp parse_type(unquote(wire_type)), do: unquote(type)
  end
end
