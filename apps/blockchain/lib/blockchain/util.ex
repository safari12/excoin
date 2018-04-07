defmodule Blockchain.Util do
  def adj_diff_list([]), do: []
  def adj_diff_list([_]), do: []
  def adj_diff_list([h | [h2 | t]]) do
    [h - h2] ++ adj_diff_list([h2 | t])
  end
end
