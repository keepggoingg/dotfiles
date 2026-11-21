-- VS Code-style mouse support.
--   right-click        context menu (LSP, git, debug, clipboard; file actions in the explorer)
--   ctrl/alt + click   go to definition
--   hover              docs / diagnostics popup after a short pause
--   gutter clicks      line number: breakpoint, git sign: preview change,
--                      diagnostic sign: show error
--   explorer           single click opens; the 󰙅 Explorer button bottom-left toggles it
--   tabs               click to switch, x or middle-click to close
--   status line        click branch: lazygit, diagnostics: problems list
--   Cmd shortcuts      Cmd+S/P/Shift+P/Shift+F/'/'/Z/Shift+Z/A/B/W, forwarded by
--                      Ghostty -> tmux (see tmux.conf "Cmd keys for nvim")

vim.o.mouse = "a"
vim.o.mousemodel = "popup_setpos" -- right-click moves the cursor there first, then opens the menu
vim.o.mousemoveevent = true -- needed for hover popups and tab hover
vim.o.mousescroll = "ver:1,hor:2"

-- File explorer (snacks): open if closed, close if open
function _G.vscode_toggle_explorer()
  local open = Snacks.picker.get({ source = "explorer" })[1]
  if open then
    open:close()
  else
    Snacks.explorer({ cwd = LazyVim.root() })
  end
end

-- ---- Cmd keys --------------------------------------------------------------
local function map(modes, lhs, rhs, desc, remap)
  vim.keymap.set(modes, lhs, rhs, { desc = desc, remap = remap, silent = true })
end
local nvi = { "n", "v", "i" }
map(nvi, "<D-s>", "<Cmd>w<CR><Esc>", "Save")
map(nvi, "<D-p>", function() Snacks.picker.files() end, "Find file")
map(nvi, "<D-S-p>", function() Snacks.picker.commands() end, "Command palette")
map(nvi, "<D-S-f>", function() Snacks.picker.grep() end, "Search in files")
map("n", "<D-/>", "gcc", "Toggle comment", true)
map("v", "<D-/>", "gc", "Toggle comment", true)
map("i", "<D-/>", "<Esc>gcca", "Toggle comment", true)
map({ "n", "v" }, "<D-z>", "<Cmd>undo<CR>", "Undo")
map("i", "<D-z>", "<C-o>u", "Undo")
map({ "n", "v" }, "<D-S-z>", "<Cmd>redo<CR>", "Redo")
map("i", "<D-S-z>", "<C-o><C-r>", "Redo")
map(nvi, "<D-a>", "<Esc>ggVG", "Select all")
map(nvi, "<D-b>", function() _G.vscode_toggle_explorer() end, "Toggle file explorer")
map(nvi, "<D-w>", function() Snacks.bufdelete() end, "Close tab")

-- ---- Ctrl/Alt + click: go to definition -------------------------------------
-- (Cmd+click can't reach a terminal app: mouse reports carry only shift/alt/ctrl.)
for _, lhs in ipairs({ "<C-LeftMouse>", "<M-LeftMouse>" }) do
  map({ "n", "i" }, lhs, "<LeftMouse><Cmd>lua vim.lsp.buf.definition()<CR>", "Go to definition")
end

-- ---- Right-click menu -------------------------------------------------------
local function has_lsp()
  return #vim.lsp.get_clients({ bufnr = 0 }) > 0
end

local function build_menu()
  vim.cmd("silent! aunmenu PopUp")
  local function item(modes, label, rhs)
    label = label:gsub(" ", [[\ ]]):gsub("%.", [[\.]])
    for _, m in ipairs(modes) do
      vim.cmd(("%smenu PopUp.%s %s"):format(m, label, rhs))
    end
  end
  local n, v, a = { "n" }, { "v" }, { "n", "v" }
  local sep = 0
  local function separator()
    sep = sep + 1
    vim.cmd(("anoremenu PopUp.-sep%d- <Nop>"):format(sep))
  end

  if vim.bo.filetype == "snacks_picker_list" then
    -- the explorer's own keys (buffer-local, so these menus remap: nmenu, not nnoremenu)
    item(n, "Open", "<CR>")
    item(n, "Open to the Side", "<C-v>")
    separator()
    item(n, "New File or Folder (end with /)", "a")
    item(n, "Rename", "r")
    item(n, "Copy", "c")
    item(n, "Move", "m")
    item(n, "Delete", "d")
    separator()
    item(n, "Copy Path", "y")
    item(n, "Open with Default App", "o")
    item(n, "Show or Hide Hidden Files", "H")
    item(n, "Refresh", "u")
    item(n, "Collapse All", "Z")
    return
  end

  item(n, "Toggle File Explorer", "<Cmd>lua _G.vscode_toggle_explorer()<CR>")
  separator()
  if has_lsp() then
    item(n, "Go to Definition", "<Cmd>lua vim.lsp.buf.definition()<CR>")
    item(n, "Go to References", "<Cmd>lua Snacks.picker.lsp_references()<CR>")
    item(n, "Go to Implementation", "<Cmd>lua Snacks.picker.lsp_implementations()<CR>")
    item(n, "Show Docs", "<Cmd>lua vim.lsp.buf.hover()<CR>")
    separator()
    item(n, "Rename Symbol", "<Cmd>lua vim.lsp.buf.rename()<CR>")
    item(a, "Code Action / Quick Fix", "<Cmd>lua vim.lsp.buf.code_action()<CR>")
    item(a, "Format", "<Cmd>lua LazyVim.format({ force = true })<CR>")
    separator()
  end
  if #vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 }) > 0 then
    item(n, "Show Problem", "<Cmd>lua vim.diagnostic.open_float()<CR>")
    separator()
  end
  item(v, "Cut", '"+x')
  item(v, "Copy", '"+y')
  item(n, "Paste", '"+gP')
  item(v, "Paste", '"+P')
  item(n, "Select All", "ggVG")
  separator()
  vim.cmd([[nmenu PopUp.Toggle\ Comment gcc]])
  vim.cmd([[vmenu PopUp.Toggle\ Comment gc]])
  if vim.b.gitsigns_head or vim.b.gitsigns_status_dict then
    separator()
    item(n, "Git: Preview Change", "<Cmd>Gitsigns preview_hunk<CR>")
    item(n, "Git: Revert Change", "<Cmd>Gitsigns reset_hunk<CR>")
    item(n, "Git: Blame Line", "<Cmd>Gitsigns blame_line<CR>")
  end
  if package.loaded["dap"] or pcall(require, "dap") then
    separator()
    item(n, "Toggle Breakpoint", "<Cmd>lua require('dap').toggle_breakpoint()<CR>")
  end
end

vim.api.nvim_create_autocmd("MenuPopup", {
  group = vim.api.nvim_create_augroup("vscode_mouse_menu", { clear = true }),
  callback = build_menu,
})

return {
  -- Hover popups (docs, diagnostics) under the mouse
  {
    "lewis6991/hover.nvim",
    event = "VeryLazy",
    config = function()
      local hover = require("hover")
      hover.config({
        providers = {
          "hover.providers.diagnostic",
          "hover.providers.lsp",
          "hover.providers.dap",
        },
        preview_opts = { border = "rounded" },
        preview_window = false,
        title = false,
        mouse_providers = { "hover.providers.diagnostic", "hover.providers.lsp" },
        mouse_delay = 600,
      })
      vim.keymap.set("n", "<MouseMove>", hover.mouse, { desc = "Hover under mouse" })
    end,
  },

  -- Clickable gutter
  {
    "luukvbaal/statuscol.nvim",
    event = "VeryLazy",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,
        ft_ignore = { "snacks_picker_list", "snacks_picker_input", "snacks_layout_box", "help", "lazy", "mason", "trouble", "Trouble", "dapui_scopes", "dapui_watches", "dapui_stacks", "dapui_breakpoints", "dapui_console", "dap-repl" },
        bt_ignore = { "terminal", "nofile", "prompt" },
        segments = {
          { sign = { namespace = { "diagnostic" }, maxwidth = 1, colwidth = 2, auto = false }, click = "v:lua.ScSa" },
          { sign = { name = { "Dap.*" }, maxwidth = 1, colwidth = 2, auto = true }, click = "v:lua.ScSa" },
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
          { sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1, auto = false, wrap = true }, click = "v:lua.ScSa" },
        },
      })
    end,
  },
  { "folke/snacks.nvim", opts = { statuscolumn = { enabled = false } } },

  -- Tabs: hover shows the close button, middle-click closes, right-click just switches
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.always_show_bufferline = true
      opts.options.show_buffer_close_icons = true
      opts.options.hover = { enabled = true, delay = 120, reveal = { "close" } }
      opts.options.right_mouse_command = "buffer %d"
      opts.options.middle_mouse_command = function(n) Snacks.bufdelete(n) end
    end,
  },

  -- Status line: 󰙅 Explorer button toggles the file explorer,
  -- click the branch for lazygit, diagnostics for the problems list
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_b = {
        {
          function() return "󰙅 Explorer" end,
          on_click = function() _G.vscode_toggle_explorer() end,
          color = { fg = "#7aa2f7", gui = "bold" },
        },
        { "branch", on_click = function() Snacks.lazygit() end },
      }
      opts.sections.lualine_z = {} -- no clock: the tmux status bar already shows it
      for _, c in ipairs(opts.sections.lualine_c) do
        if type(c) == "table" and c[1] == "diagnostics" then
          c.on_click = function() vim.cmd("Trouble diagnostics toggle") end
        end
      end
    end,
  },

  -- File explorer (snacks): single click opens a file or expands a folder, like VS Code
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            win = { list = { keys = { ["<LeftRelease>"] = "confirm" } } },
          },
        },
      },
    },
  },
}
