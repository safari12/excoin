defmodule Core.ChainTest do
  use ExUnit.Case, async: false

  import Core.Fixtures

  alias Core.{Chain, Block}

  setup do
    Chain.replace_chain(mock_blockchain(5))
  end

  describe "all_blocks" do
    test "should return genesis block as its first element" do
      b = Block.genesis_block()
      {:ok, first_block} = Enum.fetch(Chain.all_blocks(), -1)
      assert first_block == b
    end
  end

  describe "add_block" do
    test "should add block if valid" do
      b = "some data"
        |> Block.generate_next_block
        |> proof_of_work().compute

      assert :ok = Chain.add_block(b)
    end

    test "should fail if block is invalid" do
      valid_block =
        "some data"
        |> Block.generate_next_block
        |> proof_of_work().compute

      invalid_block = %{valid_block | index: 1000}
      assert {:error, :invalid_block_index} =
        Chain.add_block(invalid_block)

      invalid_block = %{valid_block | prev_hash: "not the good previous hash"}
      assert {:error, :invalid_block_previous_hash} =
        Chain.add_block(invalid_block)

      invalid_block = %{valid_block | hash: "0#{valid_block.hash}"}
      assert {:error, :invalid_block_hash} =
        Chain.add_block(invalid_block)

      invalid_block = %{valid_block | timestamp: 0}
      assert {:error, :invalid_block_timestamp} =
        Chain.add_block(invalid_block)

      invalid_hash = "F#{String.slice(valid_block.hash, 1..-1)}"
      invalid_block = %{valid_block | hash: invalid_hash}
      assert {:error, :proof_of_work_not_verified} =
        Chain.add_block(invalid_block)
    end
  end

  describe "last_blocks" do
    test "should return last 4 blocks" do
      assert Enum.take(Chain.all_blocks, -4) == Chain.last_blocks(4)
      assert Chain.all_blocks == Chain.last_blocks(50)
    end
  end

  describe "validate_chain" do
    test "should fail if invalid genesis block" do
      invalid_genesis_block = %Block{
        index: 1,
        prev_hash: "0",
        timestamp: 1_465_154_705,
        data: "genesis block"
      }

      assert {:error, :no_genesis_block} =
        Chain.validate_chain([invalid_genesis_block])
    end

    test "should fail if invalid next block" do
      genesis_block = Block.genesis_block()
      chain = [genesis_block]

      invalid_next_block = %Block{
        index: 1,
        prev_hash: "wrong",
        timestamp: 1_465_154_706,
        data: "first block"
      }

      assert {:error, :invalid_block_previous_hash} =
              Chain.validate_chain([invalid_next_block | chain])

      assert Chain.validate_chain(mock_blockchain(3))
    end
  end

  describe "replace_chain" do
    test "should replace chain if valid" do
      new_chain = mock_blockchain(6)
      :ok = Chain.replace_chain(new_chain)
      assert Chain.all_blocks() == new_chain
    end
  end

  defp proof_of_work, do: Application.fetch_env!(:core, :proof_of_work)

end
