return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = {
    open_cmd = "brave --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=auto --app=%s",
  },
}
