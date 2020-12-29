#' Convert a PGN file to a dataframe
#'
#' This is experimental. It will not work for annotated PGN files.
#' http://www.saremba.de/chessgml/standards/pgn/pgn-complete.htm#c8.1.1
#'
#' @param pgn A raw (un-annotated) PGN text file
#' @param pgn_tags PGN tags wanted in the output dataframe. One of
#' \itemize{
#'   \item "seven" - The 'Seven tag roster' (default)
#'   \item "all_present" - ALl tags found in the PGN file
#'   \item "all" - All known tags (experimental)
#'   }
#'
#' @return
#' @export
pgn_to_df <- function(pgn, pgn_tags = "seven"){

  pgn <- readr::read_file(pgn)

  # Extract all tags from PGN in long format
  tags <-
    pgn %>%
    # Extract any characters of length one or more between square brackets
    stringr::str_extract_all("\\[.+\\]") %>%
    unlist() %>%
    # My regexps in human readable (should help find bugs and things I've missed)
    # tag: A-z text of length one or more following a [
    # value: Any characters of length one or more preceded by " and followed by "
    purrr::map_dfr(~tibble::tibble(tag = stringr::str_extract(.x, "(?<=\\[)[A-z]+"),
                                   value = stringr::str_extract(.x, "(?<=\").+(?=\")")))

  # A tags argument to the function could have 3 options for the user
  # Return all known tags (with missing values as NA) - left join to all_tags
  # Return only tags present in PGN - dont join to all_tags
  # Provide a vector of the tags wanted (with missing values as NA) - left join to all_tags and then filter to only those wanted?
  if(pgn_tags == "seven"){
    tags <-
      seven_tag_roster %>%
      dplyr::left_join(tags, by=c("tag" = "tag")) %>%
      tidyr::pivot_wider(id_cols = tag, names_from = tag)
  } else if(pgn_tags == "all"){
    tags <-
      all_tags %>%
      dplyr::left_join(tags, by=c("tag" = "tag")) %>%
      tidyr::pivot_wider(id_cols = tag, names_from = tag)
  } else if(pgn_tags == "all_present"){
    tags <- tags %>% tidyr::pivot_wider(id_cols = tag, names_from = tag)
  } else {
    tags <-
      seven_tag_roster %>%
      dplyr::left_join(tags, by=c("tag" = "tag")) %>%
      tidyr::pivot_wider(id_cols = tag, names_from = tag)
  }

  # Extarct the moves
  moves <-
    # Extract any characters of length one or more preceded by two new line markers and 1.
    # New line markers of \n or \r\n
    # The 1. is not extracted
    stringr::str_extract(pgn, "(?<=\n\n1\\.).+|(?<=\r\n\r\n1\\.).+") %>%
    # Remove the result from the end of the string.
    # TODO: Check that if the result tag is * (game still ongoing) that this doesnt mess up!
    # TODO: What if a pgn does not have a result field? This will error.
    stringr::str_remove(tags$Result) %>%
    # Split the moves on the number and full-stop
    stringr::str_split("[0-9]+\\.") %>%
    unlist() %>%
    stringr::str_trim()

  # Retrun the dataframe in long format with tag columns appended
  tibble::tibble(raw_moves = moves) %>%
    dplyr::mutate(move_number = row_number()) %>%
    tidyr::separate(raw_moves, into=c("w", "b"), sep = " ", fill="right") %>%
    tidyr::pivot_longer(cols=c("w", "b"), names_to = "colour", values_to = "move") %>%
    dplyr::mutate(square = stringr::str_extract(move, "[A-z]{1}[0-9]{1}"),
                  x = square_lookup[substr(square, 1, 1)],
                  y = as.numeric(substr(square, 2, 2))) %>%
    dplyr::bind_cols(tags)
}
