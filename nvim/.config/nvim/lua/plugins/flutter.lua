-- Flutter: run/hot reload/devices/debug via flutter-tools. It starts its own
-- dartls with the project's FVM SDK, so LazyVim's dartls is turned off.
return {
  {
    "neovim/nvim-lspconfig",
    opts = { servers = { dartls = { enabled = false } } },
  },
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
    opts = {
      fvm = true, -- use .fvm/flutter_sdk when the project has one
      ui = { border = "rounded" },
      decorations = { statusline = { app_version = true, device = true } },
      debugger = { enabled = true },
      dev_log = { enabled = true, open_cmd = "botright 15split" },
      widget_guides = { enabled = true },
      closing_tags = { enabled = true, prefix = "// " },
      lsp = {
        color = { enabled = true },
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          renameFilesWithClasses = "prompt",
          updateImportsOnRename = true,
        },
      },
    },
    keys = {
      { "<leader>F", "", desc = "+flutter", ft = "dart" },
      { "<leader>Fr", "<cmd>FlutterRun<cr>", desc = "Run", ft = "dart" },
      { "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Devices", ft = "dart" },
      { "<leader>Fe", "<cmd>FlutterEmulators<cr>", desc = "Emulators", ft = "dart" },
      { "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Hot restart", ft = "dart" },
      { "<leader>Fh", "<cmd>FlutterReload<cr>", desc = "Hot reload", ft = "dart" },
      { "<leader>Fq", "<cmd>FlutterQuit<cr>", desc = "Quit app", ft = "dart" },
      { "<leader>Fl", "<cmd>FlutterLogToggle<cr>", desc = "Toggle log", ft = "dart" },
      { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Widget outline", ft = "dart" },
      { "<leader>Fp", "<cmd>FlutterPubGet<cr>", desc = "pub get", ft = "dart" },
      { "<leader>Ft", "<cmd>FlutterDevTools<cr>", desc = "DevTools", ft = "dart" },
    },
  },
}
