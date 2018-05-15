core:module("CoreMenuManager")

local old_register_menu = Manager.register_menu
function Manager:register_menu(menu)
	log(tostring(Application))

	if not Application:editor() then
		return old_register_menu(self, menu)
	end

	local id = menu.id
	log("Processing menu " .. id)

	if id == "kit_menu" then return end
	if id == "mission_end_menu" then return end
	if id == "loot_menu" then return end
	if id == "custom_safehouse_menu" then return end
	if id == "heister_interact_menu" then return end

	return old_register_menu(self, menu)
end

--local old = MenuManager.init
--function MenuManager:init(is_start_menu)
--	--assert(is_start_menu, "found it!")
--	return old(self, is_start_menu)
--end
