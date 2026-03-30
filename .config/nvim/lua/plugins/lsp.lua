-- LSP configuration
-- Note: zk LSP is managed by zk-nvim (plugins/zk.lua), not here.
return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright", "gopls", "html", "cssls",
          "ts_ls", "jsonls", "sqlls", "harper_ls", "lua_ls",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      -- Disabled — zk LSP handles markdown, marksman is not installed
      vim.lsp.enable("marksman", false)

      local servers = {
        "pyright", "gopls", "html", "cssls",
        "ts_ls", "jsonls", "sqlls", "harper_ls", "lua_ls",
      }
      for _, server in ipairs(servers) do
        vim.lsp.config(server, {})
        vim.lsp.enable(server)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, {
              autotrigger = true,
            })
          end
        end,
      })
    end,
  },
}
