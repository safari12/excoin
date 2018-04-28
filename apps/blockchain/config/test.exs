use Mix.Config

config :blockchain, Blockchain.ProofOfWork,
  target_max: "0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"

config :logger,
  level: :error
