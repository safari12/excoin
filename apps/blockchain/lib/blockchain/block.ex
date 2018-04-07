defmodule Blockchain.Block do
  @moduledoc """
  Provides Block struct and related block operations
  """

  alias Blockchain.{Block, Chain, BlockData, Crypto}

  @type t :: %__MODULE__{
    index: integer,
    prev_hash: String.t(),
    timestamp: integer,
    data: BlockData.t(),
    nonce: integer | nil,
    hash: String.t() | nil,
    difficulty: integer
  }

  @derive [Poison.Encoder]
  defstruct [
    :index,
    :prev_hash,
    :timestamp,
    :data,
    :nonce,
    :hash,
    :difficulty
  ]

  @spec genesis_block() :: t
  def genesis_block do
    %Block{
      index: 0,
      prev_hash: "0",
      timestamp: 1_465_154_705,
      data: "genesis block",
      nonce: 35_679,
      hash: "0000DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60",
      difficulty: 1
    }
  end

  @spec generate_next_block(BlockData.t(), t) :: t
  def generate_next_block(data, block \\ Chain.latest_block())

  def generate_next_block(data, %Block{} = latest_block) do
    b = %Block{
      index: latest_block.index + 1,
      prev_hash: latest_block.hash,
      timestamp: System.system_time(:second),
      data: data
    }

    hash = compute_hash(b)
    %{b | hash: hash}
  end

  @spec compute_hash(t) :: String.t()
  def compute_hash(%Block{index: i, prev_hash: h, timestamp: ts, data: data, nonce: n}) do
    "#{i}#{h}#{ts}#{BlockData.hash(data)}#{n}"
    |> Crypto.hash(:sha256)
    |> Base.encode16()
end

end
