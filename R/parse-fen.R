#' Parse a FEN text string
#'
#' @param fen a character vector FEN of length one
#'
#' @return A named character vector
#' @export
#'
#' @examples
#' parse_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
parse_fen <- function(fen){

  # Break FEN into its 6 parts (individual sections of the FEN are separated by spaces)
  # https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation
  stringr::str_split(fen, " ")[[1]] %>%
    setNames(nm=c("pieces", "active_colour", "castling_availability",
                  "en_passant_target", "halfmove", "fullmove"))

  }


#' Convert a FEN string to a dataframe of pieces and positions
#'
#' @param fen a character vector FEN of length one
#'
#' @return A dataframe
#' @export
#'
#' @examples
#' fen_to_df("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
fen_to_df <- function(fen){

  # Extract pieces section from the FEN
  pieces_vector <-
    parse_fen(fen)['pieces'] %>%
    # Remove all "/", split into individual characters and store in a df
    stringr::str_remove_all("/") %>%
    stringr::str_split("") %>%
    unlist() %>%
    tibble::tibble(raw = .) %>%
    # Find the elements that are integers (the unoccupied squares on the chess board)
    dplyr::mutate(numeric = strtoi(raw)) %>%
    # Replace the integers with the integer value of empty spaces
    dplyr::transmute(r = purrr::map2_chr(raw, numeric,
                                         function(x,y){
                                           if(is.na(y)){x} else {stringr::str_flatten(rep(" ", y))}
                                         })) %>%
    dplyr::pull(r) %>%
    stringr::str_flatten() %>%
    stringr::str_split("") %>%
    unlist()

  # Create dataframe of all 64 positions in the correct order
  # Add the pieces vactor, flag if a piece is white
  expand.grid(x=1:8, y=8:1) %>%
    dplyr::mutate(p = pieces_vector) %>%
    dplyr::filter(p != " ") %>%
    dplyr::mutate(is_white = stringr::str_detect(p, "^[:upper:]+$"))

}
