-- Spell checking
vim.opt.spelllang = "en_us"
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- Auto-save on focus lost and when leaving insert mode
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost" }, {
  pattern = "*.md",
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" then
      vim.cmd("silent! write")
    end
  end,
})

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr  = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false
