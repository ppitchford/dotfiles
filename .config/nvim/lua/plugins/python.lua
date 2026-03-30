-- ── Python ────────────────────────────────────────────────────────────────────
-- venv-selector.nvim detects uv virtual environments and tells pyright
-- which Python interpreter to use per project. No restart required.

return {
    {
        "linux-cultist/venv-selector.nvim",
        ft           = { "python" },
        dependencies = { "neovim/nvim-lspconfig" },
        opts = {
            -- Search for .venv directories created by uv
            search_venv_managers = true,
            auto_refresh         = true,
        },
        keys = {
            { "<leader>pv", "<cmd>VenvSelect<cr>",       desc = "Select Python venv" },
            { "<leader>pc", "<cmd>VenvSelectCached<cr>", desc = "Use cached venv" },
        },
    },
}
