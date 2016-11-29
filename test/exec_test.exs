defmodule Erlexec.Test do
  use ExUnit.Case, async: true
	
	test "stdout stderr monitor" do
		cmd = ~c(sleep .2; echo stdout; sleep .2; echo stderr >&2)
		{:ok, exec_pid, exec_os_pid} = :exec.run(cmd, [:monitor, :stdout, :stderr])

		assert_receive {:stdout, ^exec_os_pid, "stdout\n"}, 250
		assert_receive {:stderr, ^exec_os_pid, "stderr\n"}, 250
		assert_receive {:DOWN, ^exec_os_pid, :process, ^exec_pid, :normal}, 100
	end	

	test "exit 1" do
		cmd = ~c(exit 1)
		{:ok, exec_pid, exec_os_pid} = :exec.run(cmd, [:monitor, :stdout, :stderr])

		assert_receive {:DOWN, ^exec_os_pid, :process, ^exec_pid, {:exit_status, 256}}, 100
	end	
end
