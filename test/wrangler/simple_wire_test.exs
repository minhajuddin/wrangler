defmodule Wrangler.SimpleWireTest do
  use ExUnit.Case, async: true
  import SimpleWire

  describe "heartbeat" do
    test "build" do
      assert build_frame(:heartbeat) |> :erlang.iolist_to_binary() == <<3, 0, 0>>
    end

    test "parse" do
      assert parse_frame(<<3, 0, 0>>) == %{type: :heartbeat, version: 3, payload: nil, length: 0}
    end
  end

  describe "request" do
    test "build" do
      for {payload, frame} <- [
            {"everything is awesome",
             <<3, _type = 1, _length = String.length("everything is awesome"),
               _payload = "everything is awesome">>},
            {"dang nabbit", <<3, 1, String.length("dang nabbit"), "dang nabbit">>},
            {:binary.encode_unsigned(334_455), <<3, 1, 3>> <> :binary.encode_unsigned(334_455)}
          ] do
        assert build_frame(:request, payload) |> :erlang.iolist_to_binary() == frame
      end
    end

    test "parse" do
      assert parse_frame(<<3, 0, 0>>) == %{type: :heartbeat, version: 3, payload: nil, length: 0}
    end
  end
end
