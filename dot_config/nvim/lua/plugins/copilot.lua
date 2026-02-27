return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  cmd = "Copilot",
  config = function()
    require("copilot").setup({
      filetypes = {
        quarto = false,
        tex = false,
        typst = false,
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<M-;>",
        },
      }
    })
  end
}
