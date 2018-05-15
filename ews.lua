
log("Setting up EWS...")
EWS.hello()

function EWS:_internal_get_error()
	local lvl = debug.getinfo(2, "n")
	return lvl.name
end

function EWS:system_file_exists(fname)
	return SystemFS:exists(fname)
end
