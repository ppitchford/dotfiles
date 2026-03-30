-- ── Theme switching ───────────────────────────────────────────────────────────
-- Reads ~/.config/theme/current (written by theme-switch daemon) to determine
-- whether to use Rosé Pine Main (dark) or Rosé Pine Dawn (light).
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

-- Apply the appropriate Rosé Pine variant
local function apply_theme(variant)
    local ok, rosepine = pcall(require, "rose-pine")
    if not ok then return end
    rosepine.setup({ variant = variant == "light" and "dawn" or "main" })
    vim.cmd("colorscheme rose-pine")
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
