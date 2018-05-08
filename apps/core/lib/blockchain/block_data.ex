defprotocol Core.BlockData do
  @spec hash(t) :: String.t()
  def hash(data)

  @spec verify(t, [Core.Block.t()]) :: :ok | {:error, String.t()}
  def verify(data, chain)
end
defimpl Core.BlockData, for: BitString do
  def hash(string) do
    string
    |> Core.Crypto.hash(:sha256)
    |> Base.encode16()
  end

  def verify(_string, _chain), do: :ok
end
