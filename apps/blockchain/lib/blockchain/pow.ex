defmodule Blockchain.ProofOfWork do
  @moduledoc """
  ProofOfWork contains functions to perform and verify proof-of-work
  """

  alias Blockchain.Block

  @spec compute(Block.t() | Block.t(), integer) :: Block.t()
  def compute(%Block{} = b, target \\ target()) do
    {hash, nonce} = proof_of_work(b, target)
    %{b | hash: hash, nonce: nonce}
  end

  @spec verify(String.t() | String.t(), integer) :: boolean
  def verify(hash), do: verify(hash, target())

  def verify(hash, target) do
    {n, _} = Integer.parse(hash, 16)
    n < target
  end

  @spec target() :: integer
  defp target do
    hex_target = Application.get_env(:blockchain, __MODULE__)[:target]
    {target, _} = Integer.parse(hex_target, 16)
    target
  end

  @spec proof_of_work(Block.t(), integer, integer) :: {String.t(), integer}
  defp proof_of_work(%Block{} = block, target, nonce \\ 0) do
    b = %{block | nonce: nonce}
    hash = Block.compute_hash(b)

    case verify(hash, target) do
      true -> {hash, nonce}
      _ -> proof_of_work(block, target, nonce + 1)
    end
  end
end
