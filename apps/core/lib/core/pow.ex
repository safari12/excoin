defmodule Core.ProofOfWork do
  @moduledoc """
  ProofOfWork contains functions to perform and verify proof-of-work
  https://en.bitcoin.it/wiki/Proof_of_work
  """

  alias Core.{Block, Util, Chain}

  @target_max Application.get_env(:core, __MODULE__)[:target_max]
  @window Application.get_env(:core, __MODULE__)[:window]
  @expected_window_time Application.get_env(:core, __MODULE__)[:expected_window_time]
  @outlier_cutt_off Application.get_env(:core, __MODULE__)[:outlier_cutt_off]

  # compute computes the proof of work of a given block
  # and returns a new block with the `nonce` field set
  # so its hash satisfies the PoW. Can take a while according
  # to the difficulty set in `pow_difficulty` config

  @spec compute(Block.t() | Block.t()) :: Block.t()
  def compute(%Block{} = b) do
    diff = Chain.last_blocks(@window)
      |> Enum.map(&(&1.header.timestamp))
      |> calculate_difficulty_change(@expected_window_time, @outlier_cutt_off)
      |> Kernel.*(current_difficulty())

    target = diff
      |> calculate_target()

    {hash, nonce} = proof_of_work(b, target, diff)
    h = %{b.header | hash: hash, nonce: nonce, difficulty: diff}
    %{b | header: h}
  end

  # verify that a givens hash satisfy the core
  # proof-of-work

  @spec verify(Block.t()) :: boolean
  def verify(%Block{} = b) do
    verify(b.header.hash, calculate_target(b.header.difficulty))
  end

  @spec verify(String.t() | String.t(), integer) :: boolean
  def verify(hash, target) do
    {n, _} = Integer.parse(hash, 16)
    n < target
  end

  @spec current_difficulty() :: number
  def current_difficulty() do
    Chain.latest_block().header.difficulty
  end

  @spec calculate_target(number) :: integer
  def calculate_target(difficulty) do
    {t, _} = Integer.parse(@target_max, 16)
    (t / difficulty)
  end

  @spec calculate_difficulty_change([Block.t()], integer, number) :: number
  def calculate_difficulty_change(timestamps, expected_time, outlier_cutt_off) do
    timestamps = timestamps
      |> Util.adj_diff_list
      |> Enum.sort(&(&1 >= &2))
      |> Enum.filter(&(&1 > 0))

    size = timestamps
      |> Enum.count
      |> Kernel.*((100 - outlier_cutt_off) / 100)
      |> round

    time = timestamps
      |> Enum.take(size)
      |> Enum.sum

    try do
      result = (expected_time / time)
      cond do
        (result <= 4) && (result >= 0.25) -> result
        true -> 1
      end
    rescue
      ArithmeticError -> 1
    end
  end

  @spec proof_of_work(Block.t(), integer, number, integer) :: {String.t(), integer}
  defp proof_of_work(%Block{} = block, target, difficulty, nonce \\ 0) do
    h = %{block.header | nonce: nonce, difficulty: difficulty}
    b = %{block | header: h}
    hash = Block.compute_hash(b)

    case verify(hash, target) do
      true -> {hash, nonce}
      _ -> proof_of_work(block, target, difficulty, nonce + 1)
    end
  end
end
