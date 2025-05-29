return {
  "Vigemus/iron.nvim",
  config = function()
    local iron = require("iron.core")
    local common = require("iron.fts.common")
    local view = require("iron.view")
    iron.setup({
      config = {
        scratch_repl = true,
        highlight = false,
        repl_definition = {
          sh = {
            command = { "zsh" },
          },
          python = {
            command = { "ipython" },
            format = common.bracketed_paste,
            block_dividers = { "# %%", "#%%" },
          },
          r = {
            command = { "radian" },
            format = common.bracketed_paste,
            block_dividers = { "# %%", "#%%" },
          },
          rmd = { command = { "radian" } },
          quarto = { command = { "radian" } },
        },
        repl_filetype = function(bufnr, ft)
          return ft
        end,
        repl_open_cmd = view.split.vertical.rightbelow(100)
      },
      keymaps = {
        toggle_repl = "<leader>rr", -- toggles the repl open and closed.
        -- If repl_open_command is a table as above, then the following keymaps are
        -- available
        -- toggle_repl_with_cmd_1 = "<leader>rv",
        -- toggle_repl_with_cmd_2 = "<leader>rh",
        restart_repl = "<leader>rR", -- calls `IronRestart` to restart the repl
        send_motion = "<leader>sc",
        visual_send = "<leader>sc",
        send_file = "<leader>sf",
        send_line = "<leader>sl",
        send_paragraph = "<leader>sp",
        send_until_cursor = "<leader>su",
        send_mark = "<leader>sm",
        send_code_block = "<leader>sb",
        send_code_block_and_move = "<leader>sn",
        mark_motion = "<leader>mc",
        mark_visual = "<leader>mc",
        remove_mark = "<leader>md",
        cr = "<leader>s<cr>",
        interrupt = "<leader>s<space>",
        exit = "<leader>sq",
        clear = "<leader>cl",
      },
      ignore_blank_lines = true,
    })
  end
}
