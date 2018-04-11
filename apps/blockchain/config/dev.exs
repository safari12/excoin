use Mix.Config

config :blockchain, Blockchain.ProofOfWork,
  # target_max: round(:math.pow(16, 63)) - 1,
  target_max: "00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
  window: 700,
  expected_window_time: 84000
