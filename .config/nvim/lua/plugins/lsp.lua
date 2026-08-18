-- ── LSP ───────────────────────────────────────────────────────────────────────
-- Servers are installed system-wide, never by mason. pyright, gopls,
-- lua-language-server and rust_analyzer come from xbps; html, cssls and jsonls
-- come from one npm global install of vscode-langservers-extracted. mason kept
-- a private 576MB tree and installed vscode-langservers-extracted three times
-- over, once per server name.
--
-- JavaScript and TypeScript go through tsgo rather than ts_ls. The typescript
-- 7.x package ships a native Go binary that serves LSP directly -- `tsc --lsp
-- --stdio` answers initialize with full completion capabilities -- so it
-- replaces both typescript-language-server and the tsserver.js that only
-- typescript 5.x still shipped. That avoids pinning typescript to 5.x purely
-- to keep a wrapper working.
--
-- nvim-lspconfig is kept only for the server definitions that vim.lsp.config
-- reads out of its lsp/ directory; it does no setup() work here.
return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local servers = {
        "pyright", "gopls", "html", "cssls",
        "jsonls", "lua_ls", "rust_analyzer",
      }
      for _, server in ipairs(servers) do
        vim.lsp.config(server, {})
        vim.lsp.enable(server)
      end

      -- The upstream tsgo config expects a binary named `tsgo`; the typescript
      -- package publishes the same executable as `tsc`. Everything else in that
      -- config -- filetypes, monorepo-aware root_dir, inlay hints -- still applies.
      vim.lsp.config("tsgo", { cmd = { "tsc", "--lsp", "--stdio" } })
      vim.lsp.enable("tsgo")

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- Native completion, built into 0.11+. This replaces nvim-cmp and
          -- its five companion plugins entirely.
          if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, {
              autotrigger = true,
            })
          end

          -- Inline inferred types, scoped to rust_analyzer so the other
          -- servers keep their current behaviour.
          if client and client.name == "rust_analyzer" then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })
    end,
  },
}
