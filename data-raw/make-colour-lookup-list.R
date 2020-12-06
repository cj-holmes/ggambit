# Generate a lookup of colours for the chess board
colour_lookup <-
  list(brown = c("#b58863ff", "#f0d9b5ff"),
       blue = c("#8ca2adff", "#dee3e6ff"),
       blue2 = c("#607789ff", "#8298adff"),
       green = c("#86a666ff", "#ffffddff"),
       grey = c("#878787ff", "#a9a9a9ff"),
       pink = c("#f27474ff", "#f1f1caff"),
       purple = c("#7d4a8dff", "#9f90b0ff"),
       ic = c("#c1c18eff", "#ecececff")
       )

usethis::use_data(colour_lookup, overwrite = TRUE)
