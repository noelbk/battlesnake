defmodule Test.PubSub do
	def reg(name) do
		:true = :gproc.reg(reg_tuple)
		:true = :gproc.add_local_property(name_property, name)
		:ok
	end
	
	def pub(msg) do
		:gproc.send(reg_tuple, {self(), msg})
	end

	def reg_tuple() do
		{:p, :l, {__MODULE__, :my_event}}
	end

	def name_property() do
		{__MODULE__, :name}
	end
end

defmodule Test.PubSubEcho do
	use GenServer

	def init(name) do
		:ok = Test.PubSub.reg(name)
		{:ok, []}
	end

	def handle_info({from, msg}, state) do
		send(from, {:reply, self(), msg})
		{:noreply, state}
	end
end

defmodule Gproc.PubSub.Test do
	use ExUnit.Case

	def flush_recv() do
		receive do
			{:reply, _from, _msg} -> flush_recv
		after 1 -> :ok
		end
	end
		
	def check_recv(expect) do
		receive do
			{:reply, from, msg} ->
				#IO.puts("got reply from=#{inspect from} msg=#{inspect msg}")
 				if MapSet.member?(expect, {from, msg}) do
					check_recv(MapSet.delete(expect, {from, msg}))
				else
					:ok = flush_recv
					{:error, :unexpected, "got unexpected msg=#{inspect msg} from=#{inspect from}"}
				end
		after 1 ->
				if MapSet.size(expect) == 0 do
					:ok
				else
					{:error, :timeout, "timed out waiting for expect=#{inspect expect}"}
				end
		end
	end
		
	def check(msgs, pids) do
		Enum.each(msgs, &(Test.PubSub.pub(&1)))
		expect = for msg <- msgs, pid <- pids, do: {pid, msg}
		check_recv(MapSet.new(expect))
	end
		
	test "pubsub" do
		:ok = check([:msg1], [])

		{:error, :timeout, _msg} = check([:msg12], [:nopid])

		{:ok, pid1} = GenServer.start_link(Test.PubSubEcho, :pid1)
		{:ok, pid2} = GenServer.start_link(Test.PubSubEcho, :pid2)

		assert MapSet.new([pid1, pid2]) == MapSet.new(:gproc.lookup_pids(Test.PubSub.reg_tuple))

		assert MapSet.new([{pid1, :pid1}, {pid2, :pid2}]) ==
			MapSet.new(:gproc.lookup_local_properties(Test.PubSub.name_property))
		
		:ok = check([:msg21, :msg22], [pid1, pid2])
		{:error, :unexpected, _msg} = check([:msg23, :msg24], [pid1])

		:ok = GenServer.stop(pid1)
		:ok = check([:msg31, :msg32], [pid2])
		{:error, :unexpected, _msg} = check([:msg33, :msg34], [pid1])
		assert MapSet.new([pid2]) == MapSet.new(:gproc.lookup_pids(Test.PubSub.reg_tuple))

		:ok = GenServer.stop(pid2)
		:ok = check([:msg41, :msg42], [])
		assert MapSet.new([]) == MapSet.new(:gproc.lookup_pids(Test.PubSub.reg_tuple))

		{:ok, pid3} = GenServer.start_link(Test.PubSubEcho, [], [])
		:ok = check([:msg51, :msg52], [pid3])
		assert MapSet.new([pid3]) == MapSet.new(:gproc.lookup_pids(Test.PubSub.reg_tuple))
	end	
end
