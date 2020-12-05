library(tidyverse)

# Need to run so R can find Ghost Script on my computer
Sys.setenv(R_GSCMD = "C:/Program Files/gs/gs9.27/bin/gswin64c.exe")


# convert each ps file into an xml file and store in data-raw
map(list.files('data-raw/pieces/', pattern = ".ps", full.names = TRUE),
    ~grImport::PostScriptTrace(file = .x,
                              outfilename = paste0(.x, ".xml"),
                              setflat = 0.2))


paths <-
  list.files('data-raw/pieces/', pattern=".xml", full.names = TRUE) %>%
  tibble(xml_file_name = .) %>%
  mutate(xml_file = map(xml_file_name, ~grImport::readPicture(.x))) %>%
  mutate(paths = map(xml_file, ~.x@paths)) %>%
  mutate(paths_df = map(paths, ~imap(unname(.x), ~tibble(x=.x@x, y=.x@y, fill=.x@rgb, id=.y)))) %>%
  select(xml_file_name, paths_df) %>%
  unnest(paths_df) %>%
  unnest(paths_df) %>%
  # Normalise piece sizes relative to the largest piece (so that the largest piece is scaled between 0 and 1)
  mutate(min_x = min(x), max_x = max(x), min_y = min(y), max_y = max(y)) %>%
  mutate(xn = (x - min_x)/(max_x - min_x),
         yn = (y - min_y)/(max_y - min_y)) %>%
  # Normalise each pice indivdually to be centered on (0,0)
  group_by(xml_file_name) %>%
  mutate(xn = xn - ((max(xn) - min(xn))/2),
         yn = yn - ((max(yn) - min(yn))/2)) %>%
  ungroup() %>%
  mutate(colour = substr(xml_file_name, 17, 17),
         piece = substr(xml_file_name, 18, 18),
         piece = case_when(colour == "w" ~ toupper(piece),
                           TRUE ~ piece)) %>%
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
  ggplot(aes(xn, yni))+
  geom_polygon(aes(fill=fill, group=as.factor(id)))+
  geom_point(aes(x=0, y=0), col="red")+
  facet_wrap(~piece)+
  scale_fill_identity()+
  coord_equal()

usethis::use_data(paths, overwrite = TRUE)
