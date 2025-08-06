local Popup = require 'nui.popup'

local M = {}

--- Generate ASCII bar chart lines.
-- @param labels table of string labels
-- @param values table of number values
-- @param max_width number: maximum bar width in characters
-- @return table of strings, each representing one line of the chart
local function make_bar_lines(labels, values, max_width)
  -- Find maximum value for scaling
  local max_val = math.max(unpack(values))
  local lines = {}

  for i, label in ipairs(labels) do
    local val = values[i] or 0
    -- Scale bar length proportionally
    local bar_len = max_val > 0 and math.floor((val / max_val) * max_width) or 0
    -- Build bar string
    local bar = string.rep('█', bar_len)
    -- Format: label padded, bar, and numeric value
    lines[i] = string.format('%-10s │%s %.2f', label, bar, val)
  end

  return lines
end
--- Draw a bar graph in a floating popup.
-- @param labels table: list of strings
-- @param values table: list of numbers
-- @param opts table: { width, height, border, position }
function M.draw_bar_graph(labels, values, opts)
  -- Default options
  opts = vim.tbl_deep_extend('force', {
    width = 50,
    height = #labels + 2,
    border = { style = 'rounded', text = { top = ' Bar Chart ' }, padding = { top = 1, right = 1, left = 1 } },
    position = '50%',
  }, opts or {})

  -- Generate chart lines
  local lines = make_bar_lines(labels, values, opts.width - 25)

  -- Create popup
  local popup = Popup {
    enter = true,
    focusable = true,
    position = opts.position,
    size = { width = opts.width, height = opts.height },
    border = opts.border,
  }
  popup:mount() -- attach buffer and window

  -- Fill buffer with chart lines
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)

  -- Close on <Esc> or <q>
  popup:map('n', 'q', function()
    popup:unmount()
  end, { noremap = true, silent = true })
  popup:map('n', '<Esc>', function()
    popup:unmount()
  end, { noremap = true, silent = true })
end

return M
