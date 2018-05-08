defmodule Core.Application do
  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:core, :port)
    
    children = [
      {Core.Chain, []},
      {Core.Mempool, []},
      {Core.P2P.Peers, []},
      {Task.Supervisor, name: Core.P2P.Server.TasksSupervisor},
      {Task, fn -> Core.P2P.Server.accept(port) end}
    ]

    opts = [
      strategy: :one_for_one,
      name: Core.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
