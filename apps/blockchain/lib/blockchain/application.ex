defmodule Blockchain.Application do
  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:blockchain, :port)
    
    children = [
      {Blockchain.Chain, []},
      {Blockchain.Mempool, []},
      {Blockchain.P2P.Peers, []},
      {Task.Supervisor, name: Blockchain.P2P.Server.TasksSupervisor},
      {Task, fn -> Blockchain.P2P.Server.accept(port) end}
    ]

    opts = [
      strategy: :one_for_one,
      name: Blockchain.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
