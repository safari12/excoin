defmodule Blockchain.ProofOfWorkTest do
  use ExUnit.Case, async: true
  import Blockchain.Fixtures

  alias Blockchain.{Block, ProofOfWork}

  test "compute" do
    b =
      "some data"
      |> Block.generate_next_block
      |> ProofOfWork.compute

    assert b.nonce != nil
    assert ProofOfWork.verify(b.hash)
  end

  test "verify" do
    hash = "0000DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60"
    {n, _} = Integer.parse(hash, 16)
    assert ProofOfWork.verify(hash, n + 1)
    refute ProofOfWork.verify(hash, n)
    refute ProofOfWork.verify(hash, n - 1)
  end

  test "calculate difficulty" do
    expected_time = 100
    start_difficulty = 1
    number_of_blocks = 25
    mine_time = 50
    take_percent = 1
    decr_timestamp_unit = mine_time / number_of_blocks

    expected_diff =
       start_difficulty - (start_difficulty - (expected_time / mine_time))

    actual_diff = mock_blockchain(number_of_blocks)
      |> modify_timestamps(expected_time, decr_timestamp_unit)
      |> ProofOfWork.calculate_difficulty(expected_time, take_percent)

    assert expected_diff == actual_diff
  end

  defp modify_timestamps(blocks, last_timestamp, decr_timestamp_unit) do
    {blocks, _} = Enum.map_reduce(blocks, last_timestamp, fn(x, acc) ->
      {%{x | timestamp: acc}, acc - decr_timestamp_unit}
    end)

    blocks
  end
end
