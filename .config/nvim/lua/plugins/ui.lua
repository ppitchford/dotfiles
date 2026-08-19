-- ── UI ────────────────────────────────────────────────────────────────────────

return {
    -- Tokyo Night colorscheme — dark (Night) and light (Day) styles.
    -- Deliberately no opts here: lua/theme.lua owns the setup() call, because
    -- the pure-black background must be applied to the dark style only and
    -- that module is the one place that knows which variant is active.
    {
        "folke/tokyonight.nvim",
        name     = "tokyonight",
        priority = 1000,  -- Load before other plugins
        lazy     = false,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                theme            = "auto",
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
