#' Fade the chess board
#'
#' Fading the board can make annotations stand out more
#'
#' @param fade fade ammount between 0 (no fade) and 1 (no board)
#' @param fill fade colour (default = "white")
#'
#' @export
#' @examples
#' plot_fen() +
#'   fade_board() +
#'   add_arrow("g1", "f3")
fade_board <- function(fade = 0.5, fill = "white"){

  ggplot2::geom_polygon(data = tibble::tibble(x=c(0.5, 8.5, 8.5, 0.5),
                                              y=c(0.5, 0.5, 8.5, 8.5)),
                        fill = fill,
                        alpha = fade,
                        ggplot2::aes(x, y))

}



