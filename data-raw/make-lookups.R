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

# Generate a lookup for helping to parse the pieces section of FEN strings
notation_lookup <-
  c("p" = "p",
    "b" = "b",
    "n" = "n",
    "r" = "r",
    "q" = "q",
    "k" = "k",
    "P" = "P",
    "B" = "B",
    "N" = "N",
    "R" = "R",
    "Q" = "Q",
    "K" = "K",
    "1" = " ",
    "2" = "  ",
    "3" = "   ",
    "4" = "    ",
    "5" = "     ",
    "6" = "      ",
    "7" = "       ",
    "8" = "        ",
    "/" = ""
    )

square_lookup <- setNames(1:8, letters[1:8])

# seven tag roster
seven_tag_roster <- c("Event", "Site", "Date", "Round", "White", "Black", "Result") %>% tibble::tibble(tag = .)

# A lookup of all known common tags
all_tags <-
  tibble(tag = c("Event", "Site", "Date", "Round", "White", "Black", "Result",
                 "Annotator", "PlyCount", "TimeControl", "Time", "Termination", "Mode", "FEN",
                 "UTCDate", "UTCTime", "WhiteElo", "BlackElo", "Variant", "ECO", "Opening"))

usethis::use_data(colour_lookup,
                  notation_lookup,
                  square_lookup,
                  seven_tag_roster,
                  all_tags,
                  overwrite = TRUE)
