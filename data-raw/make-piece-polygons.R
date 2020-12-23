library(tidyverse)

# Need to run so R can find Ghost Script on my computer
Sys.setenv(R_GSCMD = "C:/Program Files/gs/gs9.27/bin/gswin64c.exe")


# convert each ps file into an xml file and store in data-raw
map(list.files('data-raw/pieces/', pattern = ".ps", full.names = TRUE),
    ~grImport::PostScriptTrace(file = .x,
                               outfilename = paste0(.x, ".xml")))


paths <-
  list.files('data-raw/pieces/', pattern=".xml", full.names = TRUE) %>%
  tibble(xml_file_name = .) %>%
  mutate(xml_file = map(xml_file_name, ~grImport::readPicture(.x))) %>%
  mutate(paths = map(xml_file, ~.x@paths)) %>%
  mutate(paths_df = map(paths, ~imap(unname(.x), ~tibble(x=.x@x, y=.x@y, fill=.x@rgb, id=.y)))) %>%
  select(xml_file_name, paths_df) %>%
  unnest(paths_df) %>%
  unnest(paths_df) %>%
  mutate(colour = substr(xml_file_name, 17, 17),
         piece = substr(xml_file_name, 18, 18),
         piece = case_when(colour == "w" ~ toupper(piece),
                           TRUE ~ piece))

# View unnormalised pieces
paths %>%
  ggplot(aes(x, y))+
  geom_polygon(aes(fill=fill, group=as.factor(id)))+
  facet_wrap(~piece)+
  scale_fill_identity()+
  coord_equal()

piece_size_lookup <-
  paths %>%
  group_by(piece) %>%
  summarise(min_x = min(x),
            max_x = max(x),
            min_y = min(y),
            max_y = max(y)) %>%
  mutate(width = max_x - min_x,
         height = max_y - min_y,
         width_n = width/max(width),
         height_n = height/max(height),
         ar = height/width)

paths <-
  paths %>%
  inner_join(piece_size_lookup) %>%
  group_by(piece) %>%
  # Shift each piece to align bottom left corner on (0,0)
  mutate(x = x - min(x),
         y = y - min(y)) %>%
  # Scale all x values to the global maximum x (largest width piece)
  ungroup() %>%
  mutate(xn = x / (max(x))) %>%
  # Scale y values to be the equivalent aspect of the scaled x pieces
  group_by(piece) %>%
  mutate(scaled_width = max(xn),
         yn = (y / max(y)) * scaled_width * ar) %>%
  # centre the pieces on (0,0)
  mutate(xn = xn - ((max(xn) - min(xn))/2),
         yn = yn - ((max(yn) - min(yn))/2)) %>%
  select(piece, xn, yn, fill, id) %>%
  # Invert pieces in y for when board is viewed from Black's perspective
  group_by(piece) %>%
  mutate(y_range = max(yn),
         x_range = max(xn)) %>%
  mutate(yni = y_range - yn,
         xni = x_range - xn) %>%
  mutate(yni = yni - ((max(yni) - min(yni))/2),
         xni = xni - ((max(xni) - min(xni))/2))

paths %>%
  # filter(piece == "B") %>%
  ggplot(aes(xn, yn))+
  geom_polygon(aes(fill=fill, group=as.factor(id)))+
  facet_wrap(~piece)+
  scale_fill_identity()+
  coord_equal()+
  geom_vline(xintercept = 0, col=4)+
  geom_hline(yintercept = 0, col=4)

usethis::use_data(paths, overwrite = TRUE)
