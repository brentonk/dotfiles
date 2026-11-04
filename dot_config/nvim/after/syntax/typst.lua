-- Extra math conceals on top of kaarmu/typst.vim's built-in symbol table
-- (see lua/plugins/typst-vim.lua). That table is script-local, so custom
-- macros are added here instead.
--
-- Why this is needed: typst.vim matches symbol names with no word
-- boundaries, so a macro like `eqq` gets its leading `eq` concealed as `=`
-- (showing `=q`). A whole-word rule defined here, after the plugin's syntax
-- file, takes priority because Vim prefers the last-defined match when two
-- start at the same position.
--
-- Add entries as { name, concealed char }. Matches `name` or `#name`.
if vim.g.typst_conceal_math ~= 1 then
  return
end

local symbols = {
  { "eqq", "⇔" }, -- quad <=> quad
}

for _, s in ipairs(symbols) do
  vim.cmd(
    ("syntax match typstMathSymbol '#\\?\\<%s\\>' contained conceal cchar=%s"):format(s[1], s[2])
  )
end
