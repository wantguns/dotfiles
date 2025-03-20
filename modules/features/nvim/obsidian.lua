local Path = require("plenary.path")

-- Function to check if a directory exists
local function directory_exists(path)
  local dir = Path:new(path)
  return dir:is_dir()
end

-- Path to the workspace directory
local workspace_path = vim.fn.expand("~/Documents/warehouse")

if directory_exists(workspace_path) then
  -- If directory exists, setup the workspace
  require("obsidian").setup({
    workspaces = {
      {
        name = "warehouse",
        path = workspace_path,
      },
    },

    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = "notes/dailies",
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = "%Y-%m-%d",
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = "%B %-d, %Y",
      -- Optional, default tags to add to each new daily note created.
      default_tags = { "daily-notes" },
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = nil
    },
  })
end
