defmodule Blockchain.Crypto do
  @moduledoc """
  Wrapper around erlang crypto for easy piping
  """

  @type hash_algorithm :: :md5 | :ripemd160 | :sha | :sha224 | :sha256 | :sha384 | :sha512

  @spec hash(iodata, hash_algos) :: String.t()
  def hash(data, algo), do: :crypto.hash(algo, data)
end
