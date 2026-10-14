-- ==============================================================================
--  init.lua - Minimalist Nordic Charcoal Neovim Configuration
--  Maintained by: Shaan
-- ==============================================================================

local opt = vim.opt
local g = vim.g

-- Leader Key
g.mapleader = " "
g.maplocalleader = " "

-- --- UI & Typography ---
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

-- --- Tabs & Indentation ---
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

-- --- Search ---
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- --- Behavior & Performance ---
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.updatetime = 250
opt.timeoutlen = 300
opt.swapfile = false
opt.backup = false
opt.undofile = true

-- --- Netrw File Explorer ---
g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_browse_split = 0
g.netrw_winsize = 25

-- --- Nordic Charcoal Syntax & Colors (Zero-Dependency) ---
local function apply_nordic_colors()
    local set = vim.api.nvim_set_hl
    set(0, "Normal", { fg = "#cdd6f4", bg = "#11111b" })
    set(0, "NormalFloat", { fg = "#cdd6f4", bg = "#181825" })
    set(0, "FloatBorder", { fg = "#89dceb", bg = "#181825" })
    set(0, "CursorLine", { bg = "#181825" })
    set(0, "CursorLineNr", { fg = "#89dceb", bold = true })
    set(0, "LineNr", { fg = "#45475a" })
    set(0, "SignColumn", { bg = "#11111b" })
    set(0, "VertSplit", { fg = "#313244", bg = "#11111b" })
    set(0, "StatusLine", { fg = "#cdd6f4", bg = "#181825" })
    set(0, "StatusLineNC", { fg = "#6c7086", bg = "#11111b" })
    set(0, "Visual", { bg = "#313244" })
    set(0, "Search", { fg = "#11111b", bg = "#89dceb" })
    set(0, "IncSearch", { fg = "#11111b", bg = "#f9e2af" })

    -- Syntax
    set(0, "Comment", { fg = "#6c7086", italic = true })
    set(0, "Constant", { fg = "#f9e2af" })
    set(0, "String", { fg = "#a6e3a1" })
    set(0, "Character", { fg = "#a6e3a1" })
    set(0, "Number", { fg = "#fab387" })
    set(0, "Boolean", { fg = "#fab387" })
    set(0, "Identifier", { fg = "#cdd6f4" })
    set(0, "Function", { fg = "#89dceb", bold = true })
    set(0, "Statement", { fg = "#cba6f7" })
    set(0, "Keyword", { fg = "#cba6f7", bold = true })
    set(0, "PreProc", { fg = "#89b4fa" })
    set(0, "Type", { fg = "#89b4fa" })
    set(0, "Special", { fg = "#89dceb" })
    set(0, "Error", { fg = "#f38ba8" })
    set(0, "Todo", { fg = "#11111b", bg = "#89dceb", bold = true })
end
apply_nordic_colors()

-- --- Minimalist Statusline ---
local modes = {
    ["n"] = "NORMAL", ["i"] = "INSERT", ["v"] = "VISUAL", ["V"] = "V-LINE",
    ["\22"] = "V-BLOCK", ["c"] = "COMMAND", ["R"] = "REPLACE", ["t"] = "TERMINAL"
}
function _G.statusline()
    local mode = modes[vim.api.nvim_get_mode().mode] or "NORMAL"
    local file = vim.fn.expand("%:t")
    if file == "" then file = "[No Name]" end
    local modified = vim.bo.modified and " 󰏫 " or ""
    local readonly = vim.bo.readonly and "  " or ""
    local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "text"
    local line = vim.fn.line(".")
    local col = vim.fn.col(".")
    local total = vim.fn.line("$")
    local pct = math.floor((line / total) * 100)

    return string.format(
        "%%#StatusLine# 󰄛 %s %%#StatusLineNC# │ %s%s%s %%= %%#StatusLine# %s │ 󰌑 %d:%d │ %d%%%% ",
        mode, file, modified, readonly, ft, line, col, pct
    )
end
opt.statusline = "%!v:lua.statusline()"

-- --- Keybindings ---
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save buffer" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit buffer" })
map("n", "<leader>e", "<cmd>Lex 25<CR>", { desc = "Toggle netrw file explorer" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Buffer navigation
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Move lines in Visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
