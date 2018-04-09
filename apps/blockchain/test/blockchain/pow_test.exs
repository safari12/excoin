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

  test "calculate change in difficulty" do
    timestamps = [10, 16, 11, 10, 3, 18, 25, 2]
    expected_time = 60
    mine_time = 36
    take_percent = 1

    expected_diff_change = (expected_time / mine_time) - 1

    actual_diff_change = timestamps
      |> ProofOfWork.difficulty_change(expected_time, take_percent)

    assert expected_diff_change == actual_diff_change
  end
end
