require "nvchad.mappings" -- add yours here
local dap = require "dap"

local map = vim.keymap.set

vim.lsp.commands["rust-analyzer.runSingle"] = function(command)
  print(vim.inspect(command))
  local handle, pid = vim.uv.spawn("cargo", {
    args = command.args,
    cwd = command.workspaceRoot,
    detached = true,
  }, function(code, signal)
    print("exit code", code)
    print("exit signal", signal)
  end)
  vim.uv.unref(handle)
end

vim.lsp.commands["rust-analyzer.debugSingle"] = function(command)
  print(vim.inspect(command))
  vim.uv.spawn("cargo", {
    args = command.args,
    cwd = command.workspaceRoot,
  }, function(code, signal)
    print("exit code", code)
    print("exit signal", signal)
  end)
end

vim.lsp.commands["rust-analyzer.showReferences"] = function(command)
  vim.lsp.buf.implementation()
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }

    map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
    map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    map("n", "gd", vim.lsp.buf.definition, { desc = "Go to declaration" })
    map("n", "gD", vim.lsp.buf.type_definition, { desc = "Go to definition" })
    map({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "<leader>fs", require("telescope.builtin").lsp_dynamic_workspace_symbols, opts)
    map("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, opts)
    map("n", "<leader>cr", vim.lsp.codelens.run, { desc = "Run CodeLense" })
    map("n", "<leader>cl", function()
      vim.lsp.codelens.refresh {
        bufnr = ev.buf,
      }
      local available = vim.lsp.codelens.get(ev.buf)
      if available == nil or next(available) == nil then
        return
      end
      vim.lsp.codelens.display(available, ev.data.client_id, ev.buf)
    end, { desc = "Show CodeLense" })
  end,
})
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map("n", "<leader>tx", "<cmd>TroubleToggle document_diagnostics<cr>", { desc = "Document Diagnostics (Trouble)" })
map("n", "<leader>tX", "<cmd>TroubleToggle workspace_diagnostics<cr>", { desc = "Workspace Diagnostics (Trouble))" })
map("n", "<leader>tL", "<cmd>TroubleToggle loclist<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>tQ", "<cmd>TroubleToggle quickfix<cr>", { desc = "Quickfix List (Trouble)" })

map("n", "[q", function()
  if require("trouble").is_open() then
    require("trouble").previous { skip_groups = true, jump = true }
  else
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = "Previous trouble/quickfix item" })

map("n", "]q", function()
  if require("trouble").is_open() then
    require("trouble").next { skip_groups = true, jump = true }
  else
    local ok, err = pcall(vim.cmd.cnext)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = "Next trouble/quickfix item" })
vim.keymap.set("n", "<F5>", function()
  -- (Re-)reads launch.json if present
  --[[ if vim.fn.filereadable ".vscode/launch.json" then
          require("dap.ext.vscode").load_launchjs(nil)
        end ]]
  dap.continue()
end, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>B", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })

map({ "n", "v" }, ":", "<cmd>Telescope cmdline<cr>", { desc = "Cmdline" })
