require "nvchad.mappings" -- add yours here

local map = vim.keymap.set

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }

    map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "<leader>fs", require("telescope.builtin").lsp_dynamic_workspace_symbols, opts)
    map("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, opts)
  end,
})
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
