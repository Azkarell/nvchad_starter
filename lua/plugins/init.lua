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
    },
    opts = function()
      local conf = require "nvchad.configs.telescope"
      conf.extensions["ui-select"] = {
        require("telescope.themes").get_cursor(),
      }
    end,
  },

  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup {}
      vim.keymap.set("n", "<leader>dvo", "<Cmd>DiffviewOpen<Enter>", {
        desc = "Open Diffview",
      })
      vim.keymap.set("n", "<leader>dvc", "<Cmd>DiffviewClose<Enter>", {
        desc = "Close Diffview",
      })
    end,
  },
  { "rmagatti/auto-session", config = true, lazy = false },
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
}
