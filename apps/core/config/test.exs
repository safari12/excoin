use Mix.Config

config :core, Core.ProofOfWork,
  target_max: "0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"

config :logger,
  level: :error
