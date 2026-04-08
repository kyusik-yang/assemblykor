.onAttach <- function(libname, pkgname) {
  v <- utils::packageVersion("assemblykor")

  title <- paste0("assemblykor ", v)
  subtitle <- "Korean National Assembly Data for Political Science Education"
  width <- max(nchar(title), nchar(subtitle)) + 2

  top    <- paste0("
    \n",
  "
     \n")
  bottom <- paste0("
     \n",
  "
    ")

  pad_line <- function(text) {
    padding <- width - nchar(text)
    paste0(
      "\u2502 ", text, strrep(" ", padding - 1), "\u2502"
    )
  }

  box <- paste0(
    "\n",
    "  \u250c", strrep("\u2500", width), "\u2510\n",
    "  ", pad_line(title), "\n",
    "  ", pad_line(subtitle), "\n",
    "  \u2514", strrep("\u2500", width), "\u2518\n"
  )

  msg <- paste0(
    box,
    "\n",
    "  7 built-in datasets:\n",
    "    legislators    947 recs   MPs (20-22nd)\n",
    "    bills       60,925 recs   Bills proposed\n",
    "    wealth       2,928 recs   Asset declarations\n",
    "    seminars     5,962 recs   Policy seminars\n",
    "    speeches    15,843 recs   Committee speeches (22nd, Sci & ICT)\n",
    "    votes        8,050 recs   Plenary vote tallies\n",
    "    roll_calls 383,739 recs   Member-level votes (22nd)\n",
    "\n",
    "  Downloadable:\n",
    "    get_bill_texts()           Bill propose-reason texts\n",
    "    get_proposers()            Co-sponsorship records\n",
    "\n",
    "  Tutorials:\n",
    "    list_tutorials()           See all 9 tutorials\n",
    "    run_tutorial(1)            Launch in browser (interactive)\n",
    "    open_tutorial(1)           Copy Rmd to working directory\n",
    "\n",
    "  Korean font for ggplot2:     set_ko_font()\n",
    "\n",
    "  https://CRAN.R-project.org/package=assemblykor\n"
  )

  packageStartupMessage(msg)
}
