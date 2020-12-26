library(tidyverse)
# http://www.saremba.de/chessgml/standards/pgn/pgn-complete.htm#c8.1.1

# seven tag roster
str <- c("Event", "Site", "Date", "Round", "White", "Black", "Result") %>% tibble::tibble(tag = .)

# A lookup of all known common tags
all_tags <-
  tibble(tag = c("Event", "Site", "Date", "Round", "White", "Black", "Result",
                 "Annotator", "PlyCount", "TimeControl", "Time", "Termination", "Mode", "FEN",
                 "UTCDate", "UTCTime", "WhiteElo", "BlackElo", "Variant", "ECO", "Opening"))


pgn_to_df <- function(pgn, pgn_tags = "seven"){

  pgn <- read_file(pgn)
  # pgn <- read_file('tests/test-pgn1-annotated.pgn')
  # pgn_tags <- "seven"

  # Extract all tags from PGN in long format
  tags <-
    pgn %>%
    # Extract any characters of length one or more between square brackets
    str_extract_all("\\[.+\\]") %>%
    unlist() %>%
    # My regexps in human readable (should help find bugs and things I've missed)
    # tag: A-z text of length one or more following a [
    # value: Any characters of length one or more preceded by " and followed by "
    map_dfr(~tibble(tag = str_extract(.x, "(?<=\\[)[A-z]+"),
                    value = str_extract(.x, "(?<=\").+(?=\")")))

  # A tags argument to the function could have 3 options for the user
  # Return all known tags (with missing values as NA) - left join to all_tags
  # Return only tags present in PGN - dont join to all_tags
  # Provide a vector of the tags wanted (with missing values as NA) - left join to all_tags and then filter to only those wanted?
  if(pgn_tags == "seven"){
    tags <-
      str %>%
      left_join(tags, by=c("tag" = "tag")) %>%
      pivot_wider(id_cols = tag, names_from = tag)
  } else if(pgn_tags == "all"){
    tags <-
      all_tags %>%
      left_join(tags, by=c("tag" = "tag")) %>%
      pivot_wider(id_cols = tag, names_from = tag)
  } else if(pgn_tags == "all_present"){
    tags <- tags %>% pivot_wider(id_cols = tag, names_from = tag)
  } else {
    tags <-
      str %>%
      left_join(tags, by=c("tag" = "tag")) %>%
      pivot_wider(id_cols = tag, names_from = tag)
  }

  # Extarct the moves
  moves <-
    # Extract any characters of length one or more preceded by two new line markers and 1.
    # The 1. is not extracted
    str_extract(pgn, "(?<=\n\n1\\.).+") %>%
    # Remove the result from the end of the string.
    # TODO: Check that if the result tag is * (game still ongoing) that this doesnt mess up!
    # TODO: What if a pgn does not have a result field? This will error.
    str_remove(tags$Result) %>%
    # Split the moves on the number and full-stop
    str_split("[0-9]+\\.") %>%
    unlist() %>%
    str_trim()

  # Retrun the dataframe in long format with tag columns appended
  tibble(raw_moves = moves) %>%
    mutate(move_number = row_number()) %>%
    separate(raw_moves, into=c("w", "b"), sep = " ", fill="right") %>%
    bind_cols(tags)
}


pgn_to_df('tests/test-pgn1.pgn', pgn_tags = "all_present") %>%
  holmesr::print_all()

