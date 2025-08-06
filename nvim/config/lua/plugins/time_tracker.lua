return {
  {
    dir = '~/.config/nvim/time_tracker',
    lazy = false,
    config = function()
      require 'time_tracker'
    end,
  },
}
