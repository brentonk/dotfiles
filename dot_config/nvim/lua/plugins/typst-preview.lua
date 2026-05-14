local function open_cmd()
  if vim.uv.os_uname().sysname == "Darwin" then
    return "'/Applications/Brave Browser.app/Contents/MacOS/Brave Browser' --app=%s 2>/dev/null &"
  end
  return "brave --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=auto --app=%s 2>/dev/null"
end

return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = {
    open_cmd = open_cmd(),
  },
}
