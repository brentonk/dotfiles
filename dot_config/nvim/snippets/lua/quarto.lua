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
	-- in-class exercise
	s("ice", {
		t({ '::: {.callout-note title="In-class exercise"}', "" }),
		i(0),
		t({ "", "", "```{r}", "#", "# [Write your answer here]", "#", "```", ":::", "" }),
	}),
}
