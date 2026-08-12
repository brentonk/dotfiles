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

    -- Use the system R + user library `languageserver` package directly.
    -- Mason's vendored r-languageserver bundles precompiled .so files that
    -- break (undefined symbol: SETLENGTH) when the system R is upgraded.
    vim.lsp.config("r_language_server", {
      cmd = { "R", "--no-echo", "-e", "languageserver::run()" },
    })
    vim.lsp.enable("r_language_server")

    -- Prefer the project venv's ruff (matches `uv run ruff check` and the
    -- conform formatters) over mason's, which shadows it via PATH prepending
    vim.lsp.config("ruff", {
      cmd = function(dispatchers, config)
        local ruff = "ruff"
        local candidates = {}
        if vim.env.VIRTUAL_ENV then
          table.insert(candidates, vim.env.VIRTUAL_ENV .. "/bin/ruff")
        end
        local root = config.root_dir or vim.fn.getcwd()
        for _, dir in ipairs(vim.fs.find(".venv", { upward = true, path = root, type = "directory" })) do
          table.insert(candidates, dir .. "/bin/ruff")
        end
        for _, candidate in ipairs(candidates) do
          if vim.fn.executable(candidate) == 1 then
            ruff = candidate
            break
          end
        end
        return vim.lsp.rpc.start({ ruff, "server" }, dispatchers)
      end,
    })
  end
}
