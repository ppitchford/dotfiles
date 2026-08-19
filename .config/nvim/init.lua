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

-- Required before lazy.setup: theme.lua registers a `User LazyDone` autocmd,
-- and lazy fires that event from within setup(). Requiring it afterwards
-- would register the autocmd too late for it to ever run.
require("theme")

require("lazy").setup("plugins")
