defmodule Wrangler.SimpleWireTest do
  use ExUnit.Case, async: true
  import SimpleWire

  describe "heartbeat" do
    test "build" do
      assert build_frame(:heartbeat) |> :erlang.iolist_to_binary() == <<3, 0, 0, 0, 0, 0>>
    end

    test "parse" do
      assert parse_frame(<<3, 0, 0::size(32)>>) ==
               {:ok, %{type: :heartbeat, version: 3, payload: "", length: 0}}
    end
  end

  describe "request" do
    @test_payload_frames [
      {"everything is awesome",
       <<3, _type = 1, _length = 21::size(32), _payload = "everything is awesome"::binary>>},
      {"dang nabbit", <<3, 1, 11::size(32), "dang nabbit">>},
      {:binary.encode_unsigned(334_455),
       <<3, 1, 3::size(32)>> <> :binary.encode_unsigned(334_455)}
    ]
    test "build" do
      for {payload, frame} <- @test_payload_frames do
        assert build_frame(:request, payload) |> :erlang.iolist_to_binary() == frame
      end
    end

    test "parse" do
      for {payload, frame} <- @test_payload_frames do
        assert parse_frame(frame) ==
                 {:ok,
                  %{type: :request, version: 3, payload: payload, length: byte_size(payload)}}
      end
    end
  end
end
