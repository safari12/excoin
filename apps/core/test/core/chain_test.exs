defmodule Core.ChainTest do
  use ExUnit.Case, async: false

  import Core.Fixtures

  alias Core.{Chain, Block}
  alias Core.Block.Header, as: BlockHeader

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

      invalid_header = %{valid_block.header | height: 1000}
      invalid_block = %{valid_block | header: invalid_header}
      assert {:error, :invalid_block_height} =
        Chain.add_block(invalid_block)

      invalid_header = %{valid_block.header | prev_hash: "not the good previous hash"}
      invalid_block = %{valid_block | header: invalid_header}
      assert {:error, :invalid_block_previous_hash} =
        Chain.add_block(invalid_block)

      invalid_header = %{valid_block.header | hash: "0#{valid_block.header.hash}"}
      invalid_block = %{valid_block | header: invalid_header}
      assert {:error, :invalid_block_hash} =
        Chain.add_block(invalid_block)

      invalid_header = %{valid_block.header | timestamp: 0}
      invalid_block = %{valid_block | header: invalid_header}
      assert {:error, :invalid_block_timestamp} =
        Chain.add_block(invalid_block)

      invalid_hash = "F#{String.slice(valid_block.header.hash, 1..-1)}"
      invalid_header = %{valid_block.header | hash: invalid_hash}
      invalid_block = %{valid_block | header: invalid_header}
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
        header: %BlockHeader{
          height: 1,
          prev_hash: "0",
          timestamp: 1_465_154_705
        },
        data: "genesis block"
      }

      assert {:error, :no_genesis_block} =
        Chain.validate_chain([invalid_genesis_block])
    end

    test "should fail if invalid next block" do
      genesis_block = Block.genesis_block()
      chain = [genesis_block]

      invalid_next_block = %Block{
        header: %BlockHeader{
          height: 1,
          prev_hash: "wrong",
          timestamp: 1_465_154_706
        },
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
