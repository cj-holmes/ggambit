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

  # Extract pieces section from the FEN and replace them with their notation_lookup value
  # Then create a vector of letters (should always be length 64)
  pieces_vector <-
    notation_lookup[stringr::str_split(parse_fen(fen)['pieces'], "")[[1]]] %>%
    stringr::str_flatten() %>%
    stringr::str_split("") %>%
    unlist()

  # Create dataframe of all 64 positions in the correct order
  # Add the pieces vactor, flag if a piece is white
  expand.grid(x=1:8, y=8:1) %>%
    dplyr::mutate(p = pieces_vector) %>%
    dplyr::filter(p != " ")

}
