defmodule Blockchain.ProofOfWorkTest do
  use ExUnit.Case, async: true

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

  test "calculate increase in difficulty" do
    timestamps = [10, 16, 11, 10, 3, 18, 25, 2]
    expected_time = 60
    start_difficulty = 1
    mine_time = 36
    take_percent = 1

    ProofOfWork.change_difficulty(start_difficulty)

    expected_diff =
       start_difficulty - (start_difficulty - (expected_time / mine_time))

    actual_diff = timestamps
      |> ProofOfWork.calculate_difficulty(expected_time, take_percent)

    assert expected_diff == actual_diff
  end

  test "calculate decrease in difficulty" do
    timestamps = [10, 16, 11, 10, 3, 18, 25, 2, 60, 10]
    expected_time = 60
    start_difficulty = 1
    mine_time = 86
    take_percent = 1

    ProofOfWork.change_difficulty(start_difficulty)

    expected_diff =
       start_difficulty - (start_difficulty - (expected_time / mine_time))

    actual_diff = timestamps
      |> ProofOfWork.calculate_difficulty(expected_time, take_percent)

    assert expected_diff == actual_diff
  end
end
