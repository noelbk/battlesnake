defmodule Battlesnake.Player.Test do
	use ExUnit.Case
	doctest Battlesnake.Player

	test "player" do
		name = "player1"
		{:global, {Battlesnake.Player, ^name}} = Battlesnake.Player.via_tuple(name)
		{:ok, _pid} = Battlesnake.Player.start_link("player1")
		{:ok, _player} = Battlesnake.Player.status("player1")
	end
end	
