local setup_rust_dap = function()
  local ok, mason_registry = pcall(require, "mason-registry")
  local adapter
  print "i was here"
  if ok then
    -- rust tools configuration for debugging support
    local codelldb = mason_registry.get_package "codelldb"
    local extension_path = codelldb:get_install_path() .. "/extension/"
    local codelldb_path = extension_path .. "adapter/codelldb"
    local liblldb_path = ""
    if vim.loop.os_uname().sysname:find "Windows" then
      liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
    elseif vim.fn.has "mac" == 1 then
      liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
    else
      liblldb_path = extension_path .. "lldb/lib/liblldb.so"
    end
    adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path)
  end
  print(vim.inspect(adapter))
  return adapter
end
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "Hoffs/omnisharp-extended-lsp.nvim",
    },
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  --
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "rust",
      },
    },
  },
  --{
  --  "simrat39/rust-tools.nvim",
  --  lazy = false,
  --},
  {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
      },
      { "nvim-tree/nvim-web-devicons" },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "gbrlsnchs/telescope-lsp-handlers.nvim" },
      { "jonarrien/telescope-cmdline.nvim" },
      { "paopaol/telescope-git-diffs.nvim" },
    },
    opts = function()
      local conf = require "nvchad.configs.telescope"
      conf.extensions["ui-select"] = {
        require("telescope.themes").get_dropdown(),
      }
      conf.extensions["fzf"] = {
        fuzzy = true,
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"ver
      }
      conf.extensions["lsp_handler"] = {}
      conf.extensions["dap"] = {}
      conf.extensions["cmdline"] = {}
      conf.extensions["git_diffs"] = {}
    end,
  },

  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup {}
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    lazy = false,

    dependencies = {
      "PasiBergman/cmp-nuget",
    },
    config = function()
      local conf = require "nvchad.configs.cmp"
      local nuget_cmp = require "cmp-nuget"
      nuget_cmp.setup {}
      table.insert(conf.sources, 1, { name = "nuget" })
      require("cmp").setup(conf)
    end,
  },
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("flutter-tools").setup {
        fvm = true,
        debugger = {
          enabled = true,
          run_via_dap = true,
        },
      }
      require("telescope").load_extension "flutter"
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "nvim-telescope/telescope-dap.nvim",
    },
    lazy = false,
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      require("mason-nvim-dap").setup {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_setup = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
        },

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {},
      }
      dapui.setup {
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don't feel like these are good choices.
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
        controls = {
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
      }
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open {}
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close {}
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close {}
      end
    end,
  },

  {
    "folke/neodev.nvim",
    lazy = false,
    config = function()
      require("neodev").setup {
        library = {
          plugins = { "nvim-dap-ui", "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
          types = true,
        },
      }
    end,
  },
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      src = {
        cmp = { enabled = true },
      },
    },
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = false },
    keys = {},
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {},
  },
  {
    "sindrets/diffview.nvim",
    opts = {},
  },
}
