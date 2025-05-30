return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "lukas-reineke/cmp-rg",
    "micangl/cmp-vimtex",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      completion = {
        autocomplete = false
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      sources = cmp.config.sources({
        { name = "vimtex" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "rg" },
        { name = "path" },
      }, {
        { name = "buffer" }
      }),
      mapping = {
        ['<C-p>']     = cmp.mapping.select_prev_item(),
        ['<C-n>']     = cmp.mapping.select_next_item(),
        ['<S-Tab>']   = cmp.mapping.select_prev_item(),
        ['<Tab>']     = cmp.mapping.select_next_item(),
        ['<C-S-f>']   = cmp.mapping.scroll_docs(-4),
        ['<C-f>']     = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>']     = cmp.mapping.close(),
        ['<C-m>']     = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select   = true,
        }),
        ['<CR>']      = cmp.mapping.confirm({select = false}),
      },
      experimental = {
        ghost_text = false,
      },
    })
  end,
}
