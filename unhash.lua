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
	mapping[Idstring(s):key()] = s
end

function Idstring:s()
	if mapping[self:key()] then return mapping[self:key()] end
	error("no mapping")
end

--[[
local old = Idstring
function Idstring(str)
	local id = old(str)
	if id:key() == "38d76ada6dbed4fa" or id:key() == "fad4be6dda6ad738" then
		error(str)
	end
	return id
end
--]]

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
