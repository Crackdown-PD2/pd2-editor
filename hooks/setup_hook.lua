
function Setup:load_packages()
	PackageManager:set_resource_loaded_clbk(Idstring("unit"), nil)
	TextureCache:set_streaming_enabled(true)

	if SystemInfo:platform() == Idstring("PS4") or SystemInfo:platform() == Idstring("XB1") then
		TextureCache:set_LOD_streaming_enabled(false)
	else
		TextureCache:set_LOD_streaming_enabled(true)
	end

	--if not Application:editor() then
	--	PackageManager:set_streaming_enabled(true)
	--end

	if not PackageManager:loaded("packages/base") then
		PackageManager:load("packages/base")
	end

	if not PackageManager:loaded("packages/dyn_resources") then
		PackageManager:load("packages/dyn_resources")
	end

	if Application:ews_enabled() and not PackageManager:loaded("packages/production/editor") then
		PackageManager:load("packages/production/editor")
	end

	PackageManager:script_data( Idstring( "menu" ), ("gamedata/menus/pause_menu"):id() )
	error("Package loaded!")
end



log("EDITORR!!!!!!!!!!!!!!")
EWS.hello()




local strs = {
	"none",
	"identity",
	"match",
	"candle",
	"desklight",
	"neonsign",
	"flashlight",
	"monitor",
	"dimlight",
	"streetlight",
	"searchlight",
	"reddot",
	"sun",
	"inside of borg queen",
	"megatron",
}

local mapping = {}
for _, s in ipairs(strs) do
	mapping[s:key()] = s
end

function Idstring:s()
	if mapping[self:key()] then return mapping[self:key()] end
	error("no mapping")
end

local function decode_idstring(id)
	local newstring = ""
	for c in id:key():gmatch("..") do
		newstring = c .. newstring
	end

	if ids[id:key()] then
		return newstring .. ":" .. ids[id:key()]
	end

	return newstring
end

--if true then return end

local function overrideable(name)
	assert(name, "name is nil")
	local old = _G[name]
	assert(old, "old is nil")
	local new = {}
	_G[name] = new

	setmetatable(new, {
		__index = function(t, k)
			if not old[k] then return nil end

			return function(badself, ...)
				return old[k](old, ...)
			end
		end
	})

	new.old = old
end

overrideable("SoundDevice")

function SoundDevice:events(sb, ...)
	return self.old:events(sb, ...) or {}
end

overrideable("PackageManager")

function PackageManager:load(name, ...)
	log("Loading " .. name)
	if name == "packages/production/editor" then
		log("Got it!!")
		return
	end
	return self.old:load(name, ...)
end

local old = Application
Application = {}
setmetatable(Application, {
	__index = function(t, k)
		if not old[k] then return nil end

		return function(badself, ...)
			return old[k](old, ...)
		end
	end
})

function Application:editor()
	return true
end
function Application:production_build()
	return true
end

function Application:ews_enabled()
	return true
end

function EWS:system_file_exists(fname)
    return SystemFS:exists(fname)
end