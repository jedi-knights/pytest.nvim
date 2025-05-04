local Mj= {}

--- Parses pytest.ini and extracts marker names from the [markers] section.
-- @return table|nil markers: A list of marker names (or nil if file missing)
-- @return string|nil err: An error message if something went wrong
function M.get_markers()
  local markers = {}
  local ini = io.open("pytest.ini", "r")

  if not ini then
    return nil, "pytest.ini not found"
  end

  local in_markers_section = false
  for line in ini:lines() do
    -- Detect start of [markers] section
    if line:match("^%[markers%]") then
      in_markers_section = true
    -- Detect start of a new section (end of markers section)
    elseif line:match("^%[.*%]") then
      in_markers_section = false
    elseif in_markers_section then
      -- Extract the marker name (before the colon or space)
      local marker = line:match("^%s*([%w_]+)")
      if marker and marker ~= "" then
        table.insert(markers, marker)
      end
    end
  end

  ini:close()

  if #markers == 0 then
    return {}, nil  -- No markers found, but file was read successfully
  end

  return markers, nil
end

return M
