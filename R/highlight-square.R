#' Highlight soecific square of chess board
#'
#' @param square square to highlight (example: "e4")
#' @param col colour of highlight circle
#' @param size thickness of highlight circle
#' @param fill fill colour of highlight circle
#' @param ... further arguments passed to \code{ggplot2::geom_polygon()}
#'
#' @return A ggplot2 geom_polygon() layer
#' @export
highlight_squares <- function(squares, col="red", size=1.5, fill=NA, res=50, d=0.45, ...){

  circle <-
    tibble::tibble(x = d*cos(seq(0, 2*pi, l=res)),
                   y = d*sin(seq(0, 2*pi, l=res)))

  purrr::map(squares, function(s){
    da <-
      circle %>%
      dplyr::mutate(x = x + square_lookup[substr(s, 1, 1)],
                    y = y + as.integer(substr(s, 2, 2)))

    ggplot2::geom_polygon(data = da, ggplot2::aes(x=x, y=y),
                          col=col,
                          size=size,
                          fill=fill,
                          ...)
  })
}
