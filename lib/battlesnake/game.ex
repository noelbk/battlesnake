defmodule Battlesnake.Game.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end
	
	def create_game(name, opts \\ []) do
		Supervisor.start_child(__MODULE__, [name, opts])
	end
	
  def init(_) do
    children = [
      worker(Battlesnake.Game, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end

defmodule Battlesnake.Game do
	use GenServer
	import Battlesnake.Util

	defmodule State do
		defstruct [
			:name,
			:opts,
			state: :none,
			players: Map.new(),
		]
	end

	defmodule PlayerState do
		defstruct [
			:name,
			state: :none,
		]
	end

	def start(name, players, opts \\ []) do
		Battlesnake.Game.Supervisor.start_game(name, players, opts)
	end
	
	@doc """
  handle one game
  """
	def start_link(name, opts \\ []) do
		GenServer.start_link(__MODULE__, %State{name: name, opts: opts}, name: via_tuple(name))
	end

	def status(name) do
		call_catch_noproc(via_tuple(name), :status)
	end

	def add_player(game, player) do
		call_catch_noproc(via_tuple(game), {:add_player, player})
	end

	## Private 
	
	def via_tuple(name) do
		{:via, :gproc, {:n, :l, {__MODULE__, name}}}
	end

  def handle_call(:status, _from, state) do
    {:reply, {:ok, state}, state}
  end
	
  def handle_call({:add_player, player}, _from, state) do
		case Battlesnake.Player.status(player) do
			{:ok, _player_info} ->
				player_state = %PlayerState{name: player}
				{:reply, {:ok, state}, %{state | players: Map.put(state.players, player, player_state)}}
			e = {:error, :noproc} ->
				{:reply, e, state}
		end
  end
end
