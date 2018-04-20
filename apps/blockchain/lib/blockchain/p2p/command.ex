require Logger

defmodule Blockchain.P2P.Command do
  @moduledoc """
  TCP server commands
  """

  alias Blockchain.{Chain, Block}
  alias Blockchain.P2P.Payload, as: Payload

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
      latest_block_held.index >= latest_block_received.index ->
        Logger.info "received blockchain is no longer, ignoring chain"
        :ok

      latest_block_held.hash == latest_block_received.prev_hash ->
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
end
