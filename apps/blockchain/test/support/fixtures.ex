defmodule Blockchain.Fixtures do
  alias Blockchain.{Block, Chain}

  # mock a valid blockchain of n elements + genesis block
  def mock_blockchain(n), do: mock_blockchain([Block.genesis_block()], n)
  def mock_blockchain(acc, n) when n == 0, do: acc

  def mock_blockchain(acc, n) when n > 0 do
    [latest_block | _] = acc

    b =
      "some block data #{n}"
      |> Block.generate_next_block(latest_block)
      |> proof_of_work().compute

    mock_blockchain([b | acc], n - 1)
  end

  def create_blockchain(n) when n == 0, do: :ok
  def create_blockchain(n) when n > 0 do
    "some block data #{n}"
      |> Block.generate_next_block()
      |> proof_of_work().compute
      |> Chain.add_block

    create_blockchain(n - 1)
  end

  defp proof_of_work, do: Application.fetch_env!(:blockchain, :proof_of_work)
end
