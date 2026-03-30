-- ── Treesitter ────────────────────────────────────────────────────────────────

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvim-treesitter").setup({
                ensure_installed = {
                    "bash", "css", "go", "html", "javascript",
                    "json", "lua", "markdown", "markdown_inline",
                    "python", "sql", "toml", "typescript", "yaml",
                },
                highlight    = { enable = true },
                indent       = { enable = true },
                auto_install = true,
            })
        end,
    },
}
