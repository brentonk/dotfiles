return {
  s("block", {
    t("::: {"),
    i(1),
    t({"}", ""}),
    i(0),
    t({"", ":::"}),
  }),
  s("block4", {
    t(":::: {"),
    i(1),
    t({"}", ""}),
    i(0),
    t({"", "::::"}),
  }),
  -- python code block
  s("pb", {
    t({"```{python}", ""}),
    i(0),
    t({"", "```"}),
  }),
  -- aligned equation
  s("al", {
    t({"$$", ""}),
    t({"\\begin{aligned}", ""}),
    i(0),
    t({"", "\\end{aligned}", ""}),
    t({"$$"}),
  }),
}
