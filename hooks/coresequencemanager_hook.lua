core:module("CoreSequenceManager")

function SequenceManager:_add_sequences_from_unit_data(unit_data)
	local unit_name = unit_data:name()
	local unit_name_key = unit_name:key()

	if self._sequence_file_map[unit_name_key] then
		return
	end

	local seq_manager_filename = unit_data:sequence_manager_filename()

	if seq_manager_filename then
		for key, file in pairs(self._sequence_file_map) do
			if file == seq_manager_filename then
				self._sequence_file_map[unit_name_key] = seq_manager_filename
				self._unit_elements[unit_name_key] = self._unit_elements[key]

				return
			end
		end

		if DB:has(self.SEQUENCE_FILE_EXTENSION, seq_manager_filename) and not (tostring(seq_manager_filename) == "Idstring(@ID67768423451632b3@)") then
			self._sequence_file_map[unit_name_key] = seq_manager_filename
			local type = self.SEQUENCE_FILE_EXTENSION:id()
			--manager_node = self:_serialize_to_script(type, seq_manager_filename)

			log("File " .. tostring(seq_manager_filename))

			if Application:editor() then
				manager_node = PackageManager:editor_load_script_data(type, seq_manager_filename)
			else
				manager_node = PackageManager:script_data(type:id(), seq_manager_filename)
			end

		elseif Application:production_build() then
			Application:error("Unit \"" .. unit_name:t() .. "\" refers to the external sequence manager file \"" .. seq_manager_filename:t() .. "." .. self.SEQUENCE_FILE_EXTENSION .. "\", but it doesn't exist.")
		else
			Application:error("Unit \"" .. tostring(unit_name) .. "\" refers to the external sequence manager file \"" .. tostring(seq_manager_filename) .. "\", but it doesn't exist.")
		end

		if manager_node then
			for _, data in ipairs(manager_node) do
				if data._meta == "unit" then
					if self._unit_elements[unit_name_key] then
						if Application:production_build() then
							Application:throw_exception("Unit \"" .. unit_name:t() .. "\" has duplicate <unit/>-elements in the external sequence manager file \"" .. seq_manager_filename:t() .. "." .. self.SEQUENCE_FILE_EXTENSION .. "\".")
						else
							Application:error("Unit \"" .. tostring(unit_name) .. "\" has duplicate <unit/>-elements in the external sequence manager file \"" .. tostring(seq_manager_filename) .. "\".")
						end
					else
						self._unit_elements[unit_name_key] = UnitElement:new(data, unit_name)
					end
				end
			end
		end
	end
end
