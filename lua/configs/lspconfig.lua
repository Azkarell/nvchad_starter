-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local masonlspconfig = require "mason-lspconfig"
local on_attach_wrapper = function(client, bufnr)
  vim.lsp.inlay_hint.enable(bufnr, true)
  on_attach(client, bufnr)
end
masonlspconfig.setup {}
masonlspconfig.setup_handlers {
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name) -- default handler (optional)
    require("lspconfig")[server_name].setup {
      on_attach = on_attach_wrapper,
      capabilities = capabilities,
      on_init = on_init,
    }
  end,
  -- Next, you can provide a dedicated handler for specific servers.
  -- For example, a handler override for the `rust_analyzer`:
  ["omnisharp"] = function()
    lspconfig.omnisharp.setup {
      on_init = on_init,
      on_attach = on_attach,
      capabilities = capabilities,
      enable_roslyn_analyzers = true,
      enable_import_completion = true,
      handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").definition_handler,
        ["textDocument/typeDefinition"] = require("omnisharp_extended").type_definition_handler,
        ["textDocument/references"] = require("omnisharp_extended").references_handler,
        ["textDocument/implementation"] = require("omnisharp_extended").implementation_handler,
      },
    }
  end,
  ["rust_analyzer"] = function()
    lspconfig["rust_analyzer"].setup {
      on_attach = on_attach_wrapper,
      capabilities = capabilities,
      on_init = on_init,
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
      },
      diagnostics = {
        enable = true,
      },
      inlayHints = {
        bindingModeHints = {
          enable = true,
        },
        closureCaptureHints = {
          enable = true,
        },
        closureReturnTypeHints = {
          enable = true,
        },
      },
    }
  end,
}

--
-- -- typescript
-- lspconfig.tsserver.setup {
--   on_attach = on_attach,
--   on_init = on_init,
--   capabilities = capabilities,
-- }
