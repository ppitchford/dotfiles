-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

require("options")
require("lazy").setup("plugins")

-- Auto-open today's journal on startup if no file arguments provided
if vim.fn.argc() == 0 then
  vim.schedule(function()
    local id    = os.date("%Y%m%d000000")
    local today = os.date("%Y-%m-%d")
    local file  = vim.fn.expand("~/Documents/zettelkasten/journal/") .. id .. ".md"
    if vim.fn.filereadable(file) == 0 then
      local template = vim.fn.readfile(
        vim.fn.expand("~/Documents/zettelkasten/templates/daily.md")
      )
      local lines = {}
      for _, line in ipairs(template) do
        line = line:gsub("{{id}}", id):gsub("{{date}}", today)
        table.insert(lines, line)
      end
      vim.fn.writefile(lines, file)
    end
    vim.cmd("edit " .. file)
  end)
end
