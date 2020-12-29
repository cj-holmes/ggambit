#' Parse PGN text into a dataframe
#'
#' @param pgn A raw (un-annotated) PGN text file (can contain multiple PGNs)
#' @param pgn_tags#'
#' \itemize{
#'   \item "seven" - The 'Seven tag roster' (default)
#'   \item "all_present" - ALl tags found in the PGN file
#'   \item "all" - All known tags (experimental)
#'   }
#'
#' @return A list containing dataframes of each game found in the PGN text file
#' @export
pgn_to_df <- function(pgn, pgn_tags = "seven"){

  # pgn <- read_file('~/../Downloads/Adams/Adams.pgn')

  my_pgns <-
    readr::read_file(pgn) %>%
    # Split out the PGNs by splitting on two new lines markers followed by an open square bracket [
    str_split("\r\n\r\n(?=\\[)|\n\n(?=\\[)") %>%
    unlist() %>%
    # Remove all new line markers and quotes
    str_remove_all("\"") %>%
    unlist()

  # x <- my_pgns[[1]]

  # Map over all the PGNs
  purrr::map(my_pgns, function(x){

    # Extract tags
    tags <-
      x %>%
      # Extract everything but a closed square bracket ] that are preceeded by a [ and followed by a ]
      stringr::str_extract_all("(?<=\\[)[^\\]]+(?=\\])") %>%
      unlist() %>%
      # Put them into a tibble and split them on the first space
      # Splits after the first space are merged with the extra argument
      tibble(a=.) %>%
      separate(a, into=c("tag", "value"), sep=" ", extra="merge", fill="right")

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


    x %>%
      # Extract any characters of length one or more preceded by ]1.
      # The 1. is not extracted
      stringr::str_extract("(?<=\n1\\.)[[:graph:][:space:]]+") %>%
      # Remove the result from the end of the string.
      # TODO: Check that if the result tag is * (game still ongoing) that this doesnt mess up!
      # TODO: What if a pgn does not have a result field? This will error.
      stringr::str_remove(tags$Result) %>%
      # Split the moves on the number and full-stop
      stringr::str_split("[0-9]+\\.") %>%
      unlist() %>%
      stringr::str_remove_all("[\r\n]") %>%
      stringr::str_trim() %>%
      tibble::tibble(raw_moves = .) %>%
      dplyr::mutate(move_number = dplyr::row_number()) %>%
      tidyr::separate(raw_moves, into=c("w", "b"), sep = " ", fill="right") %>%
      tidyr::pivot_longer(cols=c("w", "b"), names_to = "colour", values_to = "move") %>%
      dplyr::mutate(square = stringr::str_extract(move, "[A-z]{1}[0-9]{1}"),
                    x = ggambit::square_lookup[substr(square, 1, 1)],
                    y = as.numeric(substr(square, 2, 2))) %>%
      dplyr::bind_cols(tags)
  }
  )
}
