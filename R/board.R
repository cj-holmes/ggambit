#' Plot an empty chess board
#'
#' @param perspective should the board be viewed from the white side or black side. One of "w" or "b" (default = "w")
#' @param cols A single character colour theme listed below or a length 2 vector of colours ordered dark, light (default = "brown")
#' \itemize{
#'   \item "brown"
#'   \item "blue"
#'   \item "blue2"
#'   \item "green"
#'   \item "grey"
#'   \item "pink"
#'   \item "purple"
#'   \item "ic"
#'   }
#' @param show_coords logical - should the board coordinates be printed?
#'
#' @return A ggplot2 object
#' @export
board <- function(perspective = "w", cols = "brown", show_coords = TRUE){

  # If cols is passed as a length one string, pick the colours from the lookup list
  if(length(cols) == 1 && (cols %in% names(colour_lookup))){
    sq_cols <- colour_lookup[[cols]]
  } else if(length(cols) == 2){
    # Else use the colours as provided
    sq_cols <- cols
  } else {
    stop("'cols' must be provided as a single colour specification (see documentation) or a length 2 vector of dark and light square colours")
  }

  # Create a dataframe for the geom_tile() chessboard
  squares <-
    tidyr::crossing(x = 1:8, y = 1:8) %>%
    dplyr::mutate(black = rep(c(rep(c(T,F), 4), rep(c(F,T), 4)), 4))

  # Create the base plot
  b <-
    ggplot2::ggplot()+
    ggplot2::annotate(geom="tile",
                      x=squares$x[squares$black],
                      y=squares$y[squares$black],
                      height=1, width=1, fill=sq_cols[1])+
    ggplot2::annotate(geom="tile",
                      x=squares$x[!squares$black],
                      y=squares$y[!squares$black],
                      height=1, width=1, fill=sq_cols[2])+
    ggplot2::coord_fixed()+
    ggplot2::theme_minimal()+
    ggplot2::theme(plot.caption = ggplot2::element_text(colour = sq_cols[1]))

  # Ammend the background plot based on perspective chosen
  if(perspective == "w"){
    b <-
      b +
      ggplot2::scale_y_continuous("", breaks=1:8, limits=c(0.5, 8.5), expand = ggplot2::expansion(add=0, mult = 0))+
      ggplot2::scale_x_continuous("", breaks=1:8, labels = letters[1:8], limits=c(0.5, 8.5), expand = ggplot2::expansion(add=0))

  } else if(perspective == "b"){
    b <-
      b +
      ggplot2::scale_y_reverse("", breaks=1:8, limits=c(8.5, 0.5), expand = ggplot2::expansion(add=0))+
      ggplot2::scale_x_reverse("", breaks=1:8, labels = letters[1:8], limits=c(8.5, 0.5), expand = ggplot2::expansion(add=0))

  } else {
    stop("Perspective must be 'w' or 'b'")
  }

  if(!show_coords){
    b <- b + ggplot2::theme(axis.text = ggplot2::element_blank())
  }

  b

}
