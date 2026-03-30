-- ── UI ────────────────────────────────────────────────────────────────────────

return {
    -- Rosé Pine colorscheme — dark (Main) and light (Dawn) variants
    -- Theme switching is handled by lua/theme.lua via file watcher
    {
        "rose-pine/neovim",
        name     = "rose-pine",
        priority = 1000,  -- Load before other plugins
        opts = {
            variant      = "main",  -- Default; overridden by theme.lua on startup
            dark_variant = "main",
            styles = {
                bold          = true,
                italic        = true,
                transparency  = false,
            },
        },
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                theme            = "rose-pine",
                section_separators   = "",
                component_separators = "",
                globalstatus     = true,
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },

    -- Show pending keybinds
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts  = {},
    },
    -- File icons used by telescope, which-key, and other plugins
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },
}
