-- Merge request review.
--   diffview.nvim: side-by-side diff of a branch against its target, file history.
--   gitlab.nvim:   GitLab MR summary, discussions, line comments, approve, pipeline.
-- gitlab.nvim takes the token from glab (`glab auth login` once per GitLab host),
-- so no token lives in this repo or in a .gitlab.nvim file.

-- Host of the current repo's origin remote, e.g. git.example.com.
local function origin_host()
  local url = vim.trim(vim.fn.system({ "git", "remote", "get-url", "origin" }))
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return url:match("^git@([^:]+):") or url:match("^ssh://[^@]+@([^:/]+)") or url:match("^https?://([^/]+)/")
end

-- Diff the current branch against the MR target (origin/development, else origin/HEAD).
local function diff_against_target()
  local base = "origin/development"
  vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", base })
  if vim.v.shell_error ~= 0 then
    base = "origin/HEAD"
  end
  vim.cmd("DiffviewOpen " .. base .. "...HEAD")
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = {
      enhanced_diff_hl = true,
      view = { merge_tool = { layout = "diff3_mixed" } },
    },
    keys = {
      { "<leader>gv", diff_against_target, desc = "Diffview: branch vs target" },
      { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
      { "<leader>gH", ":DiffviewFileHistory<cr>", mode = "v", desc = "Diffview: selection history" },
    },
  },

  {
    "harrisoncramer/gitlab.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    build = function()
      require("gitlab.server").build(true)
    end,
    opts = {
      auth_provider = function()
        local host = origin_host()
        if not host then
          return nil, nil, "gitlab.nvim: no origin remote in this repo"
        end
        local token = vim.trim(vim.fn.system({ "glab", "config", "get", "token", "--host", host }))
        if vim.v.shell_error ~= 0 or token == "" then
          return nil,
            nil,
            "gitlab.nvim: no glab token for " .. host .. " (run `glab auth login --hostname " .. host .. "`)"
        end
        return token, "https://" .. host, nil
      end,
    },
    keys = {
      { "<leader>m", "", desc = "+merge request" },
      {
        "<leader>mm",
        function()
          require("gitlab").choose_merge_request()
        end,
        desc = "Choose MR (checks out branch)",
      },
      {
        "<leader>mr",
        function()
          require("gitlab").review()
        end,
        desc = "Review diff",
      },
      {
        "<leader>ms",
        function()
          require("gitlab").summary()
        end,
        desc = "Summary / description",
      },
      {
        "<leader>md",
        function()
          require("gitlab").toggle_discussions()
        end,
        desc = "Discussions",
      },
      {
        "<leader>mA",
        function()
          require("gitlab").approve()
        end,
        desc = "Approve",
      },
      {
        "<leader>mR",
        function()
          require("gitlab").revoke()
        end,
        desc = "Revoke approval",
      },
      {
        "<leader>mp",
        function()
          require("gitlab").pipeline()
        end,
        desc = "Pipeline",
      },
      {
        "<leader>mn",
        function()
          require("gitlab").create_note()
        end,
        desc = "General comment",
      },
      {
        "<leader>mc",
        function()
          require("gitlab").create_comment()
        end,
        desc = "Comment on line",
      },
      {
        "<leader>mc",
        function()
          require("gitlab").create_multiline_comment()
        end,
        mode = "v",
        desc = "Comment on lines",
      },
      {
        "<leader>mS",
        function()
          require("gitlab").create_comment_suggestion()
        end,
        mode = "v",
        desc = "Suggest change",
      },
      {
        "<leader>mo",
        function()
          require("gitlab").open_in_browser()
        end,
        desc = "Open in browser",
      },
      {
        "<leader>mC",
        function()
          require("gitlab").create_mr()
        end,
        desc = "Create MR",
      },
    },
  },
}
