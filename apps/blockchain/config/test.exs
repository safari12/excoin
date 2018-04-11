use Mix.Config

config :blockchain, Blockchain.ProofOfWork,
  target_max: "0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
  window: 700,
  expected_window_time: 84000
