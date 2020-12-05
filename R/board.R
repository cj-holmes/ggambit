#' Plot an empty chess board
#'
#'
#' @param perspective should the board be viewed from the white side or black side. One of "w" or "b" (default = "w")
#' @param cols Length 2 vector giving colours of dark and light squares (default = c("#b58863ff", "#f0d9b5ff"))
#'
#' @return A ggplot2 object
#' @export
#'
#' @examples
#' board()
board <- function(perspective = "w", cols = c("#b58863ff", "#f0d9b5ff")){

  squares <-
    tidyr::crossing(x = 1:8, y = 1:8) %>%
    dplyr::mutate(black = rep(c(rep(c(T,F), 4), rep(c(F,T), 4)), 4))

  b <-
    ggplot2::ggplot()+
    ggplot2::annotate(geom="tile",
                      x=squares$x[squares$black],
                      y=squares$y[squares$black],
                      height=1, width=1, fill=cols[1])+
    ggplot2::annotate(geom="tile",
                      x=squares$x[!squares$black],
                      y=squares$y[!squares$black],
                      height=1, width=1, fill=cols[2])+
    ggplot2::theme_minimal()+
    ggplot2::theme(panel.grid = ggplot2::element_blank(),
                   plot.caption = ggplot2::element_text(colour = cols[1]))

  if(perspective == "w"){
    b +
      ggplot2::scale_y_continuous("", breaks=1:8, limits=c(0, 9), expand = ggplot2::expansion(add=0.25))+
      ggplot2::scale_x_continuous("", breaks=1:8, labels = letters[1:8], limits=c(0, 9), expand = ggplot2::expansion(add=0.25))+
      ggplot2::coord_fixed(xlim=c(0.5, 8.5), ylim=c(0.5,8.5))

  } else if(perspective == "b"){
    b +
      ggplot2::scale_y_reverse("", breaks=1:8, limits=c(9, 0), expand = ggplot2::expansion(add=0.25))+
      ggplot2::scale_x_reverse("", breaks=1:8, labels = letters[1:8], limits=c(9, 0), expand = ggplot2::expansion(add=0.25))+
      ggplot2::coord_fixed(xlim=c(8.5, 0.5), ylim=c(8.5, 0.5))
  } else {
      stop("Perspective must be 'w' or 'b'")
    }
}
