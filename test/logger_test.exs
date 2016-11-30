defmodule Logger.Test do
  use ExUnit.Case, async: true
	import ExUnit.CaptureLog
	
	import Logger
	
	test "logger" do
		assert capture_log fn ->
			debug "debug"
			info "info"
			warn "warn"
			error "error"
		end =~ ~r/ warn\n.* error\n/ims
	end	
end
