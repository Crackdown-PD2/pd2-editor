if Application:editor() then
	require("core/lib/utils/dev/editor/CoreEditor")
end

-- This must be run first
local function MenuSetup_old_load_packages(self, cb)
	PackageManager:set_streaming_enabled(true)

	if not PackageManager:loaded("core/packages/base") then
		PackageManager:load("core/packages/base")
	end

	if not PackageManager:loaded("packages/start_menu") then
		PackageManager:load("packages/start_menu")
	end

	if not PackageManager:loaded("packages/load_level") then
		PackageManager:load("packages/load_level")
	end

	if not PackageManager:loaded("packages/load_default") then
		PackageManager:load("packages/load_default")
	end

	if _G.IS_VR and not PackageManager:loaded("packages/vr_base") then
		PackageManager:load("packages/vr_base")
	end

	if _G.IS_VR and not PackageManager:loaded("packages/vr_menu") then
		PackageManager:load("packages/vr_menu")
	end

	local prefix = "packages/dlcs/"
	local sufix = "/start_menu"
	local package = ""

	for dlc_package, bundled in pairs(tweak_data.BUNDLED_DLC_PACKAGES) do
		package = prefix .. tostring(dlc_package) .. sufix

		Application:debug("[MenuSetup:load_packages] DLC package: " .. package, "Is package OK to load?: " .. tostring(bundled))

		if bundled and (bundled == true or bundled == 1) and PackageManager:package_exists(package) and not PackageManager:loaded(package) then
			PackageManager:load(package)
		end
	end

	local platform = SystemInfo:platform()

	if not PackageManager:loaded("packages/game_base_init") then
		
		-- Lines: 95 to 97
		local function _load_wip_func()
			Global._game_base_package_loaded = true
		end

		-- Lines: 98 to 100
		local function load_base_func()
			PackageManager:load("packages/game_base", _load_wip_func)

			-- Start the game/editor loading at this point
			-- Note that we're not waiting for game_base - that
			-- takes much longer to load, and doesn't appear to be
			-- necessary. Move this to _load_wip_func if that's
			-- not the case.
			log("Loaded, init...")
			cb(self)
		end

		log("Loading...")
		PackageManager:load("packages/game_base_init", load_base_func)
	else
		log("Already Loaded, init...")
		cb(self)
	end
end

function CoreSetup:__init()
	-- Redo the window setup, now that editor is set
	self:__pre_init()

	self:init_category_print()

	if not PackageManager:loaded("core/packages/base") then
		PackageManager:load("core/packages/base")
	end

	managers.global_texture = managers.global_texture or CoreGTextureManager.GTextureManager:new()

	if not Global.__coresetup_bootdone then
		self:start_boot_loading_screen()

		Global.__coresetup_bootdone = true
	end

	self:load_packages()

	if Application:editor() then
		--self:_load_editor_packages()
	end

	World:set_raycast_bounds(Vector3(-50000, -80000, -20000), Vector3(90000, 50000, 30000))
	World:load((Application:editor() and false --[[ Note: edited here ]] ) and "core/levels/editor/editor" or "core/levels/zone", false)
	min_exe_version("1.0.0.7000", "Core Systems")
	rawset(_G, "UnitDamage", rawget(_G, "UnitDamage") or CoreUnitDamage)
	rawset(_G, "EditableGui", rawget(_G, "EditableGui") or CoreEditableGui)

	local aspect_ratio = nil

	if Application:editor() then
		local frame_resolution = SystemInfo:desktop_resolution()
		aspect_ratio = frame_resolution.x / frame_resolution.y
	elseif SystemInfo:platform() == Idstring("WIN32") then
		aspect_ratio = RenderSettings.aspect_ratio

		if aspect_ratio == 0 then
			aspect_ratio = RenderSettings.resolution.x / RenderSettings.resolution.y
		end
	else
		aspect_ratio = (SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("PS3") and SystemInfo:widescreen()) and RenderSettings.resolution.x / RenderSettings.resolution.y or RenderSettings.resolution.x / RenderSettings.resolution.y
	end

	if Application:ews_enabled() then
		managers.database = CoreDatabaseManager.DatabaseManager:new()
	end

	managers.localization = CoreLocalizationManager.LocalizationManager:new()
	managers.controller = CoreControllerManager.ControllerManager:new()
	managers.slot = CoreSlotManager.SlotManager:new()
	managers.listener = CoreListenerManager.ListenerManager:new()
	managers.viewport = CoreViewportManager.ViewportManager:new(aspect_ratio)
	managers.mission = CoreMissionManager.MissionManager:new()
	managers.expression = CoreExpressionManager.ExpressionManager:new()
	managers.worldcamera = CoreWorldCameraManager:new()
	managers.environment_effects = CoreEnvironmentEffectsManager.EnvironmentEffectsManager:new()
	managers.shape = CoreShapeManager.ShapeManager:new()
	managers.portal = CorePortalManager.PortalManager:new()
	managers.sound_environment = CoreSoundEnvironmentManager:new()
	managers.environment_area = CoreEnvironmentAreaManager.EnvironmentAreaManager:new()
	managers.cutscene = CoreCutsceneManager:new()
	managers.rumble = CoreRumbleManager.RumbleManager:new()
	managers.DOF = CoreDOFManager.DOFManager:new()
	managers.subtitle = CoreSubtitleManager.SubtitleManager:new()
	managers.overlay_effect = CoreOverlayEffectManager.OverlayEffectManager:new()
	managers.sequence = CoreSequenceManager.SequenceManager:new()
	managers.camera = CoreCameraManager.CameraTemplateManager:new()
	managers.slave = CoreSlaveManager.SlaveManager:new()
	managers.world_instance = CoreWorldInstanceManager:new()
	managers.environment_controller = CoreEnvironmentControllerManager:new()
	managers.helper_unit = CoreHelperUnitManager.HelperUnitManager:new()
	self._input = CoreInputManager.InputManager:new()
	self._session = CoreSessionManager.SessionManager:new(self.session_factory, self._input)
	self._smoketest = CoreSmoketestManager.Manager:new(self._session:session())

	managers.sequence:internal_load()
	self:init_managers(managers)

	if Application:ews_enabled() then
		managers.news = CoreNewsReportManager.NewsReportManager:new()
		assert(EWS)
		managers.toolhub = CoreToolHub.ToolHub:new()

		managers.toolhub:add("Environment Editor", CoreEnvEditor)
		managers.toolhub:add(CoreLuaProfilerViewer.TOOLHUB_NAME, CoreLuaProfilerViewer.LuaProfilerViewer)
		managers.toolhub:add(CoreMaterialEditor.TOOLHUB_NAME, CoreMaterialEditor)
		managers.toolhub:add("LUA Profiler", CoreLuaProfiler)
		managers.toolhub:add("Particle Editor", CoreParticleEditor)
		managers.toolhub:add(CorePuppeteer.EDITOR_TITLE, CorePuppeteer)
		managers.toolhub:add(CoreCutsceneEditor.EDITOR_TITLE, CoreCutsceneEditor)

		if not Application:editor() then
			managers.toolhub:add("Unit Reloader", CoreUnitReloader)
		end

		self:init_toolhub(managers.toolhub)
		managers.toolhub:buildmenu()
	end

	self.__gsm = assert(self:init_game(), "self:init_game must return a GameStateMachine.")

	managers.cutscene:post_init()
	self._smoketest:post_init()

	if not Application:editor() then
		-- Nothing
	end

	self:init_finalize()
end

local function tweak(name, cb)
	local orig = CoreSetup[name]
	CoreSetup[name] = function(self, ...)
		return cb(orig, self, ...)
	end
end

tweak("__update", function(orig, self, t, dt, ...)
	orig(self, t, dt, ...)
	if Application:ews_enabled() then
		managers.toolhub:update(t, dt)
	end
end)

--[[tweak("make_entrypoint", function(orig, self, ...)
	local already_setup = _G.CoreSetup.__entrypoint_is_setup
	orig(self, ...)

	if already_setup then return end

	local function wait_for_load(name)
		local orig = _G[name]
		_G[name] = function(...)
			-- TODO put some kind of warning on for the other functions
			if CoreSetup._entry_made then
				return orig(...)
			end
		end
	end

	--wait_for_load("pre_init")
	--wait_for_load("init")
	--wait_for_load("destroy")
	wait_for_load("update")
	wait_for_load("end_update")
	wait_for_load("paused_update")
	wait_for_load("paused_end_update")
	wait_for_load("render")
	wait_for_load("end_frame")
	wait_for_load("animations_reloaded")
	wait_for_load("script_reloaded")
	wait_for_load("entering_window")
	wait_for_load("leaving_window")
	wait_for_load("kill_focus")
	wait_for_load("save")
	wait_for_load("load")

	_G.init = function()
		log("Startup...")
		MenuSetup_old_load_packages(self, function()
			CoreSetup._entry_made = true
			self:__init()
		end)
	end
end)
]]--