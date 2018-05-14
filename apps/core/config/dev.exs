use Mix.Config

config :core, Core.ProofOfWork,
  target_max: "00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"

config :core, Core.Block,
  genesis_header: %{
    height: 0,
    prev_hash: "0",
    merkle_root_hash: "0",
    timestamp: 1_465_154_705,
    nonce: 0,
    hash: "0000DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60",
    difficulty: 1,
    version: 1
  },
  genesis_data: "genesis block"
