require Logger

defmodule Core.P2P.Command do
  @moduledoc """
  TCP server commands
  """

  alias Core.{Chain, Block, Mempool}
  alias Core.P2P.Payload, as: Payload
  alias Core.P2P.Server, as: Server

  @type return :: :ok | {:ok, String.t()} | {:error, atom()}

  @spec handle(String.t()) :: return
  def handle(data) do
    case Payload.decode(data) do
      {:ok, payload} ->
        handle_payload(payload)
      {:error, _reason} = err ->
        err
    end
  end

  @spec handle_payload(Payload.t()) :: return
  defp handle_payload(%Payload{type: "ping"}) do
    {:ok, "pong"}
  end

  defp handle_payload(%Payload{type: "query_latest"}) do
    Logger.info "asking for latest block"

    response = [Chain.latest_block]
      |> Payload.response_blockchain
      |> Payload.encode!

    {:ok, response}
  end

  defp handle_payload(%Payload{type: "query_all"}) do
    Logger.info "asking for all blocks"

    response = Chain.all_blocks
      |> Payload.response_blockchain
      |> Payload.encode!

    {:ok, response}
  end

  defp handle_payload(%Payload{type: "response_blockchain", blocks: received_chain}) do
    latest_block_held = Chain.latest_block
    [latest_block_received | _] = received_chain

    cond do
      latest_block_held.header.height >= latest_block_received.header.height ->
        Logger.info "received core is no longer, ignoring chain"
        :ok

      latest_block_held.header.hash == latest_block_received.header.prev_hash ->
        Logger.info "adding new block"
        add_block(latest_block_received)
        :ok

      length(received_chain) == 1 ->
        Logger.info "asking for all blocks"

        response = Payload.query_all
          |> Payload.encode!

        {:ok, response}

      true ->
        Logger.info "replacing my chain"
        Chain.replace_chain(received_chain)
    end
  end

  defp handle_payload(%Payload{type: "mining_request", data: data}) do
    case Mempool.add(data) do
      :ok ->
        Logger.info "received data to mine"
        broadcast_mining_request(data)
        :ok
      {:error, _reason} ->
        # block is already in mining pool, or BlockData.verify failed
        :ok
    end
  end

  defp handle_payload(_) do
    {:error, :unknown_type}
  end

  @spec add_block(Block.t()) :: :ok
  defp add_block(%Block{} = block) do
    # notify mining pool to stop working on this block
    with :ok <- Chain.add_block(block),
         :ok <- Mempool.block_mined(block) do
      broadcast_new_block(block)
    else
      {:error, _reason} ->
        # block is invalid just ignoring it
        :ok
    end
  end

  @spec broadcast_new_block(Block.t()) :: :ok
  def broadcast_new_block(%Block{} = block) do
    Logger.info "broadcasting new block"

    [block]
      |> Payload.response_blockchain
      |> Payload.encode!
      |> Server.broadcast
  end

  @spec broadcast_mining_request(Core.BlockData.t()) :: :ok | {:error, atom()}
  def broadcast_mining_request(data) do
    Logger.info "broadcasting mining request"

    data
      |> Payload.mining_request
      |> Payload.encode!
      |> Server.broadcast

    Mempool.add(data)
  end

  @spec ask_all_blocks(port()) :: :ok | {:error, atom()}
  def ask_all_blocks(socket) do
    Payload.query_all
      |> Payload.encode!
      |> Server.send_data(socket)
  end
end
