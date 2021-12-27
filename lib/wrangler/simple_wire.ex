# SimpleWire is a simple, and fast, wire protocol to transport binary data.

#   Wire format
#   +------+------+-------------------+--------------------------------------+
#   |  V   |   T  |    length         |        payload                       |
#   +------+------+-------------------+--------------------------------------+
#   |  1   |  1   |      4            |        length bytes                  |
#   +------+------+-------------------+--------------------------------------+
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
    [@version, type(type), byte_size(payload), payload]
  end

  def parse_frame(<<3, 0, 0>>) do
    %{type: :heartbeat, version: @version, payload: nil, length: 0}
  end

  defp type(:heartbeat), do: 0
  defp type(:request), do: 1
  defp type(:response), do: 2
end
