-- time_tracker.lua
-- Enhanced: auto-init, immediate save flush, and robust timestamp capture
local utils = require 'utils'
local graph = require 'graph'

local M = {}

-- Determine project root by finding .git or default to cwd

function M.get_project_root()
  local path = vim.loop.cwd()
  while path and path ~= '/' do
    if vim.loop.fs_stat(path .. '/.git') then
      return path
    end
    path = vim.fn.fnamemodify(path, ':h')
  end
  return vim.loop.cwd()
end

-- File I/O helpers
function M.read_time(file)
  local f = io.open(file, 'r')
  if not f then
    return 0
  end
  local num = f:read '*n'
  f:close()
  return num or 0
end

function M.write_time(file, seconds)
  local f = io.open(file, 'w')
  if not f then
    vim.notify('TimeTracker: Cannot write to ' .. file, vim.log.levels.ERROR)
    return
  end
  f:write(seconds)
  f:close()
end

function M.update_root_time(file)
  local now = utils.now()
  if M.last then
    local elapsed = now - M.last
    local total = M.read_time(file) + elapsed
    M.write_time(file, total)
  end
  M.last = now
end

---@param file string
function M.write_time_for_today(file)
  local now = utils.now()
  if not M.last_today then
    M.last_today = now
  end
  local today = os.date '%Y-%m-%d'
  local last_record = utils.get_last_line(file)
  local elapsed = now - M.last_today

  if last_record and utils.starts_with(last_record, today) then
    local total = last_record:match '%S+%s+(%S+)'
    total = tonumber(total) + elapsed
    utils.replace_last_line(file, today .. ' ' .. tostring(total))
  else
    utils.append_line(file, today .. ' ' .. tostring(elapsed))
  end
  M.last_today = now
end

-- Initialize tracking and autocommands
function M.init()
  local root = M.get_project_root()
  M.file = root .. '/.nvim_time_tracker.txt'
  if not vim.loop.fs_stat(M.file) then
    M.write_time(M.file, 0)
  end

  M.dates_file = root .. '/.nvim_time_tracker_dates.txt'
  if not vim.loop.fs_stat(M.dates_file) then
    M.write_time_for_today(M.dates_file)
  end

  local group = vim.api.nvim_create_augroup('TimeTracker', { clear = true })

  -- Capture initial timestamp on VimEnter
  vim.api.nvim_create_autocmd('VimEnter', {
    group = group,
    callback = function()
      M.last = utils.now()
      M.last_today = utils.now()
    end,
  })

  -- Update timestamp on buffer load/enter
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufEnter' }, {
    group = group,
    callback = function()
      M.last = utils.now()
      M.last_today = utils.now()
    end,
  })

  -- Immediate flush on save: accumulate elapsed and write
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    callback = function()
      M.update_root_time(M.file)
      M.write_time_for_today(M.dates_file)
    end,
  })

  -- On exit, accumulate any remaining time
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      M.update_root_time(M.file)
      M.write_time_for_today(M.dates_file)
    end,
  })

  vim.notify('TimeTracker initialized in: ' .. root, vim.log.levels.INFO)
end

-- Show total time spent
function M.show()
  if not M.file then
    vim.notify('TimeTracker: Run :InitTimeTracker first!', vim.log.levels.WARN)
    return
  end
  local total = M.read_time(M.file)
  vim.notify('Total time spent: ' .. utils.format_time(total), vim.log.levels.INFO)
end

function M.plot()
  local lines = utils.tail_lines(M.dates_file, 30)

  local labels = {}
  local values = {}

  for _, l in ipairs(lines) do
    local first, second = l:match '(%S+)%s+(%S+)'
    table.insert(labels, first)
    table.insert(values, second)
  end

  -- Draw the graph centered in the editor
  local totalTimeSpent = utils.format_time(M.read_time(M.file))
  graph.draw_bar_graph(labels, values, {
    width = 100,
    border = { style = 'rounded', text = { top = ' Time Spent (seconds) / Total: ' .. totalTimeSpent .. ' ' } },
    position = '50%',
  })
end

-- Auto-init if tracker file already exists
local root = M.get_project_root()
local existing = root .. '/.nvim_time_tracker.txt'
if vim.loop.fs_stat(existing) then
  M.init()
end

-- User commands
vim.api.nvim_create_user_command('TimeTrackerInit', M.init, { desc = 'Initialize project time tracker' })
vim.api.nvim_create_user_command('TimeTrackerShow', M.show, { desc = 'Show total time spent in project' })
vim.api.nvim_create_user_command('TimeTrackerPlot', M.plot, { desc = 'Plots' })

return M
