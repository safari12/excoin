defmodule Blockchain.BlockTest do
  use ExUnit.Case, async: true

  alias Blockchain.{Block, Chain}

  describe "generate_next_block" do
    test "should generate the next block for chain" do
      data = "some data"
      b = Block.generate_next_block("some data")
      latest_block = Chain.latest_block()

      assert b.prev_hash == latest_block.hash
      assert b.data == data
      assert b.index == latest_block.index + 1
      assert b.difficulty == nil
      assert b.timestamp > latest_block.timestamp
      assert byte_size(b.hash) == 64
    end
  end
end
