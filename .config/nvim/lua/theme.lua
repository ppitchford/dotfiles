-- ── Theme switching ───────────────────────────────────────────────────────────
-- Reads ~/.config/theme/current (written by ornatus) to determine
-- whether to use Tokyo Night (dark) or Tokyo Night Day (light).
-- A file watcher detects changes and switches the colorscheme live.

local theme_file = vim.fn.expand("~/.config/theme/current")

-- Read the current theme from the theme file
local function read_theme()
    local f = io.open(theme_file, "r")
    if not f then return "dark" end
    local content = f:read("*l") or "dark"
    f:close()
    return content:match("^%s*(.-)%s*$")  -- trim whitespace
end

-- Sanctum palette — github.com/jdanielmourao/obsidian-sanctum
-- Sanctum ships no Neovim port, so tokyonight is kept purely as the highlight
-- engine and its colour slots are overwritten with Sanctum's. Every highlight
-- group tokyonight defines then resolves to a Sanctum colour.
local sanctum = {
    dark = {  -- sanctum-black
        bg = "#000000", layer1 = "#161616", layer2 = "#3a3838",
        fg = "#c7c5c2", fg_dim = "#8e8c8b", faint = "#3a3838",
        border = "#262625", border_strong = "#545151",
        accent = "#669961", focus = "#3f758f",
        red = "#c54128", green = "#669961", yellow = "#f3bd4f",
        blue = "#53709f", purple = "#a577da", cyan = "#63959c",
        orange = "#f68d45", pink = "#ce2f5b",
    },
    light = {  -- sanctum-default-light
        bg = "#f4f4f0", layer1 = "#fdfefe", layer2 = "#e2e0dc",
        fg = "#161616", fg_dim = "#545151", faint = "#a9a8a5",
        border = "#e2e0dc", border_strong = "#8e8c8b",
        accent = "#f68d45", focus = "#3f758f",
        red = "#9c2327", green = "#1d5e38", yellow = "#986400",
        blue = "#325384", purple = "#702fac", cyan = "#205677",
        orange = "#f68d45", pink = "#ce2f5b",
    },
}

-- Apply the Sanctum palette for the given variant.
local function apply_theme(variant)
    local ok, tokyonight = pcall(require, "tokyonight")
    if not ok then return end

    local dark = variant ~= "light"
    local s    = dark and sanctum.dark or sanctum.light

    tokyonight.setup({
        style       = "night",
        light_style = "day",
        styles      = { bold = true, italic = true },
        on_colors   = function(c)
            c.bg            = s.bg
            c.bg_dark       = s.bg
            c.bg_float      = s.layer1
            c.bg_popup      = s.layer1
            c.bg_sidebar    = s.bg
            c.bg_statusline = s.layer1
            c.bg_highlight  = s.layer2
            c.bg_visual     = s.layer2
            c.bg_search     = s.layer2
            c.fg            = s.fg
            c.fg_dark       = s.fg_dim
            c.fg_float      = s.fg
            c.fg_sidebar    = s.fg_dim
            c.fg_gutter     = s.faint
            c.comment       = s.fg_dim
            c.border        = s.border
            c.border_highlight = s.border_strong
            c.terminal_black   = s.border

            c.red, c.green, c.yellow = s.red, s.green, s.yellow
            c.blue, c.purple, c.cyan = s.blue, s.purple, s.cyan
            c.magenta, c.orange, c.teal = s.pink, s.orange, s.cyan
            c.red1, c.green1, c.green2 = s.red, s.green, s.green
            c.blue0, c.blue1, c.blue2  = s.focus, s.cyan, s.blue
            c.blue5, c.blue6, c.blue7  = s.cyan, s.cyan, s.border
            c.magenta2 = s.pink
            c.error, c.warning = s.red, s.yellow
            c.info, c.hint     = s.focus, s.cyan
        end,
    })

    vim.o.background = dark and "dark" or "light"
    vim.cmd("colorscheme tokyonight")
end

-- Apply theme and start file watcher after all plugins have loaded
vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once    = true,
    callback = function()
        -- Apply correct theme on startup
        apply_theme(read_theme())

        -- Watch for changes to the theme file and switch live
        local watcher = vim.uv.new_fs_event()
        if watcher then
            watcher:start(theme_file, {}, function()
                vim.schedule(function()
                    apply_theme(read_theme())
                end)
            end)
        end
    end,
})
