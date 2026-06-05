-- Restrict a snippet to buffers under a given directory
local function in_dir(dir)
	dir = vim.fs.normalize(vim.fn.expand(dir))
	return function()
		return vim.startswith(vim.api.nvim_buf_get_name(0), dir .. "/")
	end
end

local in_mfpa_notes = in_dir("~/Dropbox/courses/mfpa/notes")

return {
	s("block", {
		t("::: {"),
		i(1),
		t({ "}", "" }),
		i(0),
		t({ "", ":::" }),
	}),
	s("block4", {
		t(":::: {"),
		i(1),
		t({ "}", "" }),
		i(0),
		t({ "", "::::" }),
	}),
	-- python code block
	s("pb", {
		t({ "```{python}", "" }),
		i(0),
		t({ "", "```" }),
	}),
	-- R code block
	s({ trig = "rb", dscr = "R code chunk" }, {
		t({ "```{r}", "" }),
		i(0),
		t({ "", "```" }),
	}),
	-- aligned equation
	s("al", {
		t({ "$$", "" }),
		t({ "\\begin{aligned}[]", "" }),
		i(0),
		t({ "", "\\end{aligned}", "" }),
		t({ "$$" }),
	}),
	-- two-column layout
	s({ trig = "col", dscr = "Two-column layout" }, {
		t({ "::: {.columns}", ":::: {.column}", "" }),
		i(1),
		t({ "", "::::", ":::: {.column}", "" }),
		i(2),
		t({ "", "::::", ":::" }),
	}),
	-- exercise with answer block (mfpa notes only)
	s(
		{ trig = "exr", dscr = "Exercise with answer block" },
		fmta(
			[[
			::: {#exr-<> name="<>"}
			<>

			:::: {.answer}
			::::
			:::
			]],
			{
				i(1, "label"),
				i(2, "Name"),
				i(0),
			}
		),
		{
			condition = in_mfpa_notes,
			show_condition = in_mfpa_notes,
		}
	),
	-- in-class exercise
	s("ice", {
		t({ '::: {.callout-note title="In-class exercise"}', "" }),
		i(0),
		t({ "", "", "```{r}", "#", "# [Write your answer here]", "#", "```", ":::", "" }),
	}),
}
