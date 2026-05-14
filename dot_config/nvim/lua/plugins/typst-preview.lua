return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = function()
    -- On Ubuntu, `brave` in PATH is a wrapper that drops args; use the real
    -- binary directly when present. On Arch, `brave` is the real binary.
    local browser = vim.fn.executable("brave-browser") == 1 and "brave-browser" or "brave"
    return {
      open_cmd = browser
        .. " --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=auto --app=%s 2>/dev/null",
    }
  end,
}
