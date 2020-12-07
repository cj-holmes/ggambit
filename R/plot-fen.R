#' Visualise a FEN
#'
#' @param fen a character vector FEN of length one (defaults to the opening position)
#' @param perspective view board from white "w" or black "b" perspective (default = "w")
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
#' @param piece_scale scaling factor for piece sizes (default = 0.85)
#' @param show_coords logical - should the board coordinates be printed?
#' @param show_fen logical - should the FEN be printed in the plot caption
#'
#' @details Chess piece SVG design file downloaded from https://commons.wikimedia.org/wiki/File:Chess_Pieces_Sprite.svg
#'
#'  jurgenwesterhof (adapted from work of Cburnett), CC BY-SA 3.0 <https://creativecommons.org/licenses/by-sa/3.0>, via Wikimedia Commons
#'
#'
#' @return A ggplot2 plot object
#' @export
#'
#' @examples
#' plot_fen('Q1b2rk1/p1p2p1p/6Bp/2b5/8/2P5/P1P2PPP/R4RK1 b - - 0 16')
plot_fen <- function(fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
                     perspective = "w",
                     cols = "brown",
                     piece_scale = 0.85,
                     show_coords = TRUE,
                     show_fen = TRUE){

  # Convert FEN to a df, join to only the relevant piece polygons (inner join)
  # Adjust the pieces to sit in the right squares (and apply scaling to piece size)
  piece_df <-
    fen_to_df(fen) %>%
    dplyr::inner_join(paths, by=c("p" = "piece")) %>%
    dplyr::mutate(piece_x = (xn*piece_scale) + x,
                  piece_y = (yn*piece_scale) + y,
                  piece_xi = (xni*piece_scale) + x,
                  piece_yi = (yni*piece_scale) + y)

  # Render board and add piece layer
  if(perspective == "w"){
    # If perspective is white, plot the pieces with the standard piece_x and piece_y coordinates
    b <-
      board(perspective=perspective, cols=cols, show_coords=show_coords) +
      ggplot2::geom_polygon(data=piece_df,
                            ggplot2::aes(x=piece_x, y=piece_y, fill=fill,
                                         group=interaction(id, x, y),
                                         subgroup=p))+
      ggplot2::scale_fill_identity()

  } else if(perspective == "b"){
    # If perspective is black, plot the pieces with the inverted piece_x and piece_y coordinates so that
    # when the x and y scales are reversed by board(), the pieces are flipped back again and plotted in the correct orientation
    b <-
      board(perspective=perspective, cols=cols, show_coords=show_coords) +
      ggplot2::geom_polygon(data=piece_df,
                            ggplot2::aes(x=piece_xi, y=piece_yi, fill=fill,
                                         group=interaction(id, x, y),
                                         subgroup=p))+
      ggplot2::scale_fill_identity()
  }

  # Add FEN as a caption if requested
  if(show_fen) b <- b + ggplot2::labs(caption = fen)

  # Return ggplot2 object
  b


}
