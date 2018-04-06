defmodule Blockchain.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Blockchain.Chain, []}
    ]

    opts = [
      strategy: :one_for_one,
      name: Blockchain.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
