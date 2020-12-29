#' Add a piece to the current plot
#'
#' @param piece piece symbol in FEN notation ("P" = white pawn etc...)
#' @param square Square to draw piece on
#' @param perspective Board perspective for the added piece (needs to be set to the same as persepctive used with \code{plot_fen()})
#' @param piece_scale Piece scaling factor (default = 0.85)
#'
#' @return
#' @export
#'
#' @examples
#' # Draw empty board and add some pieces
#' plot_fen("8/8/8/8/8/8/8/8 w KQkq - 0 1") +
#'   add_piece("q", "c3") +
#'   add_piece("B", "h8")
add_piece <- function(piece, square, perspective = "w", piece_scale = 0.85){

  x <- square_lookup[substr(square, 1, 1)]
  y <- substr(square, 2, 2) %>% as.integer()

  ggplot2::geom_polygon(data =
                          ggambit::paths %>%
                          dplyr::rename(p = piece) %>%
                          dplyr::filter(p == piece) %>%
                          dplyr::mutate(piece_x = dplyr::case_when(perspective == "w" ~ (xn * piece_scale) + x,
                                                                   perspective == "b" ~ (xni * piece_scale) + x,
                                                                   TRUE ~ (xn * piece_scale) + x),
                                        piece_y = dplyr::case_when(perspective == "w" ~ (yn * piece_scale) + y,
                                                                   perspective == "b" ~ (yni * piece_scale) + y,
                                                                   TRUE ~ (yn * piece_scale) + y)),
                        ggplot2::aes(piece_x, piece_y, fill=fill,
                                     group=interaction(id, x, y),
                                     subgroup=piece))
}
