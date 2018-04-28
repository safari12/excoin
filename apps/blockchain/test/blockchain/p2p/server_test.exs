defmodule Blockchain.P2P.ServerTest do
  use ExUnit.Case, async: false

  import Blockchain.Fixtures

  alias Blockchain.{Chain, Block}
  alias Blockchain.P2P.Payload, as: Payload
  alias Blockchain.P2P.Server, as: Server
  alias Blockchain.P2P.Peers, as: Peers

  setup do
    :ok = Chain.replace_chain([Block.genesis_block])
    :ok = Peers.remove_all()
    {:ok, socket} = open_connection_and_ping()
    {:ok, socket: socket}
  end

  describe "ping command" do
    test "should return pong response", %{socket: socket} do
      payload = Payload.ping
        |> Payload.encode!

      assert send_and_recv(socket, payload) == "pong"
    end
  end

  describe "query latest command" do
    test "should return latest block response", %{socket: socket} do
      payload = Payload.query_latest
        |> Payload.encode!

      response = send_and_recv(socket, payload)
      {:ok, payload} = Payload.decode(response)
      assert payload == %Payload{type: "response_blockchain", blocks: [Chain.latest_block]}
    end
  end

  describe "query all command" do
    test "should return all blocks response", %{socket: socket} do
      payload = Payload.query_all
        |> Payload.encode!

      response = send_and_recv(socket, payload)
      {:ok, payload} = Payload.decode(response)
      assert payload == %Payload{type: "response_blockchain", blocks: Chain.all_blocks}
    end
  end

  describe "bad commands" do
    test "should return invalid json", %{socket: socket} do
      assert send_and_recv(socket, "not valid json") == "invalid json"
    end
    test "should return unknown type", %{socket: socket} do
      assert send_and_recv(socket, Poison.encode!(%{type: "unknown"})) == "unknown type"
    end
  end
  
  describe "response blockchain command" do
    test "should query all blocks from peers if receive chain is one block", %{socket: socket} do
      remote_chain = mock_blockchain(5)

      [block | _] = remote_chain

      payload = [block]
        |> Payload.response_blockchain
        |> Payload.encode!

      {:ok, response} = Payload.decode(send_and_recv(socket, payload))
      assert response == Payload.query_all
    end
  end
end
