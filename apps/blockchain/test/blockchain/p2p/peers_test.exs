defmodule Blockchain.P2P.PeersTest do
  use ExUnit.Case, async: true

  alias Blockchain.{P2P.Peers}

  setup do
    Peers.remove_all()
  end

  describe "start_link" do
    test "should return empty list" do
      assert [] == Peers.get_all()
    end
  end

  describe "add" do
    test "should add peer to list" do
      peer = "peer1"
      Peers.add(peer)
      assert peer == Peers.get_all() |> List.first
    end
  end

  describe "remove" do
    test "should remove peer from list" do
      peer1 = "peer1"
      peer2 = "peer2"
      Peers.add(peer1)
      Peers.add(peer2)
      Peers.remove(peer1)
      assert peer2 == Peers.get_all() |> List.first
    end
  end
end
