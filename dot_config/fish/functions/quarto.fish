function quarto --wraps quarto --description 'quarto; preview opens in a bare chromium app window'
    # `quarto preview` ignores $BROWSER on Linux and hardcodes `xdg-open` to
    # launch the preview URL. For the preview subcommand, prepend a shim dir to
    # PATH so quarto's `xdg-open` resolves to our chromium --app launcher
    # (mirrors the typst-preview.nvim setup). `set -lx` is block-scoped in fish,
    # so `command quarto` must run INSIDE this block to inherit the modified PATH.
    if test (count $argv) -gt 0; and test "$argv[1]" = preview
        set -lx PATH $__fish_config_dir/quarto-app-browser $PATH
        command quarto $argv
    else
        command quarto $argv
    end
end
