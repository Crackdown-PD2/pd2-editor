

local function overrideable(name)
	assert(name, "name is nil")
	local old = _G[name]
	assert(old, "old is nil")
	local new = {}
	_G[name] = new
	core.__pristine_G[name] = new -- Apply to modules, too

	setmetatable(new, {
		__index = function(t, k)
			if not old[k] then
				return nil
				--return function()
				--	error("Missing member " .. k .. " in c-class " .. name)
				--end
			end

			return function(badself, ...)
				return old[k](old, ...)
			end
		end
	})

	new.old = old
end

-- SoundDevice
overrideable("SoundDevice")

function SoundDevice:events(sb, ...)
	return self.old:events(sb, ...) or {}
end

-- PackageManager
overrideable("PackageManager")

function PackageManager:load(name, ...)
	--error("aabadsfjlk")
	--if name == "packages/game_base_init" then error("hi!") end
	log("Loading package " .. name)
	if name == "packages/production/editor" then
		log("Got it!!")
		return
	end

	--local id = Idstring(name)
	--if id:key() == "38d76ada6dbed4fa" or id:key() == "fad4be6dda6ad738" then
	--	error(id:key())
	--end

	return self.old:load(name, ...)
end

-- TODO
PackageManager.editor_load_script_data = PackageManager.script_data

PackageManager:set_streaming_enabled(true)

-- Application
	log(tostring(Application))

overrideable("Application")
	log(tostring(Application))


function Application:editor()
	local dbg = debug.getinfo(2, "fSl")

	local res = {
		["lib/entry.lua"] = true,
		["lib/managers/achievmentmanager.lua"] = true,
		["core/lib/units/data/corescriptunitdata.lua"] = true,
		["@mods/editor/hooks/coresetup_hook.lua"] = true,
	}

	if res[dbg.source] then
		return res[dbg.source] and znix_editor.editor_enabled
	end

	--log(json.encode(dbg))
	return znix_editor.editor_enabled --false
end

function Application:ews_enabled()
	return znix_editor.ews_enabled
end

-- TODO implement this in C
function Application:set_ews_window(win)
--	error("set_ews_window")
end
