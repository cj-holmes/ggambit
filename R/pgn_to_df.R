#' Parse PGN text into a dataframe EXPERIMENTAL
#'
#' This is an \bold{experimental} function that attempts to parse raw (un-annotated) Portable Game Notation (PGN) files into a dataframe. It is
#'   also very \bold{slow}
#'
#' @param pgn A raw (un-annotated) PGN text file (can contain multiple PGNs)
#' @param pgn_tags one of
#' \itemize{
#'   \item "seven" - The 'Seven tag roster' (default)
#'   \item "all_present" - All tags found in the PGN file
#'   }
#'
#' @return A list containing dataframes of each game found in the PGN text file
#' @export
pgn_to_df <- function(pgn, pgn_tags = "seven"){

  message("**USE WITH CAUTION** This function is experimental and buggy\nIt's also slow (approx 22 seconds to parse 1000 PGNs on my laptop)")

  # Clean and split the PGN file up into individual PGNs
  my_pgns <-
    readr::read_file(pgn) %>%
    # Replace any \r (new line markers) with the standard \n
    stringr::str_replace_all("\r", "\n") %>%
    # Now replace any instance of 2 or more \n in a row with a single \n
    stringr::str_replace_all("\n{2,}", "\n") %>%
    # Remove all quotes
    stringr::str_remove_all("\"") %>%
    # Split out the PGNs by splitting on a \n that is preceeded by a result
    stringr::str_split("(?<=\\*|1/2-1/2|0-1|1-0)\n") %>%
    # Convert list back to a vector
    unlist() %>%
    # Now replace all the new line markers with a space
    stringr::str_replace_all("\n", " ") %>%
    # And now replace spaces of 2 or more with just a single space
    stringr::str_replace_all(" {2,}", " ")

  # Some PGN files get split and have an empty last record - this gets rid of them...hacky
  my_pgns <- my_pgns[my_pgns != ""]

  # For information
  if(length(my_pgns) > 50) message(paste0("Parsing ", length(my_pgns), " games..."))

  # Map across each PGN
  purrr::map(my_pgns, function(x){

    # Extract tags
    tags <-
      x %>%
      # Extract everything but a closed square bracket ] that are preceeded by a [ and followed by a ]
      stringr::str_extract_all("(?<=\\[)[^\\]]+(?=\\])") %>%
      unlist() %>%
      # Put them into a tibble and split them on the first space
      # Splits after the first space are merged with the extra argument
      tibble::tibble(a=.) %>%
      tidyr::separate(a, into=c("tag", "value"), sep=" ", extra="merge", fill="right")

    # A tags argument to the function could have 3 options for the user
    # Return all known tags (with missing values as NA) - left join to all_tags
    # Return only tags present in PGN - dont join to all_tags
    # Provide a vector of the tags wanted (with missing values as NA) - left join to all_tags and then filter to only those wanted?
    if(pgn_tags == "seven"){
      tags <-
        ggambit::seven_tag_roster %>%
        dplyr::left_join(tags, by=c("tag" = "tag")) %>%
        tidyr::pivot_wider(id_cols = tag, names_from = tag)
    } else if(pgn_tags == "all"){
      tags <-
        ggambit::all_tags %>%
        dplyr::left_join(tags, by=c("tag" = "tag")) %>%
        tidyr::pivot_wider(id_cols = tag, names_from = tag)
    } else if(pgn_tags == "all_present"){
      tags <- tags %>% tidyr::pivot_wider(id_cols = tag, names_from = tag)
    } else {
      tags <-
        ggambit::seven_tag_roster %>%
        dplyr::left_join(tags, by=c("tag" = "tag")) %>%
        tidyr::pivot_wider(id_cols = tag, names_from = tag)
    }

    # Extract the moves and join the tags to them
    x %>%
      # Extract the moves section.
      # Any characters of length one or more preceded by ] 1. and followed by a result
      stringr::str_extract("(?<=\\] 1\\.)[[:graph:][:space:]]+(?=\\*|1/2-1/2|0-1|1-0)") %>%
      # Split the moves on the number and full-stop
      stringr::str_split("[0-9]+\\.") %>%
      unlist() %>%
      stringr::str_trim() %>%
      tibble::tibble(raw_moves = .) %>%
      dplyr::mutate(move_number = dplyr::row_number()) %>%
      # Fill to the right if the black does not make a last move (checkmate on whites move)
      # Merge extra pieces if move text is separated by two spaces (which Ive come across from opening tree PGN files)
      tidyr::separate(raw_moves, into=c("w", "b"), sep = " ", fill="right", extra = "merge") %>%
      tidyr::pivot_longer(cols=c("w", "b"), names_to = "colour", values_to = "move") %>%
      dplyr::mutate(square = stringr::str_extract(move, "[A-z]{1}[0-9]{1}"),
                    x = ggambit::square_lookup[substr(square, 1, 1)],
                    y = as.numeric(substr(square, 2, 2))) %>%
      dplyr::bind_cols(tags)
  })

}
