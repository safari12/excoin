defmodule Blockchain.ProofOfWork do
  @moduledoc """
  ProofOfWork contains functions to perform and verify proof-of-work
  https://en.bitcoin.it/wiki/Proof_of_work
  """

  use GenServer

  alias Blockchain.{Block, Util}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    difficulty = Application.get_env(:blockchain, __MODULE__)[:difficulty]
    {:ok, %{difficulty: difficulty}}
  end

  # compute computes the proof of work of a given block
  # and returns a new block with the `nonce` field set
  # so its hash satisfies the PoW. Can take a while according
  # to the difficulty set in `pow_difficulty` config

  @spec compute(Block.t() | Block.t(), integer) :: Block.t()
  def compute(%Block{} = b, target \\ target()) do
    {hash, nonce, diff} = proof_of_work(b, target)
    %{b | hash: hash, nonce: nonce, difficulty: diff}
  end

  # verify that a givens hash satisfy the blockchain
  # proof-of-work

  @spec verify(String.t() | String.t(), integer) :: boolean
  def verify(hash), do: verify(hash, target())

  def verify(hash, target) do
    {n, _} = Integer.parse(hash, 16)
    n < target
  end

  @spec current_difficulty() :: number
  def current_difficulty() do
    GenServer.call(__MODULE__, :current_difficulty)
  end

  @spec change_difficulty(number) :: {:ok, number}
  def change_difficulty(d) do
    GenServer.call(__MODULE__, {:change_difficulty, d})
  end

  @spec target() :: integer
  defp target do
    hex_target = Application.get_env(:blockchain, __MODULE__)[:target]
    {target, _} = Integer.parse(hex_target, 16)
    target
  end

  @spec calculate_difficulty([Block.t()], integer, number) :: number
  def calculate_difficulty(blocks, expected_mine_window, take_percent) do
    timestamps = blocks
      |> Enum.map(&(&1.timestamp))
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

    new_diff = current_difficulty()
      |> (&(&1 - (&1 - expected_mine_window / time))).()
      |> change_difficulty()

    new_diff
  end

  @spec proof_of_work(Block.t(), integer, integer) :: {String.t(), integer}
  defp proof_of_work(%Block{} = block, target, nonce \\ 0) do
    b = %{block | nonce: nonce}
    hash = Block.compute_hash(b)

    case verify(hash, target) do
      true -> {hash, nonce, 1}
      _ -> proof_of_work(block, target, nonce + 1)
    end
  end

  def handle_call(:current_difficulty, _from, pow) do
    {:reply, pow[:difficulty], pow}
  end

  def handle_call({:change_difficulty, d}, _from, pow) do
    {:reply, d, Map.put(pow, :difficulty, d)}
  end
end
