defmodule Core.Block.Header do
  @moduledoc """
  Structure for block header
  """

  @type t :: %__MODULE__{
    height: non_neg_integer,
    prev_hash: String.t(),
    merkle_root_hash: String.t() | nil,
    timestamp: non_neg_integer,
    nonce: non_neg_integer | nil,
    hash: String.t() | nil,
    difficulty: non_neg_integer | nil,
    version: non_neg_integer | nil,
    target: String.t() | nil
  }

  @derive [Poison.Encoder]
  defstruct [
    :height,
    :prev_hash,
    :merkle_root_hash,
    :timestamp,
    :nonce,
    :hash,
    :difficulty,
    :version,
    :target
  ]
end
