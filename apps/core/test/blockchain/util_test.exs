defmodule Core.UtilTest do
  use ExUnit.Case, async: false

  alias Core.Util

  test "adj_diff_list" do
    expected = [10, 19, 10, -10, 20, -70]
    list = [79, 69, 50, 40, 50, 30, 100]
      |> Util.adj_diff_list

    assert expected == list
  end

end
