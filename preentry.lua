-- If the C++ stuff isn't installed, we're not interested.
--if not Application then return end

-- Don't load twice
if znix_editor then return end

log("EDITORR!!!!!!!!!!!!!!")

znix_editor = {
	editor_enabled = false,
	ews_enabled = true
}

--Global.load_level = true

dofile(ModPath .. "unhash.lua")
dofile(ModPath .. "ews.lua")
dofile(ModPath .. "overrides.lua")

--if true then return end

		Input:keyboard():acquire()
