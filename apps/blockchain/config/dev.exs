use Mix.Config

config :blockchain, Blockchain.ProofOfWork,
  max_target: round(:math.pow(16, 63)) - 1
  window: 700
  expected_window_time: 84000
