#' Add arrow to chess board visualisation
#'
#' @param start start square for arrow as character (example: "e2")
#' @param end end square for arrow as character (example: "e4")
#' @param arrow_style an arrow specified by \code{grid::arrow()}
#' @param size arrow size (line thickness)
#' @param col arrow colour
#' @param ... further arguments passed to \code{ggplot2::geom_segment()}

#'
#' @return A ggplot2 geom_segment() layer
#' @export
add_arrow <- function(start, end, arrow_style = grid::arrow(), size = 1.5, col = "blue", ...){

  lu <- setNames(1:8, letters[1:8])

  ggplot2::geom_segment(ggplot2::aes(x = lu[substr(start, 1, 1)],
                                     y = as.integer(substr(start, 2, 2)),
                                     xend = lu[substr(end, 1, 1)],
                                     yend = as.integer(substr(end, 2, 2))),
                        arrow = arrow_style,
                        size = size,
                        col = col,
                        ...)
}
