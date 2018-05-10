defmodule Core.BlockTest do
  use ExUnit.Case, async: true

  alias Core.{Block, Chain}

  describe "generate_next_block" do
    test "should generate the next block for chain" do
      data = "some data"
      b = Block.generate_next_block("some data")
      latest_block = Chain.latest_block()

      assert b.header.prev_hash == latest_block.header.hash
      assert b.data == data
      assert b.header.height == latest_block.header.height + 1
      assert b.header.difficulty == nil
      assert b.header.timestamp > latest_block.header.timestamp
      assert byte_size(b.header.hash) == 64
    end
  end
end
