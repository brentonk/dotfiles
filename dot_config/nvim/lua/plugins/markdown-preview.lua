local function open_cmd(url)
  if vim.uv.os_uname().sysname == "Darwin" then
    return { "/Applications/Chromium.app/Contents/MacOS/Chromium", "--app=" .. url }
  end
  return {
    "chromium",
    "--enable-features=UseOzonePlatform,WaylandWindowDecorations",
    "--ozone-platform-hint=auto",
    "--app=" .. url,
  }
end

function _G.MarkdownPreviewOpenApp(url)
  vim.fn.jobstart(open_cmd(url), { detach = true })
end

return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = "cd app && npx --yes yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_browserfunc = "MarkdownPreviewOpenBrowser"
    vim.cmd([[
      function! MarkdownPreviewOpenBrowser(url) abort
        call v:lua.MarkdownPreviewOpenApp(a:url)
      endfunction
    ]])
  end,
}
