defmodule Blockchain.ProofOfWorkTest do
  use ExUnit.Case, async: true

  alias Blockchain.{Block, ProofOfWork}

  test "compute" do
    b =
      "some data"
      |> Block.generate_next_block
      |> ProofOfWork.compute
    
    assert b.nonce != nil
    assert String.starts_with?(b.hash, "0")
    assert ProofOfWork.verify(b)
  end

  test "verify" do
    hash = "0000DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60"
    {n, _} = Integer.parse(hash, 16)
    assert ProofOfWork.verify(hash, n + 1)
    refute ProofOfWork.verify(hash, n)
    refute ProofOfWork.verify(hash, n - 1)
  end

  test "calculate change for difficulty" do
    timestamps = [10, 16, 11, 10, 3, 18, 25, 2]
    expected_time = 60
    mine_time = 36
    take_percent = 1

    expected_diff_change = (expected_time / mine_time)

    actual_diff_change = timestamps
      |> ProofOfWork.calculate_difficulty_change(expected_time, take_percent)

    assert expected_diff_change == actual_diff_change
  end

  test "calculate difficulty from change" do
    current_diff = 1

    change = 0.4
    expected_diff = current_diff * change
    actual_diff = ProofOfWork.calculate_difficulty(change, current_diff)

    assert expected_diff == actual_diff

    change = 1.5
    expected_diff = current_diff * change
    actual_diff = ProofOfWork.calculate_difficulty(change, current_diff)

    assert expected_diff == actual_diff
  end
end
