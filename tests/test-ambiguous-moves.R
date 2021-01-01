library(ggambit)
library(tidyverse)

# In a few cases a more detailed representation is needed to resolve ambiguity;
# if so, the piece's file letter, numerical rank, or the exact square is inserted after the moving piece's name (in that order of preference). T
# Thus, Nge2 specifies that the knight originally on the g-file moves to e2.

e <- pgn_to_df('~/../Downloads/EricRosen-white.pgn') %>% bind_rows()

# Piece - file - move square
e %>% filter(str_detect(move, "[A-Z]{1}[^x]{1}[a-z]{1}[0-9]{1}"))


# Piece - rank - move square
e %>% filter(str_detect(move, "[A-Z]{1}[0-9]{1}[a-z]{1}[0-9]{1}"))


# Piece - file rank - move square
# I cant find any
e %>% filter(str_detect(move, "[A-Z]{1}[a-z]{1}[0-9]{1}[a-z]{1}[0-9]{1}"))

# Check the regexp works
str_extract("------Re6f6-----", "[A-Z]{1}[a-z]{1}[0-9]{1}[a-z]{1}[0-9]{1}")
