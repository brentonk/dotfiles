c = get_config()  # noqa

# Auto-reload modified modules before executing code
c.InteractiveShellApp.extensions = ["autoreload"]
c.InteractiveShellApp.exec_lines = ["%autoreload 2"]
