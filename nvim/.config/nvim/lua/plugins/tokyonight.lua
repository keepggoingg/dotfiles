-- tokyonight, recoloured live by `looks` (bin/.local/bin/looks).
-- looks writes ~/.local/state/looks/state.json with the Ghostty theme's colours; for any theme other
-- than "Tokyo Night Deep" (our default) those colours replace tokyonight's, and the four bundled
-- TokyoNight themes map to tokyonight's own styles. The file is watched, so open nvims follow along.
local state_dir = vim.fn.expand("~/.local/state/looks")
local state_file = state_dir .. "/state.json"
local native = { ["TokyoNight Night"] = "night", ["TokyoNight Storm"] = "storm", ["TokyoNight Moon"] = "moon", ["TokyoNight Day"] = "day" }

local function read_state()
  local f = io.open(state_file, "r")
  if not f then return nil end
  local ok, s = pcall(vim.json.decode, f:read("*a"))
  f:close()
  return ok and type(s) == "table" and s or nil
end

local base = {} -- LazyVim's own tokyonight opts (style = "moon"), kept for re-applies

local function opts(_, lazy_opts)
  if lazy_opts then base = lazy_opts end
  local s = read_state()
  local o = vim.tbl_deep_extend("force", vim.deepcopy(base), {
    transparent = true,
    cache = false, -- colours change at runtime
    styles = { sidebars = "transparent", floats = "transparent" },
  })
  local r = s and s.roles
  if not s or s.native or not r then
    vim.o.background = "dark"
    return o
  end
  vim.o.background = r.light and "light" or "dark"
  if native[s.theme] then
    o.style = native[s.theme]
    return o
  end
  o.style = r.light and "day" or "night"
  o.on_colors = function(c)
    c.bg, c.bg_dark, c.bg_float, c.bg_sidebar, c.bg_popup, c.bg_statusline = r.bg, r.bg, r.bg, r.bg, r.bg, r.bg
    c.bg_highlight, c.bg_visual, c.bg_search = r.surface, r.sel, r.sel
    c.fg, c.fg_dark, c.fg_float, c.fg_sidebar = r.fg, r.p7, r.fg, r.p7
    c.comment, c.dark5, c.dark3, c.fg_gutter, c.terminal_black, c.border = r.muted, r.muted, r.p8, r.p8, r.p8, r.p8
    c.black = r.p0
    c.red, c.red1 = r.p1, r.p9
    c.green, c.green1, c.green2, c.teal = r.p2, r.p10, r.p6, r.p6
    c.yellow, c.orange = r.p3, r.p11
    c.blue, c.blue0, c.blue1, c.blue2, c.blue5, c.blue6, c.blue7 = r.p4, r.sel, r.p6, r.p6, r.p14, r.p14, r.surface
    c.magenta, c.magenta2, c.purple = r.p5, r.p13, r.p13
    c.cyan = r.p6
  end
  return o
end

-- Re-apply when looks rewrites the state file (written atomically, so watch the directory).
local function watch()
  vim.fn.mkdir(state_dir, "p")
  local timer = vim.uv.new_timer()
  local ev = vim.uv.new_fs_event()
  ev:start(state_dir, {}, function(_, name)
    if name ~= "state.json" then return end
    timer:stop()
    timer:start(80, 0, vim.schedule_wrap(function()
      if vim.g.colors_name and vim.g.colors_name:find("^tokyonight") then
        require("tokyonight").setup(opts())
        vim.cmd.colorscheme("tokyonight")
      end
    end))
  end)
end

return {
  "folke/tokyonight.nvim",
  opts = opts,
  init = watch,
}
