defmodule Blockchain.P2P.PayloadTest do
  use ExUnit.Case, async: true
  import Blockchain.Fixtures

  alias Blockchain.{P2P.Payload}

  defmodule TestData do
    defstruct [:content, :hash, :timestamp]
  end

  describe "ping" do
    test "should return type ping" do
      assert "ping" == Payload.ping().type
    end
  end

  describe "query_all" do
    test "should return type query_all" do
      assert "query_all" == Payload.query_all().type
    end
  end

  describe "query_latest" do
    test "should return type query_latest" do
      assert "query_latest" == Payload.query_latest().type
    end
  end

  describe "response_blockchain" do
    test "should return type response_blockchain and blocks" do
      blocks = mock_blockchain(10)
      payload = Payload.response_blockchain(blocks)
      assert "response_blockchain" == payload.type
      assert blocks == payload.blocks
    end
  end

  describe "mining_request" do
    test "should return type mining_request and data" do
      data = "blah"
      payload = Payload.mining_request(data)
      assert "mining_request" == payload.type
      assert data == payload.data
    end
  end

  describe "encode and decode" do
    test "should return type data on struct data" do
      data = %TestData{
        content: "foo",
        hash: "1234DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60",
        timestamp: System.system_time(:second)
      }

      encoded_payload = data
        |> Payload.mining_request()
        |> Payload.encode!()

      assert {:ok, payload} = Payload.decode(encoded_payload)
      assert payload.data == data
    end

    test "should return type ata on basic types" do
      data = [42, "foobar"]

      encoded_payload = data
        |> Payload.mining_request()
        |> Payload.encode!()

      assert {:ok, payload} = Payload.decode(encoded_payload)
      assert payload.data == data
    end
  end
end
