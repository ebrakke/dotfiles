-- ##############################################
-- # Init
-- ##############################################

vim.opt.shell = "/bin/zsh"
vim.g.mapleader = " "

-- Set compatibility to Vim only (not needed in Neovim)
-- Set autowrite
vim.opt.autowrite = true

-- For plug-ins to load correctly
vim.cmd("syntax on")
vim.cmd("filetype plugin on")
vim.cmd("filetype plugin indent on")

-- Bootstrap lazy.nvim (modern plugin manager for Neovim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ##############################################
-- # Plugins
-- ##############################################

require("lazy").setup({
  -- Color Schemes
  { "junegunn/seoul256.vim" },
  { "connorholyday/vim-snazzy" },
  { "franbach/miramare" },
  { "chriskempson/base16-vim" },

  -- GUI enhancements
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Fuzzy finder
  { "airblade/vim-rooter" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- LSP and completion
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- Syntactic language support
  { "andys8/vim-elm-syntax", ft = "elm" },
  { "dag/vim-fish" },
  { "neovimhaskell/haskell-vim" },
  { "pbrisbin/vim-syntax-shakespeare" },
  { "yuezk/vim-js" },
  { "godlygeek/tabular" },
  { "plasticboy/vim-markdown" },
  { "reasonml-editor/vim-reason-plus" },
  { "rust-lang/rust.vim" },
  { "leafgarland/typescript-vim" },
  { "maxmellon/vim-jsx-pretty" },
  { "fatih/vim-go", build = ":GoUpdateBinaries" },
  { "hashivim/vim-terraform" },

  -- Tools
  { "TimUntersberger/neogit", dependencies = { "nvim-lua/plenary.nvim" } },
  { "numToStr/Comment.nvim" },
  { "akinsho/toggleterm.nvim" },
  { "wincent/terminus" },
  { "vimwiki/vimwiki" },

  -- File explorer
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
})

-- ##############################################
-- # Colors
-- ##############################################

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd("colorscheme base16-default-dark")

-- Key mappings for color scheme switching
vim.keymap.set("n", "<Leader>c", ":colorscheme base16-gruvbox-light-hard<CR>")
vim.keymap.set("n", "<Leader>d", ":colorscheme base16-default-dark<CR>")

-- ##############################################
-- # Telescope (FZF replacement)
-- ##############################################

local telescope = require("telescope")
telescope.setup({
  defaults = {
    file_ignore_patterns = { "node_modules", ".git" },
  },
})
telescope.load_extension("fzf")

-- Key mappings
vim.keymap.set("n", "<C-p>", "<cmd>Telescope git_files<CR>")
vim.keymap.set("n", "<Leader>b", "<cmd>Telescope buffers<CR>")
vim.keymap.set("n", "<Leader>h", "<cmd>Telescope oldfiles<CR>")
vim.keymap.set("n", "<Leader>f", "<cmd>Telescope live_grep<CR>")

-- ##############################################
-- # LSP Configuration
-- ##############################################

local lspconfig = require("lspconfig")
local cmp = require("cmp")
local luasnip = require("luasnip")

-- CMP setup
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
  }),
})

-- LSP settings
local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }
  
  -- Key mappings
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>s", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>p", function() vim.lsp.buf.format({ async = true }) end, opts)
  vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]g", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<space>a", vim.diagnostic.setloclist, opts)
end

-- Setup language servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- TypeScript/JavaScript
lspconfig.ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Go
lspconfig.gopls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Rust
lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Python (if available)
lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Lua
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

-- ##############################################
-- # Lualine (Lightline replacement)
-- ##############################################

require("lualine").setup({
  options = {
    theme = "auto",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

-- ##############################################
-- # ToggleTerm (Floaterm replacement)
-- ##############################################

require("toggleterm").setup({
  size = 20,
  open_mapping = [[<Leader>j]],
  hide_numbers = true,
  shade_terminals = true,
  direction = "float",
  float_opts = {
    border = "curved",
  },
})

-- Additional terminal mappings
vim.keymap.set("n", "<Leader>J", "<cmd>ToggleTerm direction=horizontal<CR>")

-- ##############################################
-- # Comment.nvim (NERDCommenter replacement)
-- ##############################################

require("Comment").setup()

-- ##############################################
-- # NvimTree (File explorer)
-- ##############################################

require("nvim-tree").setup({
  view = {
    width = 30,
    side = "left",
  },
})

vim.keymap.set("n", "<space>e", "<cmd>NvimTreeToggle<CR>")

-- ##############################################
-- # VimWiki
-- ##############################################

vim.g.vimwiki_list = {
  {
    path = "~/Documents/vimwiki/",
    syntax = "markdown",
    ext = ".md",
  },
}

-- ##############################################
-- # Editor Settings
-- ##############################################

vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.cmdheight = 1

-- Permanent undo
vim.opt.undodir = vim.fn.expand("~/.config/nvim/undodir")
vim.opt.undofile = true

-- Decent wildmenu
vim.opt.wildmenu = true
vim.opt.wildmode = "list:longest"
vim.opt.wildignore = ".git,.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor"

-- Folding
vim.opt.foldmethod = "syntax"
vim.opt.foldcolumn = "1"
vim.opt.foldlevelstart = 99

-- Text wrapping
vim.opt.wrap = true

-- Paste mode toggle
vim.keymap.set("n", "<F2>", ":set invpaste paste?<CR>")
vim.keymap.set("i", "<F2>", "<C-O>:set invpaste paste?<CR>")

-- Indentation
vim.opt.formatoptions = "tcqrn1"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftround = false

-- Scrolling
vim.opt.scrolloff = 5

-- Backspace behavior
vim.opt.backspace = "indent,eol,start"

-- Don't add newline at end of files
vim.opt.fixendofline = false

-- Speed up scrolling
vim.opt.ttyfast = true

-- Status bar
vim.opt.laststatus = 2

-- Bracket matching
vim.opt.matchpairs:append("<:>")

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Encoding
vim.opt.encoding = "utf-8"

-- Search settings
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Buffer navigation
vim.keymap.set("n", "<leader><leader>", "<c-^>")

-- Markdown settings
vim.g.vimwiki_global_ext = 0
vim.g.vim_markdown_new_list_item_indent = 0
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_frontmatter = 1

-- Leader commands
vim.keymap.set("n", "<leader>w", ":w<cr>")
vim.keymap.set("n", "<leader>x", ":x<cr>")
vim.keymap.set("n", "<leader>q", ":q<cr>")
vim.keymap.set("i", "jk", "<esc>")

-- ##############################################
-- # Autocommands
-- ##############################################

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Comment highlighting for JSON
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "json",
  command = "syntax match Comment +\\/\\/.*$+",
})

-- File type detection
vim.api.nvim_create_autocmd({ "BufRead" }, {
  group = augroup,
  pattern = "*.md",
  command = "set filetype=markdown",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup,
  pattern = { "*.tsx", "*.jsx" },
  command = "set filetype=typescript.tsx",
})

-- LSP diagnostics configuration
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- ##############################################
-- # Footer
-- ##############################################