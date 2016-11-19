defmodule Battlesnake.Test do
	use ExUnit.Case
	doctest Battlesnake
	doctest Battlesnake.Supervisor

	setup do
		{:ok, _sup_pid} = Battlesnake.start
		:ok
	end

	test "battlesnake_players" do
		{:ok, %{}} = Battlesnake.list_players

		player1_name = "player1"
		{:ok, ^player1_name} = Battlesnake.register_player(player1_name)
		{:ok, ^player1_name} = Battlesnake.register_player(player1_name)
		{:ok, %{^player1_name => ^player1_name}} = Battlesnake.list_players
		{:ok, %{name: ^player1_name}} = Battlesnake.get_player(player1_name)
		
		{:error, :noproc} = Battlesnake.get_player("noplayer")

		game1_name = "game1"
		{:ok, %{}} = Battlesnake.list_games
		{:ok, ^game1_name} = Battlesnake.create_game(game1_name)
		{:ok, ^game1_name} = Battlesnake.create_game(game1_name)
		{:ok, %{^game1_name => ^game1_name}} = Battlesnake.list_games
		{:ok, %{name: ^game1_name}} = Battlesnake.get_game(game1_name)
		{:ok, %{name: ^game1_name}} = Battlesnake.add_player(game1_name, player1_name)
		{:error, :noproc} = Battlesnake.add_player("nogame", player1_name)
		{:error, :noproc} = Battlesnake.add_player(game1_name, "noplayer")
		{:error, :noproc} = Battlesnake.add_player("nogame", "noplayer")
		
		{:error, :noproc} = Battlesnake.get_game("game2")
		
	end
	
end
