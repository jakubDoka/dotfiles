vim.g.have_nerd_font = false
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.belloff = {}
vim.opt.breakindent = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.errorbells = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.inccommand = 'split'
vim.opt.listchars = { eol = 'ඞ', tab = '▸ ', trail = '·', extends = '❯', precedes = '❮' }
vim.opt.list = true
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 0
vim.opt.shiftwidth = 4
vim.opt.showmode = false
vim.opt.signcolumn = 'yes'
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.updatetime = 250

for _, key in ipairs { '<Up>', '<Down>', '<Left>', '<Right>', '<PageUp>', '<PageDown>' } do
  vim.keymap.set({ 'i', 'n', 'v', 'c' }, key, '<Nop>', { noremap = true, silent = true })
end

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>tr', '<cmd>set relativenumber!<CR>', { desc = '[T]oggle [R]elative number' })

vim.keymap.set('c', '<M-h>', '<Left>', { desc = 'Move left' })
vim.keymap.set('c', '<M-j>', '<Down>', { desc = 'Move down' })
vim.keymap.set('c', '<M-k>', '<Up>', { desc = 'Move up' })
vim.keymap.set('c', '<M-l>', '<Right>', { desc = 'Move right' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

local function lmap(seq, fn, desc)
  vim.keymap.set('n', '<leader>' .. seq, fn, { desc = desc })
end

local function amap(seq, fn, desc)
  vim.keymap.set('n', '<M-' .. seq .. '>', fn, { desc = desc })
end

require('lazy').setup({
  {
    'ThePrimeagen/harpoon',
    config = function()
      amap('m', require('harpoon.mark').add_file, '[M]mark with harpoon')
      amap('q', require('harpoon.ui').toggle_quick_menu, '[H]arpoon [T]oggle [M]enu')
      amap('n', require('harpoon.ui').nav_next, '[H]arpoon [G]o to [N]ext mark')
      amap('p', require('harpoon.ui').nav_next, '[H]arpoon [G]o to [N]ext mark')

      for i = 0, 9 do
        local key = (i + 1) % 10
        amap(tostring(key), function()
          require('harpoon.ui').nav_file(key)
        end, '[H]arpoon [G]o to mark ' .. key)
      end
    end,
  },

  {
    'supermaven-inc/supermaven-nvim',
    opts = {
      keymaps = {
        accept_suggestion = '<Tab>',
        clear_suggestion = '<C-]>',
        accept_word = '<C-j>',
      },
      ignore_filetypes = { markdown = true },
      color = {
        suggestion_color = '#ffffff',
        cterm = 244,
      },
      disable_inline_completion = true, -- disables inline completion for use with cmp
      disable_keymaps = true, -- disables built in keymaps for more manual control
    },
  },

  'tpope/vim-sleuth',

  { 'numToStr/Comment.nvim', opts = {} },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      require('which-key').setup()

      require('which-key').register {
        ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
        ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
      }
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',

        build = 'make',

        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local ts = require 'telescope'
      local builtin = require 'telescope.builtin'

      ts.setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(ts.load_extension, 'fzf')
      pcall(ts.load_extension, 'ui-select')

      lmap('sh', builtin.help_tags, '[S]earch [H]elp')
      lmap('sk', builtin.keymaps, '[S]earch [K]eymaps')
      lmap('sf', builtin.find_files, '[S]earch [F]iles')
      lmap('ss', builtin.builtin, '[S]earch [S]elect Telescope')
      lmap('sw', builtin.grep_string, '[S]earch current [W]ord')
      lmap('sg', builtin.live_grep, '[S]earch by [G]rep')
      lmap('sd', builtin.diagnostics, '[S]earch [D]iagnostics')
      lmap('sr', builtin.resume, '[S]earch [R]esume')
      lmap('s.', builtin.oldfiles, '[S]earch Recent Files ("." for repeat)')
      lmap('<leader>', builtin.buffers, '[ ] Find existing buffers')
      lmap('/', builtin.current_buffer_fuzzy_find, '[/] Fuzzily search in current buffer')
      lmap('s/', builtin.live_grep, '[S]earch [/] in Open Files')
      lmap('sn', builtin.find_files, '[S]earch [N]eovim files')
    end,
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local tb = require 'telescope.builtin'
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', tb.lsp_definitions, '[G]oto [D]efinition')
          map('gr', tb.lsp_references, '[G]oto [R]eferences')
          map('gI', tb.lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', tb.lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', tb.lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', tb.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>ws', tb.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>lr', tb.lsp_references, '[L]ist [R]eferences')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        cssls = {
          capabilities = {
            textDocument = {
              completion = {
                completionItem = {
                  snippetSupport = true,
                },
              },
            },
          },
        },
        html = {
          capabilities = {
            textDocument = {
              completion = {
                completionItem = {
                  snippetSupport = true,
                },
              },
            },
          },
        },
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = {
                command = 'clippy',
              },
              imports = {
                granularity = {
                  group = 'module',
                },
                prefix = 'self',
              },
              cargo = {
                buildScripts = {
                  enable = true,
                },
              },
              procMacro = {
                enable = true,
              },
            },
          },
        },
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { 'stylua' })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  {
    'stevearc/conform.nvim',
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
      },
    },
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {},
      },
      'saadparwaiz1/cmp_luasnip',

      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          ['<C-j>'] = cmp.mapping.confirm { select = true },

          ['<C-Space>'] = cmp.mapping.complete {},

          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'supermaven' },
        },
      }
    end,
  },

  -- mark: theme
  {
    'olimorris/onedarkpro.nvim',
    priority = 1000,
    opts = {
      options = {
        transparency = true,
      },
    },
    init = function()
      local is_dark = false

      local function toggleTheme()
        if is_dark then
          vim.cmd [[colorscheme onelight | hi Normal guibg=white | hi NonText guibg=white]]
        else
          vim.cmd [[colorscheme onedark | hi Normal guibg=none | hi NonText guibg=none]]
        end

        is_dark = not is_dark
      end

      vim.keymap.set('n', 'tt', toggleTheme, { desc = '[T]oggle [T]heme' })

      toggleTheme()
    end,
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'c', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'rust' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<M-k>',
          node_incremental = '<M-k>',
          scope_incremental = '<M-s>',
          node_decremental = '<M-j>',
        },
      },
    },
    config = function(_, opts)
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
