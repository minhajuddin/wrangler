defmodule Wrangler.SimpleWireTest do
  use ExUnit.Case, async: true
  import SimpleWire

  describe "heartbeat" do
    test "build" do
      assert build_frame(:heartbeat) |> :erlang.iolist_to_binary() == <<0, 0, 0, 2, 3, 0>>
    end

    test "parse" do
      assert parse_frame(<<3, 0>>) ==
               {:ok, %{type: :heartbeat, version: 3, payload: ""}}
    end
  end

  describe "request" do
    @test_payload_frames [
      {"everything is awesome",
       <<_length = 23::size(32), _version = 3, _type = 1,
         _payload = "everything is awesome"::binary>>},
      {"dang nabbit", <<13::size(32), 3, 1, "dang nabbit">>},
      {:binary.encode_unsigned(334_455),
       <<5::size(32), 3, 1>> <> :binary.encode_unsigned(334_455)}
    ]
    test "build" do
      for {payload, frame} <- @test_payload_frames do
        assert build_frame(:request, payload) |> :erlang.iolist_to_binary() == frame
      end
    end

    test "parse" do
      # length is parsed by gen_tcp protocol 4
      for {payload, <<_length::size(32)>> <> frame} <- @test_payload_frames do
        assert parse_frame(frame) ==
                 {:ok, %{type: :request, version: 3, payload: payload}}
      end
    end
  end
end
