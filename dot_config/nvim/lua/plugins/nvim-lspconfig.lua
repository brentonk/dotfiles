return {
  "neovim/nvim-lspconfig",
  config = function()
    -- Workaround for pyright returning annotated text edits that Neovim's
    -- apply_workspace_edit doesn't handle correctly (missing change_annotations assert)
    vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR)
        return
      end
      if not result then
        vim.notify("Nothing to rename", vim.log.levels.WARN)
        return
      end
      -- Strip annotationId to avoid "change_annotations must be provided" assertion
      if result.documentChanges then
        for _, change in ipairs(result.documentChanges) do
          if change.edits then
            for _, edit in ipairs(change.edits) do
              edit.annotationId = nil
            end
          end
        end
      end
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local encoding = client and client.offset_encoding or "utf-8"
      vim.lsp.util.apply_workspace_edit(result, encoding)
      local changed_files = vim.tbl_count(result.documentChanges or result.changes or {})
      vim.notify(("Renamed in %d file(s)"):format(changed_files), vim.log.levels.INFO)
    end


    -- Lua LSP configuration using new vim.lsp.config specification
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = {
            globals = {
              "vim",
              -- LuaSnip injected globals
              "s",
              "t",
              "i",
              "f",
              "fmt",
              "fmta",
            },
          }
        }
      }
    })

    -- Enable the Lua language server
    vim.lsp.enable("lua_ls")
  end
}
