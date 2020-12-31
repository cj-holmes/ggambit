#' Plot chess pieces
#'
#' @details Chess piece SVG design file downloaded from https://commons.wikimedia.org/wiki/File:Chess_Pieces_Sprite.svg
#'
#'  jurgenwesterhof (adapted from work of Cburnett), CC BY-SA 3.0 <https://creativecommons.org/licenses/by-sa/3.0>, via Wikimedia Commons
#'
#' @return A ggplot2 object
#' @export
plot_pieces <- function(){
  ggambit::paths %>%
    ggplot2::ggplot(ggplot2::aes(xn, yn))+
    ggplot2::geom_polygon(ggplot2::aes(fill=fill, group=as.factor(id)))+
    ggplot2::facet_wrap(~piece)+
    ggplot2::scale_fill_identity()+
    ggplot2::coord_equal()
}
