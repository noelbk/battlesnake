defmodule Battlesnake.Player.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end
	
	def register_player(name, opts \\ []) do
		Supervisor.start_child(__MODULE__, [name, opts])
	end
	
  def init(_) do
    children = [
      worker(Battlesnake.Player, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end

defmodule Battlesnake.Player do
	use GenServer
	import Battlesnake.Util

	defmodule State do
		defstruct [
			:name,
			:opts,
			state: :none,
		]
	end

	@doc """
  handle one snake
  """
	def start_link(name, opts \\ []) do
		GenServer.start_link(__MODULE__, %State{name: name, opts: opts}, name: via_tuple(name))
	end

	def status(name) do
		call_catch_noproc(via_tuple(name), :status)
	end

	def load(name) do
		call_catch_noproc(via_tuple(name), :status)
	end
	
	def via_tuple(name) do
		{:via, :gproc, {:n, :l, {__MODULE__, name}}}
	end

  def handle_call(:status, _from, state) do
    {:reply, {:ok, state}, state}
  end

	# @doc """
  # returns after this player's code has loaded and it ready to play in a game
  # """ 
  # def handle_call(:load, from, state) do
	# 	# if unloaded, start loading
	# 	{:ok, loader} = spawn_loader(state)
	# 	state = put_in(state.loader_pid, loader)
	# 	# if still loading, defer reply
	# 	state = update_in(state.load_waiting, &(MapSet.put(&, from)))
  #   {:noreply, state}
	# 	# else reply immediately
  #   {:reply, reply_load(state), state}
  # end

	# def spawn_loader(state) do
	# end
	
	# def load_reply(state) do
	# 	{:ok, state.name}
	# end


	
	# def handle_info({:loaded, result}, state) do
	# 	Enum.map(state.load_waiting, &(GenServer.reply(&, load_reply(state))))
	# 	state = put_in(state.load_waiting, MapSet.new())
	# 	state = put_in(state.loader, nil)
	# 	state = put_in(state.load_done, true)
	# 	{:noreply, state}
	# end
	
end
