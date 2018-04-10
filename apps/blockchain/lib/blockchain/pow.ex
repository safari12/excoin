defmodule Blockchain.ProofOfWork do
  @moduledoc """
  ProofOfWork contains functions to perform and verify proof-of-work
  https://en.bitcoin.it/wiki/Proof_of_work
  """

  alias Blockchain.{Block, Util, Chain}

  # compute computes the proof of work of a given block
  # and returns a new block with the `nonce` field set
  # so its hash satisfies the PoW. Can take a while according
  # to the difficulty set in `pow_difficulty` config

  @spec compute(Block.t() | Block.t()) :: Block.t()
  def compute(%Block{} = b) do
    diff = Chain.last_blocks(700)
      |> Enum.map(&(&1.timestamp))
      |> calculate_difficulty_change(120, 0.8)
      |> calculate_difficulty(current_difficulty())

    target = diff
      |> calculate_target()

    {hash, nonce} = proof_of_work(b, target, diff)
    %{b | hash: hash, nonce: nonce, difficulty: diff}
  end

  # verify that a givens hash satisfy the blockchain
  # proof-of-work

  @spec verify(Block.t()) :: boolean
  def verify(%Block{} = b) do
    verify(b.hash, calculate_target(b.difficulty))
  end

  @spec verify(String.t() | String.t(), integer) :: boolean
  def verify(hash, target) do
    {n, _} = Integer.parse(hash, 16)
    n < target
  end

  @spec current_difficulty() :: number
  def current_difficulty() do
    Application.get_env(
      :blockchain,
      __MODULE__,
      %{difficulty: Chain.latest_block().difficulty}
    )[:difficulty]
  end

  @spec calculate_target(number) :: integer
  def calculate_target(difficulty) do
    round(:math.pow(16, 63 - difficulty))
  end

  @spec calculate_difficulty_change([Block.t()], integer, number) :: number
  def calculate_difficulty_change(timestamps, expected_time, take_percent) do
    timestamps = timestamps
      |> Util.adj_diff_list
      |> Enum.sort(&(&1 >= &2))
      |> Enum.filter(&(&1 > 0))

    size = timestamps
      |> Enum.count
      |> Kernel.*(take_percent)
      |> round

    time = timestamps
      |> Enum.take(size)
      |> Enum.sum

    try do
      (expected_time / time) - 1
    rescue
      ArithmeticError -> 0
    end
  end

  @spec calculate_difficulty(number, number) :: number
  def calculate_difficulty(change, current_difficulty) do
    current_difficulty + (current_difficulty * change)
  end

  @spec proof_of_work(Block.t(), integer, number, integer) :: {String.t(), integer}
  defp proof_of_work(%Block{} = block, target, difficulty, nonce \\ 0) do
    b = %{block | nonce: nonce | difficulty: difficulty}
    hash = Block.compute_hash(b)

    case verify(hash, target) do
      true -> {hash, nonce}
      _ -> proof_of_work(block, target, nonce + 1)
    end
  end
end
