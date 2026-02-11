return {
	s(
		{ trig = "res", dscr = "Restatable environment" },
		fmta(
			[[
          \begin{restatable}{<>}{res<>}
            \label{res:<>}
            <>
          \end{restatable}
          ]],
			{
				i(1, "environment"),
				i(2, "CommandName"),
				f(function(args)
					-- ChatGPT-written function for CamelCase -> kebab-case
					return args
						[1]
						[1]
						:gsub("(%l)(%u)", "%1-%2") -- fooBar → foo-Bar
						:gsub("(%u)(%u%l)", "%1-%2") -- HTMLParser → HTML-Parser
						:lower()
				end, { 2 }),
				i(0),
			}
		)
	),
	s(
		{ trig = "eq", dscr = "Equation environment" },
		fmta(
			[[
          \begin{equation}
            \label{eq:<>}
            <>
          \end{equation}
        ]],
			{
				i(1, "label"),
				i(0),
			}
		)
	),
	s({ trig = "mel", dscr = "MoveEqLeft" }, {
		t("\\MoveEqLeft{}"),
		i(0),
	}),
	-- Migrated from JSON snippets
	s({ trig = "al", dscr = "align* environment" }, {
		t({ "\\begin{align*}", "\t" }),
		i(1),
		t({ "", "\\end{align*}" }),
	}),
	s({ trig = "prob", dscr = "problem environment" }, {
		t({ "\\begin{problem}", "\t" }),
		i(1),
		t({ "", "\\end{problem}" }),
	}),
	s({ trig = "proof", dscr = "proof environment" }, {
		t({ "\\begin{proof}", "\t" }),
		i(0),
		t({ "", "\\end{proof}" }),
	}),
	s({ trig = "sum", dscr = "summation" }, {
		t("\\sum_{"),
		i(1),
		t("}^{"),
		i(2),
		t("} "),
		i(0),
	}),
	s({ trig = "int", dscr = "integral" }, {
		t("\\int_{"),
		i(1),
		t("}^{"),
		i(2),
		t("} "),
		i(0),
	}),
	s({ trig = "bigcup", dscr = "big union" }, {
		t("\\bigcup_{"),
		i(1),
		t("}^{"),
		i(2),
		t("} "),
		i(0),
	}),
	s({ trig = "bigcap", dscr = "big intersection" }, {
		t("\\bigcap_{"),
		i(1),
		t("}^{"),
		i(2),
		t("} "),
		i(0),
	}),
	s({ trig = "frac", dscr = "fraction" }, {
		t("\\frac{"),
		i(1),
		t("}{"),
		i(2),
		t("}"),
	}),
	s({ trig = "BEN", dscr = "enumerate environment" }, {
		t({ "\\begin{enumerate}", "\t\\item " }),
		i(0),
		t({ "", "\\end{enumerate}" }),
	}),
	s({ trig = "BIT", dscr = "itemize environment" }, {
		t({ "\\begin{itemize}", "\t\\item " }),
		i(0),
		t({ "", "\\end{itemize}" }),
	}),
	s({ trig = "begin", dscr = "generic environment" }, {
		t("\\begin{"),
		i(1),
		t({ "}", "\t" }),
		i(0),
		t({ "", "\\end{" }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t("}"),
	}),
}
