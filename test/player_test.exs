defmodule Battlesnake.Player.Test do
	use ExUnit.Case
	doctest Battlesnake.Player

	test "player" do
		{:ok, player_sup_pid} = Battlesnake.Player.start_sup
		{:error, {:already_started, ^player_sup_pid}} = Battlesnake.Player.start_sup
		
		player1_name = "player1"
		{:ok, player1_pid} = Battlesnake.Player.start(player1_name)
		{:error, {:already_started, ^player1_pid}} = Battlesnake.Player.start(player1_name)
		
		{:ok, %{name: ^player1_name, state: :started}} = Battlesnake.Player.status(player1_name)

		[{^player1_pid, %{name: ^player1_name, state: :started}}] = Battlesnake.Player.list
	end
end	
