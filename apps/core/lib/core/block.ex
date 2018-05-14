defmodule Core.Block do
  @moduledoc """
  Provides Block struct and related block operations
  """

  alias Core.{Block, Chain, Crypto}
  alias Core.Block.{Data, Header}

  @genesis_header Application.get_env(:core, __MODULE__)[:genesis_header]
  @genesis_data Application.get_env(:core, __MODULE__)[:genesis_data]

  @type t :: %__MODULE__{
    header: Header.t(),
    data: Data.t()
  }

  @derive [Poison.Encoder]
  defstruct [
    :header,
    :data
  ]

  @spec genesis_block() :: t
  def genesis_block do
    %Block{
      header: struct(Header, @genesis_header),
      data: @genesis_data
    }
  end

  @spec generate_next_block(Data.t(), t) :: t
  def generate_next_block(data, block \\ Chain.latest_block())

  def generate_next_block(data, %Block{} = latest_block) do
    b = %Block{
      header: %Header{
        height: latest_block.header.height + 1,
        prev_hash: latest_block.header.hash,
        timestamp: System.system_time(:second)
      },
      data: data
    }

    hash = compute_hash(b)
    %{b | header: %{b.header | hash: hash}}
  end

  @spec compute_hash(t) :: String.t()
  def compute_hash(%Block{
      header: %Header{
        height: hgt,
        prev_hash: ph,
        merkle_root_hash: mrh,
        timestamp: ts,
        nonce: n,
        difficulty: d,
        version: v,
        target: t
      },
      data: data
  }) do
    "#{hgt}#{ph}#{mrh}#{ts}#{n}#{d}#{v}#{t}#{data}"
      |> Crypto.hash(:sha256)
      |> Base.encode16()
  end

end
