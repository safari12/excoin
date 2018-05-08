defmodule Core.Fixtures do
  alias Core.{Block, Chain}
  alias Core.P2P.Payload, as: Payload

  # mock a valid core of n elements + genesis block
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

  def open_connection do
    opts = [:binary, packet: 4, active: false]
    port = Application.fetch_env!(:core, :port)
    :gen_tcp.connect('localhost', port, opts)
  end

  def open_connection_and_ping do
    {:ok, socket} = open_connection()

    ping = Payload.ping()
      |> Payload.encode!()

    "pong" = send_and_recv(socket, ping)
    {:ok, socket}
  end

  def send_and_recv(socket, payload) do
    :ok = :gen_tcp.send(socket, payload)
    recv(socket)
  end

  def recv(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end

  defp proof_of_work, do: Application.fetch_env!(:core, :proof_of_work)
end
