defmodule Battlesnake.Player do
	@moduledoc """
## Examples

"""

	use GenServer
	import Battlesnake.Util

	defmodule State do
		defstruct [
			:name,
			:opts,
			:exec_pid,
			:exec_os_pid,
			state: :init,
		]
	end

	# start a new instance
	def start_link(name, opts \\ []) do
		GenServer.start_link(__MODULE__, %State{name: name, opts: opts}, name: via_tuple(name))
	end

	# start supervisor
	def start_sup() do
		Battlesnake.Player.Supervisor.start_link
	end

	# start a new instance
	def start(name, opts \\ []) do
		Battlesnake.Player.Supervisor.start_player(name, opts)
	end

	# get current status
	def status(name) do
		call_catch_noproc(via_tuple(name), :status)
	end

	# wait for an instance to become ready
	def wait(name) do
		case call_catch_noproc(via_tuple(name), :wait) do
			err = {:error, :noproc} -> err
			:ok ->
				receive do
					{{module, name}, :started, state} -> {:ok, {module, name}, state}
				end
		end
	end

	# list all instances of this module
	def list() do
		:gproc.lookup_values(list_tuple)
	end
	
	def whereis(name) do
		:gproc.lookup_pid(name_tuple(name))
	end

	# subscribe to messages published by this instance
	def subscribe(name) do
		:gproc.reg(publish_tuple(name))
	end

	# publish a message to all subscribers
	def publish(name, msg) do
		:gproc.send(publish_tuple(name), publish_msg(name, msg))
	end

	## private functions

	# gproc tuple used to uniquely identify name
	defp name_tuple(name) do
		{:n, :l, {__MODULE__, name}}
	end
	
	defp via_tuple(name) do
		{:via, :gproc, name_tuple(name)}
	end

	# gproc name used to list instances
	defp list_tuple() do
		{:p, :l, {__MODULE__, :state}}
	end

	# gproc tuple used to send notifications about this instance
	defp publish_tuple(name) do
		{:p, :l, {__MODULE__, name, :subscribers}}
	end

	# message tuple sent via publish_tuple: {{module, name}, msg}
	defp publish_msg(name, msg) do
		{{__MODULE__, name}, msg}
	end
	
	## genserver handlers

	def init(state) do
		cmd = ~c(sleep 1; echo stdout; sleep 1; echo stderr >&2; exit)
		{:ok, exec_pid, exec_os_pid} = :exec.run(cmd, [:stdout, :stderr, :monitor])
		state = put_in(state.exec_pid, exec_pid)
		state = put_in(state.exec_os_pid, exec_os_pid)
		state = put_in(state.state, :started)
		:true = :gproc.reg(list_tuple, state)
		{:ok, state}
	end
	
	def terminate(reason, state) do
		IO.puts("terminate reason=#{inspect reason} state=#{inspect state}")
		{reason, state}
	end
 
  def code_change(old_vsn, state, extra) do
	  IO.puts("code_change old_vsn=#{inspect old_vsn} state=#{inspect state} extra=#{inspect extra}")
		{:ok, state}
	end
	
	def handle_call(:wait, from, state = %{state: :started}) do
    send(from, publish_msg(state.name, started_msg(state)))
		{:noreply, state}
  end

	def handle_call(:status, _from, state) do
		# reply to confirm I exist, but publish the started message later
    {:reply, {:ok, state}, state}
  end

	defp started_msg(state) do
		{:started, state}
	end
	
	def become_ready(state) do
		publish(state.name, started_msg(state))
	end
	
	def handle_info({:stdout, exec_os_pid, text}, state=%{exec_os_pid: exec_os_pid}) do
		{:ok, state}
	end

	def handle_info({:stderr, exec_os_pid, text}, state=%{exec_os_pid: exec_os_pid}) do
		{:ok, state}
	end

	def handle_info({'DOWN', exec_os_pid, exec_pid, reason}, state=%{exec_os_pid: exec_os_pid, exec_pid: exec_pid}) do
		state = put_in(state.status, :done)
		publish(:status, state)
		case reason do
			:normal -> {:ok, state}
			_ -> {:stop, {:error, "Unexpected exit reason: #{inspect reason}"}, state}
		end
	end

	def handle_info(msg, state) do
		{:stop, {:error, "Unexpected message: #{inspect msg}"}}
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

defmodule Battlesnake.Player.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end
	
	def start_player(name, opts \\ []) do
		Supervisor.start_child(__MODULE__, [name, opts])
	end
	
  def init(_) do
    children = [
      worker(Battlesnake.Player, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end

