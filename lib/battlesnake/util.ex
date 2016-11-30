defmodule Battlesnake.Util do
	def call_catch_noproc(to, msg) do
		try do
			GenServer.call(to, msg)
		catch
			:exit, {:noproc, {GenServer, :call, _call}} -> {:error, :noproc}
		end
	end		

	def cast_catch_noproc(to, msg) do
		try do
			GenServer.cast(to, msg)
		catch
			:exit, {:noproc, {GenServer, :call, _call}} -> {:error, :noproc}
		end
	end		

end

