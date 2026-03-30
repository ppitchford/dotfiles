return {
  {
    "zk-org/zk-nvim",
    ft = { "markdown" },
    config = function()
      require("zk").setup({
        picker = "telescope",
        lsp = {
          config = {
            cmd  = { "zk", "lsp" },
            name = "zk",
          },
          auto_attach = {
            enabled   = true,
            filetypes = { "markdown" },
          },
        },
      })

      -- ── Navigation ──────────────────────────────────────────────────────
      vim.keymap.set("n", "<leader>zf", "<cmd>ZkNotes { sort = { 'modified' } }<cr>",
        { desc = "Find notes" })
      vim.keymap.set("n", "<leader>zg", function()
        require("zk.commands").get("ZkNotes")({ match = { vim.fn.input("Search: ") } })
      end, { desc = "Search notes" })
      vim.keymap.set("n", "<leader>zl", "<cmd>ZkLinks<cr>",
        { desc = "Links in note" })
      vim.keymap.set("n", "<leader>zb", "<cmd>ZkBacklinks<cr>",
        { desc = "Backlinks to note" })

      -- ── Insert wikilink ─────────────────────────────────────────────────
      -- Typing [[ in insert mode opens the note picker and inserts [[id]]
      vim.keymap.set("i", "[[", function()
        require("zk.commands").get("ZkInsertLink")()
      end, { desc = "Insert wikilink" })
    end,
  },
}
