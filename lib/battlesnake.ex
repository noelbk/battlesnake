defmodule Battlesnake.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: Battlesnake.Supervisor)
  end
	
  def init(_) do
    children = [
			supervisor(Battlesnake.Player.Supervisor, []),
			supervisor(Battlesnake.Game.Supervisor, []),
      worker(Battlesnake, []),
    ]
    supervise(children, strategy: :one_for_one)
  end
end


defmodule Battlesnake do
	use GenServer
	
	defmodule State do
		defstruct [
			players: Map.new(),
			games: Map.new(),
		]
	end

	## public functions
	
	def start do
		Battlesnake.Supervisor.start_link
	end
	
	@doc """
  list all players
  """
	def list_players(opts \\ []) do
		GenServer.call(Battlesnake, {:list_players, opts})		
	end

	@doc """
  get player info
  """
	def get_player(name) do
		Battlesnake.Player.status(name)
	end

	@doc """
  register a player that can join games
  """
	def register_player(name, opts \\ []) do
		GenServer.call(Battlesnake, {:register_player, name, opts})		
	end

	@doc """
  list all games
  """
	def list_games(opts \\ []) do
		GenServer.call(Battlesnake, {:list_games, opts})		
	end

	@doc """
  get game info
  """
	def get_game(name) do
		Battlesnake.Game.status(name)
	end

	@doc """
  create a new game
  """
	def create_game(name \\ nil, opts \\ []) do
		GenServer.call(Battlesnake, {:create_game, name, opts})		
	end
		
	@doc """
  add a player to a game
  """
	def add_player(game, player) do
		Battlesnake.Game.add_player(game, player)
	end

	## GenServer implementation

	def start_link do
		GenServer.start_link(__MODULE__, %State{}, name: Battlesnake)
	end
	
	# players
	
  def handle_call({:list_players, _opts}, _from, state) do
    {:reply, {:ok, state.players}, state}
  end

  def handle_call({:register_player, name, opts}, _from, state) do
		reply = case Battlesnake.Player.Supervisor.register_player(name, opts)  do
							{:ok, _pid} ->
								{:ok, name}
							{:error, {:already_started, _pid}} ->
								{:ok, name}
						end
		{:reply, reply, %{state | players: Map.put(state.players, name, name)}}
  end

	# games
	
  def handle_call({:create_game, name, opts}, _from, state) do
		reply = case Battlesnake.Game.Supervisor.create_game(name, opts)  do
							{:ok, _pid} ->
								{:ok, name}
							{:error, {:already_started, _pid}} ->
								{:ok, name}
						end
		{:reply, reply, %{state | games: Map.put(state.games, name, name)}}
  end

  def handle_call({:list_games, _opts}, _from, state) do
    {:reply, {:ok, state.games}, state}
  end

end
	
	

	
