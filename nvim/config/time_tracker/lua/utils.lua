local M = {}

function M.now()
  return vim.loop.now() / 1000
end
--
-- Human-friendly formatting
function M.format_time(sec)
  local h = math.floor(sec / 3600)
  sec = sec % 3600
  local m = math.floor(sec / 60)
  sec = sec % 60
  return string.format('%dh %dm %ds', h, m, sec)
end

function M.starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

--- Reads a file and returns its last line.
---@param path  string: the path to the file
---@return string|nil  the last line, or nil plus an error message
function M.get_last_line(path)
  local f, err = io.open(path, 'r')
  if not f then
    return nil, ('could not open file %q: %s'):format(path, err)
  end

  local last
  for line in f:lines() do
    last = line
  end

  f:close()
  return last
end

--- Replace the last line of a file (or append if empty).
-- @param path     string: file path
-- @param new_line string: content to place as the last line (without newline)
-- @return boolean, string|nil: true on success, or nil+err
function M.replace_last_line(path, new_line)
  -- 1) Read all lines into a table
  local lines = {}
  local in_f, err = io.open(path, 'r')
  if not in_f then
    return nil, ('could not open for reading %q: %s'):format(path, err)
  end
  for line in in_f:lines() do
    table.insert(lines, line)
  end
  in_f:close()

  -- 2) Replace last line (or append if file was empty)
  if #lines == 0 then
    lines[1] = new_line
  else
    lines[#lines] = new_line
  end

  -- 3) Write back all lines (overwriting)
  local out_f, err2 = io.open(path, 'w')
  if not out_f then
    return nil, ('could not open for writing %q: %s'):format(path, err2)
  end
  for idx, line in ipairs(lines) do
    out_f:write(line)
    if idx < #lines then
      out_f:write '\n'
    end
  end
  out_f:close()

  return true
end

--- Appends a line to the given file, adding a newline.
-- @param path     string: the path to the file
-- @param new_line string: the content to append (without newline)
-- @return boolean|string  true on success, or an error message
function M.append_line(path, new_line)
  local f, err = io.open(path, 'a') -- open in append mode
  if not f then
    return nil, ('could not open file %q for appending: %s'):format(path, err)
  end
  f:write('\n', new_line, '\n') -- write the line + newline
  f:close()
  return true
end

--- Returns the last n lines of the file at `path`.
---@param path string: the file path
---@param n    number: how many lines from the end to retrieve
---@return table|string[]|nil: an array of up to n lines (strings), or nil+err on failure
function M.tail_lines(path, n)
  -- 1) Open the file for reading
  local f, err = io.open(path, 'r')
  if not f then
    return nil, ('could not open file %q: %s'):format(path, err)
  end

  -- 2) Maintain a sliding buffer of size n
  local buf = {}
  for line in f:lines() do
    buf[#buf + 1] = line
    if #buf > n then
      table.remove(buf, 1)
    end
  end

  -- 3) Clean up and return
  f:close()
  return buf
end

return M
