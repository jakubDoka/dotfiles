table.unpack = table.unpack or unpack

local function curry(f, ...)
  local vargs = { ... }
  return function()
    return f(table.unpack(vargs))
  end
end

do -- options
  vim.g.have_nerd_font = true
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

  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
      vim.highlight.on_yank()
    end,
  })
end

do -- install lazy
  local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
  if not vim.loop.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  end ---@diagnostic disable-next-line: undefined-field
  vim.opt.rtp:prepend(lazypath)
end

local map_presets = {
  mode = 'n',
  prefix = '',
  suffix = '',
}

local function map_cfg(mode, prefix, suffix)
  map_presets.mode = mode
  map_presets.prefix = prefix or ''
  map_presets.suffix = suffix or ''
end

local function map(key, fn, desc)
  vim.keymap.set(map_presets.mode, map_presets.prefix .. key .. map_presets.suffix, fn, { desc = desc })
end

do -- rebinds
  local disabled = { '<Up>', '<Down>', '<Left>', '<Right>', '<PageUp>', '<PageDown>' }

  for _, key in ipairs(disabled) do
    vim.keymap.set({ 'i', 'n', 'v', 'c' }, key, '<Nop>', { noremap = true, silent = true })
  end

  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  map_cfg 'n'
  map('[d', vim.diagnostic.goto_prev, 'Go to previous [D]iagnostic message')
  map(']d', vim.diagnostic.goto_next, 'Go to next [D]iagnostic message')
  map('<leader>tr', '<cmd>set relativenumber!<CR>', '[T]oggle [R]elative number')
  map('<leader>e', vim.diagnostic.open_float, 'Show diagnostic [E]rror messages')

  map_cfg('c', '<M-', '>')
  map('h', '<Left>')
  map('j', '<Down>')
  map('k', '<Up>')
  map('l', '<Right>')

  map_cfg('n', '<M-', '>')
  map('j', '<PageDown>')
  map('k', '<PageUp>')
end

require('lazy').setup({
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'

      harpoon:setup()

      map_cfg('n', '<M-', '>')
      map('m', function()
        harpoon:list():add()
      end, '[M]mark with harpoon')
      map('q', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, '[H]arpoon [T]oggle [M]enu')
      map('n', function()
        harpoon:list():prev()
      end, '[H]arpoon [G]o to [N]ext mark')
      map('p', function()
        harpoon:list():next()
      end, '[H]arpoon [G]o to [N]ext mark')

      for i = 0, 9 do
        local key = (i + 1) % 10
        map(tostring(key), function()
          harpoon:list():select(key)
        end, '[H]arpoon [G]o to mark ' .. key)
      end
    end,
  },

  {
    'mfussenegger/nvim-dap',
    config = function()
      local dap, dwg = require 'dap', require 'dap.ui.widgets'

      map_cfg('n', '<F', '>')
      map('5', dap.continue, '[D]ebug [C]ontinue')
      map('6', dap.step_over, '[D]ebug [N]ext [O]ver')
      map('7', dap.step_into, '[D]ebug [I]n [T]o')
      map('8', dap.step_out, '[D]ebug [O]ut')
      map_cfg('n', '<leader>')
      map('tb', dap.toggle_breakpoint, '[D]ebug [T]oggle [B]reakpoint')
      map('cb', dap.clear_breakpoints, '[D]ebug [C]lear [B]reakpoints')
      map('dr', dap.repl.open, '[D]ebug [R]epl')
      map('dh', dwg.hover, '[D]ebug [H]over')
      map('dp', dwg.preview, '[D]ebug [P]review')
      map('df', curry(dwg.centered_float, dwg.frames), '[D]ebug [F]rames')
      map('ds', curry(dwg.centered_float, dwg.scopes), '[D]ebug [S]copes')
      map('de', curry(dwg.centered_float, dwg.expression), '[D]ebug [E]xpression')
      map('dt', curry(dwg.centered_float, dwg.threads), '[D]ebug [T]hreads')
      map('ds', curry(dwg.centered_float, dwg.sessions), '[D]ebug [S]session')

      -- dap-adapters
      dap.adapters.lldb = {
        type = 'executable',
        command = '/usr/bin/lldb-dap',
        name = 'lldb',
      }

      -- dap-configs
      local lldb = {
        name = 'Launch lldb',
        type = 'lldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
        runInTerminal = true,
      }

      dap.configurations.zig = { lldb }
    end,
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
    config = function()
      local gitsigns = require 'gitsigns'

      -- Navigation
      map_cfg 'n'
      map(']h', function()
        if vim.wo.diff then
          vim.cmd.normal { ']h', bang = true }
        else
          gitsigns.nav_hunk 'next'
        end
      end, 'next hunk')
      map('[h', function()
        if vim.wo.diff then
          vim.cmd.normal { '[h', bang = true }
        else
          gitsigns.nav_hunk 'prev'
        end
      end, 'prev hunk')

      -- Actions
      map_cfg('n', '<leader>h')
      map('s', gitsigns.stage_hunk, '[H]unk [S]tage')
      map('r', gitsigns.reset_hunk, '[H]unk [R]eset')
      map('u', gitsigns.undo_stage_hunk, '[H]unk [U]ndo Stage Hunk')
      map('p', gitsigns.preview_hunk, '[H]unk [P]revie2')
      map('S', gitsigns.stage_buffer, '[H]unk [S]tage Buffer')
      map('R', gitsigns.reset_buffer, '[H]unk [R]eset Buffer')
      map('b', curry(gitsigns.blame_line, { full = true }), '[H]unk [B]lame line')
      map('d', gitsigns.diffthis, '[H]unk [D]iff')
      map('D', curry(gitsigns.diffthis, '~'), '[H]unk [D]iff ~')
      map_cfg('v', '<leader>h')
      map('s', curry(gitsigns.stage_hunk, { vim.fn.line '.', vim.fn.line 'v' }), 'What?')
      map('r', curry(gitsigns.reset_hunk, { vim.fn.line '.', vim.fn.line 'v' }), 'What again?')
      map_cfg('n', '<leader>t')
      map('b', gitsigns.toggle_current_line_blame, '[T]oggle Current Line [B]lame')
      map('d', gitsigns.toggle_deleted, '[T]oggle [D]eleted')

      -- Text object
      --map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      require('which-key').setup()

      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>c_', hidden = true },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>d_', hidden = true },
        { '<leader>r', group = '[R]ename' },
        { '<leader>r_', hidden = true },
        { '<leader>s', group = '[S]earch' },
        { '<leader>s_', hidden = true },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>w_', hidden = true },
      }
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-dap.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
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
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      }

      ts.load_extension 'fzf'
      ts.load_extension 'ui-select'
      ts.load_extension 'dap'

      map_cfg('n', '<leader>')
      map('sf', builtin.find_files, '[S]earch [F]iles')
      map('sg', builtin.live_grep, '[S]earch by [G]rep')
      map('sd', builtin.diagnostics, '[S]earch [D]iagnostics')
      map('sr', builtin.resume, '[S]earch [R]esume')
      map('so', builtin.oldfiles, '[S]earch Recent Files ("." for repeat)')
      map('/', builtin.current_buffer_fuzzy_find, '[/] Fuzzily search in current buffer')
      map('lb', ':Telescope dap list_breakpoints<CR>', '[L]ist [B]reakpoints')
    end,
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'https://git.ablecorp.us/kodin/hblang.vim.git',
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local tb = require 'telescope.builtin'
          local lmap = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          lmap('<leader>lr', tb.lsp_references, '[L]ist [R]eferences')
          lmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          lmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          lmap('K', vim.lsp.buf.hover, 'Hover Documentation')
          lmap('gd', tb.lsp_definitions, '[G]oto [D]efinition')
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        bashls = {},
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
        gopls = {},
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
        htmx = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        pyright = {},
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
        stylua = {},
        tailwindcss = {},
        ts_ls = {},
        zls = {},
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
    'L3MON4D3/LuaSnip',
    build = (function()
      if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
        return
      end
      return 'make install_jsregexp'
    end)(),
    config = function()
      local ls = require 'luasnip'

      vim.keymap.set({ 'i' }, '<C-K>', ls.expand)
      vim.keymap.set({ 'i', 's' }, '<C-L>', curry(ls.jump, 1))
      vim.keymap.set({ 'i', 's' }, '<C-J>', curry(ls.jump, -1))
      vim.keymap.set({ 'i', 's' }, '<C-E>', function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end)
    end,
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
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
          ['<tab>'] = cmp.mapping.confirm { select = true },

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
          { name = 'buffer' },
        },
      }
    end,
  },

  { -- mark: theme
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
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      --incremental_selection = {
      --  enable = true,
      --  keymaps = {
      --    --init_selection = '<M-k>',
      --    --node_incremental = '<M-k>',
      --    --scope_incremental = '<M-s>',
      --    --node_decremental = '<M-j>',
      --  },
      --},
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)

      local utils = require 'nvim-treesitter.ts_utils'

      ---@param parent_selector string
      ---@param next boolean
      local function swap_nodes(parent_selector, next)
        local node = utils.get_node_at_cursor()
        if node == nil then
          print 'no node under the cursor'
          return
        end

        while true do
          local next_node = node:parent()
          if next_node == nil then
            print('cannot find ' .. parent_selector)
            return
          end
          if next_node:type() == parent_selector then
            break
          end
          node = next_node
        end

        local next_node = node
        for _ = 1, vim.v.count + 1 do
          local next_n = next and utils.get_next_node(next_node) or (not next and utils.get_previous_node(next_node))
          if not next_n then
            print 'no sibling found'
            return
          end
          next_node = next_n
        end

        utils.swap_nodes(node, next_node, 0, true)
      end

      vim.keymap.set('n', 'tsa', curry(swap_nodes, 'arguments', true), { desc = '[T]reesitter [S]wap [A]rguments' })
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
