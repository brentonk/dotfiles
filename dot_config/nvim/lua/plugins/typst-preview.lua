local function open_cmd()
  if vim.uv.os_uname().sysname == "Darwin" then
    return "'/Applications/Chromium.app/Contents/MacOS/Chromium' --app=%s 2>/dev/null &"
  end
  return "chromium --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=auto --app=%s 2>/dev/null"
end

return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = {
    open_cmd = open_cmd(),
  },
}
