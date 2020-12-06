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
#'
#' @return A ggplot2 object
#' @export
board <- function(perspective = "w", cols = "brown"){

  # If cols is passed as a length one string, pick the colours from the lookup list
  if(length(cols) == 1){
    sq_cols <- colour_lookup[[cols]]
  } else {
    # Else use the colours as provided
    sq_cols <- cols
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
    ggplot2::theme_minimal()+
    ggplot2::theme(panel.grid = ggplot2::element_blank(),
                   plot.caption = ggplot2::element_text(colour = sq_cols[1]))

  # Ammend the base plot based on perspective chosen
  if(perspective == "w"){
    b +
      ggplot2::scale_y_continuous("", breaks=1:8, limits=c(0, 9), expand = ggplot2::expansion(add=0.05))+
      ggplot2::scale_x_continuous("", breaks=1:8, labels = letters[1:8], limits=c(0, 9), expand = ggplot2::expansion(add=0.05))+
      ggplot2::coord_fixed(xlim=c(0.5, 8.5), ylim=c(0.5,8.5))

  } else if(perspective == "b"){
    b +
      ggplot2::scale_y_reverse("", breaks=1:8, limits=c(9, 0), expand = ggplot2::expansion(add=0.05))+
      ggplot2::scale_x_reverse("", breaks=1:8, labels = letters[1:8], limits=c(9, 0), expand = ggplot2::expansion(add=0.05))+
      ggplot2::coord_fixed(xlim=c(8.5, 0.5), ylim=c(8.5, 0.5))
  } else {
      stop("Perspective must be 'w' or 'b'")
    }
}
