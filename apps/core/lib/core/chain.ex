defmodule Core.Chain do
  @moduledoc """
  GenServer that stores the core. Chain is stored in reverse order
  (oldest block last)
  """

  use GenServer

  alias Core.{Block}
  alias Core.Block.Data, as: BlockData

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, [Block.genesis_block()]}
  end

  @spec latest_block() :: Block.t()
  def latest_block do
    GenServer.call(__MODULE__, :latest_block)
  end

  @spec all_blocks() :: [Block.t()]
  def all_blocks do
    GenServer.call(__MODULE__, :all_blocks)
  end

  @spec last_blocks(integer) :: [Block.t()]
  def last_blocks(n) do
    GenServer.call(__MODULE__, {:last_blocks, n})
  end

  @spec add_block(Block.t()) :: :ok | {:error, atom()}
  def add_block(%Block{} = b) do
    GenServer.call(__MODULE__, {:add_block, b})
  end

  @spec replace_chain([Block.t()]) :: :ok | {:error, atom()}
  def replace_chain(chain) do
    GenServer.call(__MODULE__, {:replace_chain, chain})
  end

  def handle_call(:latest_block, _from, chain) do
    [h | _] = chain
    {:reply, h, chain}
  end

  def handle_call(:all_blocks, _from, chain) do
    {:reply, chain, chain}
  end

  def handle_call({:last_blocks, n}, _from, chain) do
    {:reply, Enum.take(chain, -n), chain}
  end

  def handle_call({:add_block, %Block{} = b}, _from, chain) do
    [prev_block | _] = chain

    case validate_block(prev_block, b, chain) do
      {:error, reason} ->
        {:reply, {:error, reason}, chain}
      :ok ->
        {:reply, :ok, [b | chain]}
    end
  end

  def handle_call({:replace_chain, new_chain}, _from, chain) do
    case validate_chain(new_chain) do
      :ok -> {:reply, :ok, new_chain}
      {:error, _} = error -> {:reply, error, chain}
    end
  end

  @spec validate_block(
    Block.t(),
    Block.t(),
    [Block.t()]) :: :ok | {:error, atom()}
  defp validate_block(prev_block, block, chain) do
    cond do
      prev_block.header.height + 1 != block.header.height ->
        {:error, :invalid_block_height}
      prev_block.header.hash != block.header.prev_hash ->
        {:error, :invalid_block_previous_hash}
      prev_block.header.timestamp > block.header.timestamp ->
        {:error, :invalid_block_timestamp}
      proof_of_work().verify(block) == false ->
        {:error, :proof_of_work_not_verified}
      block.header.hash != Block.compute_hash(block) ->
        {:error, :invalid_block_hash}
      true ->
        validate_block_data(block, chain)
    end
  end

  @spec validate_block_data(Block.t(), [Block.t()]) :: :ok | {:error, atom()}
  defp validate_block_data(%Block{data: data}, chain), do:
    BlockData.verify(data, chain)

  @spec validate_chain([Block.t()]) :: :ok | {:error, atom()}
  def validate_chain([]), do: {:error, :empty_chain}

  def validate_chain([genesis_block | _] = chain) when length(chain) == 1 do
    if genesis_block == Block.genesis_block() do
      :ok
    else
      {:error, :no_genesis_block}
    end
  end

  def validate_chain([block | [prev_block | rest] = chain]) do
    case validate_block(prev_block, block, chain) do
      {:error, _} = error -> error
      _ -> validate_chain([prev_block | rest])
    end
  end

  @spec proof_of_work() :: module()
  defp proof_of_work, do: Application.fetch_env!(:core, :proof_of_work)
end
