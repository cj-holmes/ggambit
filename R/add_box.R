#' Add a box layer to the chess board
#'
#' @param bottom_left square for box bottom left coordinate (eg "e4")
#' @param top_right square for box top right coordinate
#' @param size Box line size
#' @param linetype Box line type
#' @param fill Box fill (default = NA (no fill))
#' @param col Box line colour (default = "red")
#' @param ... Further arguments passed to \code{ggplot2::geom_rect()}
#'
#' @return A ggplot2 geom_segment() layer
#' @export
#'
#' @examples
#' plot_fen() + add_box("d4", "e5")
#' plot_fen() +
#'   add_box("d4", "e5", fill = "white", alpha=1/2) +
#'   add_box("g3", "h6", fill="green", alpha=1/2, col="black", linetype="solid")
add_box <- function(bottom_left, top_right, size = 1.5, linetype = "dashed", fill = NA, col = "red", ...){

  lu <- setNames(1:8, letters[1:8])

  ggplot2::geom_rect(ggplot2::aes(xmin = lu[substr(bottom_left, 1, 1)] - 0.5,
                                  xmax = lu[substr(top_right, 1, 1)] + 0.5,
                                  ymin = as.integer(substr(bottom_left, 2, 2)) - 0.5,
                                  ymax = as.integer(substr(top_right, 2, 2)) + 0.5),
                     size = size,
                     col = col,
                     fill = fill,
                     linetype = linetype,
                     ...)
}



