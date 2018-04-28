defmodule Blockchain.P2P.Server do
  @moduledoc """
  TCP server to handle communications between peers
  """

  alias Blockchain.P2P.Peers, as: Peers
  alias Blockchain.P2P.Command, as: Command

  @spec accept(integer) :: no_return()
  def accept(port) do
    opts = [:binary, packet: 4, active: false, reuseaddr: true]
    {:ok, listen_socket} = :gen_tcp.listen(port, opts)

    Logger.info "accepting connections on port #{port}"
    loop_acceptor(listen_socket)
  end

  @spec loop_acceptor(port()) :: no_return()
  defp loop_acceptor(listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)

    case handle_socket(socket) do
      :ok ->
        loop_acceptor(listen_socket)
      {:error, reason} ->
        Logger.info "unable to accept connection: #{reason}"
    end
  end

  @spec handle_socket(port()) :: :ok | {:error, atom()}
  def handle_socket(socket) do
    Peers.add(socket)

    {:ok, pid} =
      Task.Supervisor.start_child(Blockchain.P2P.Server.TasksSupervisor, fn ->
        serve(socket)
      end)

    :gen_tcp.controlling_process(socket, pid)
  end
end
