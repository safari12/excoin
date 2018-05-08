defmodule Core.P2P.CommandTest do
  use ExUnit.Case, async: true

  import Core.Fixtures

  alias Core.{Chain, Block}
  alias Core.P2P.Payload, as: Payload
  alias Core.P2P.Command, as: Command
  alias Core.P2P.Peers, as: Peers

  defp call(%Payload{} = p) do
    p
      |> Payload.encode!
      |> Command.handle
  end

  setup do
    Peers.remove_all()
  end

  describe "handle_ping_payload" do
    test "should return pong" do
      assert call(Payload.ping()) == {:ok, "pong"}
    end
  end

  describe "handle_query_latest_payload" do
    test "should return latest block" do
      core = mock_blockchain(3)
      :ok = Chain.replace_chain(core)

      expected = [Chain.latest_block]
        |> Payload.response_blockchain
        |> Payload.encode!

      assert call(Payload.query_latest) == {:ok, expected}
    end
  end

  describe "handle_query_all_payload" do
    test "should return all blocks" do
      core = mock_blockchain(3)
      :ok = Chain.replace_chain(core)

      expected = Chain.all_blocks
        |> Payload.response_blockchain
        |> Payload.encode!

      assert call(Payload.query_all) == {:ok, expected}
    end
  end

  describe "handle_blockchain_response_payload" do
    test "should add new block when received" do
      remote_chain = mock_blockchain(5)

      [block | chain] = remote_chain
      :ok = Chain.replace_chain(chain)

      assert call(Payload.response_blockchain([block])) == :ok
      assert Chain.all_blocks() == remote_chain
    end

    test "should ignore smaller chain" do
      remote_chain = mock_blockchain(5)

      :ok = Chain.replace_chain(remote_chain)
      [_ | chain] = remote_chain

      assert call(Payload.response_blockchain(chain)) == :ok
      assert Chain.all_blocks == remote_chain
    end

    test "should replace chain if received chain is longer" do
      remote_chain = mock_blockchain(5)

      :ok = Chain.replace_chain([Block.genesis_block])
      assert call(Payload.response_blockchain(remote_chain)) == :ok
      assert Chain.all_blocks == remote_chain
    end

    test "should query blocks from peers if received chain a block higher" do
      remote_chain = mock_blockchain(5)

      :ok = Chain.replace_chain([Block.genesis_block])
      [latest_block | _] = remote_chain

      expected = Payload.query_all()
        |> Payload.encode!()

      assert call(Payload.response_blockchain([latest_block])) == {:ok, expected}
      assert Chain.all_blocks() == [Block.genesis_block()]
    end
  end

  describe "handle_mining_request_payload" do
    test "should return ok" do
      assert call(Payload.mining_request("data")) == :ok
    end
  end
end
