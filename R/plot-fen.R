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
#' @param show_coords logical - should the board coordinates be printed? (default = TRUE)
#' @param show_fen logical - should the FEN be printed in the plot caption? (default = FALSE)
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
#' # Plot the starting position
#' plot_fen('Q1b2rk1/p1p2p1p/6Bp/2b5/8/2P5/P1P2PPP/R4RK1 b - - 0 16')
#'
#' # Plot an empty board
#' plot_fen("8/8/8/8/8/8/8/8 w KQkq - 0 1")
plot_fen <- function(fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
                     perspective = "w",
                     cols = "brown",
                     piece_scale = 0.85,
                     show_coords = TRUE,
                     show_fen = FALSE){


  # Create dataframe of pieces from FEN -------------------------------------
  # Convert FEN to a df, join to only the relevant piece polygons (inner join)
  # Adjust the pieces to sit in the right squares (and apply scaling to piece size)
  # Pick inverted pieces if perspective == "b"
  piece_df <-
    fen_to_df(fen) %>%
    dplyr::inner_join(paths, by=c("p" = "piece")) %>%
    dplyr::mutate(piece_x = dplyr::case_when(perspective == "w" ~ (xn * piece_scale) + x,
                                             perspective == "b" ~ (xni * piece_scale) + x,
                                             TRUE ~ (xn * piece_scale) + x),
                  piece_y = dplyr::case_when(perspective == "w" ~ (yn * piece_scale) + y,
                                             perspective == "b" ~ (yni * piece_scale) + y,
                                             TRUE ~ (yn * piece_scale) + y)
    )


  # Get colours for board ---------------------------------------------------
  # If cols is passed as a length one string, pick the colours from the lookup list
  if(length(cols) == 1 && (cols %in% names(colour_lookup))){
    sq_cols <- colour_lookup[[cols]]
  } else if(length(cols) == 2){
    # Else use the colours as provided
    sq_cols <- cols
  } else {
    colour_lookup[["brown"]]
  }


  # Create board ------------------------------------------------------------
  # Create a dataframe for the geom_tile() chessboard
  squares <-
    tidyr::crossing(x = 1:8, y = 1:8) %>%
    dplyr::mutate(black = rep(c(rep(c(T,F), 4), rep(c(F,T), 4)), 4))

  # Create the background board plot layer
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
    ggplot2::theme_minimal()

  # Ammend coordinate system based on the perspective chosen
  if(perspective == "b"){
    b <-
      b +
      ggplot2::scale_y_reverse("", breaks=1:8, limits=c(8.5, 0.5),
                               expand = ggplot2::expansion(add=0))+
      ggplot2::scale_x_reverse("", breaks=1:8, labels = letters[1:8],
                               limits=c(8.5, 0.5), expand = ggplot2::expansion(add=0))
  } else {
    b <-
      b +
      ggplot2::scale_y_continuous("", breaks=1:8, limits=c(0.5, 8.5),
                                  expand = ggplot2::expansion(add=0, mult = 0))+
      ggplot2::scale_x_continuous("", breaks=1:8, labels = letters[1:8],
                                  limits=c(0.5, 8.5), expand = ggplot2::expansion(add=0))
  }

  # Render board and add piece layer
  b <-
    b +
    ggplot2::geom_polygon(data=piece_df,
                          ggplot2::aes(x=piece_x, y=piece_y, fill=fill,
                                       group=interaction(id, x, y),
                                       subgroup=p))+
    ggplot2::scale_fill_identity()


  # Add FEN as a caption if requested ---------------------------------------
  if(show_fen) b <- b + ggplot2::labs(caption = fen)


  # Show coordinates on plot if chosen --------------------------------------
  if(!show_coords) b <- b + ggplot2::theme(axis.text = ggplot2::element_blank())

  # Return the plot
  b

}
