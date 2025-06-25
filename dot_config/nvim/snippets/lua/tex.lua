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
}
