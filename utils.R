# https://stackoverflow.com/a/67237035
remove_emojis <- function(string) {
  string_as_int <- string %>%
    utf8ToInt()
  # replace with empty space 
  string_as_int[which(string_as_int > 100000)] <- 160
  intToUtf8(string_as_int)
}

make_body <- function(tw){
  list(
    text = tw,
    limit = 3
  ) -> body
  return(body)
}

#-------------
# Keywording
#-------------

# Code adapted from roadoi https://github.com/ropensci/roadoi/blob/main/R/oadoi_fetch.r
kw_fetch <- function(tweet = NULL, project = NULL) { 
  
  resp <- httr::RETRY(verb = "POST",
                      url = paste0("https://ai.finto.fi/v1/projects/", project, "/suggest"),
                      body = make_body(tweet),
                      user_agent("https://github.com/tts/minatutkintweets"))
  
  if (httr::status_code(resp) != 200) {
    warning(
      sprintf(
        "Request failed [%s]\n%s",
        httr::status_code(resp),
        httr::content(resp)$message
      ),
      call. = FALSE
    )
    NULL
  } else {
    httr::content(resp, "text", encoding = "UTF-8") %>%
      jsonlite::fromJSON() %>%
      purrr::map_if(is.null, ~ NA_character_) %>%
      parse_req(tweet)
  }
}

parse_req <- function(req, tweet) {
  tibble::tibble(
    text = tweet,
    label = list(tibble::as_tibble(req$results$label)),
    label_score = list(tibble::as_tibble(req$results$score)),
    label_uri = list(tibble::as_tibble(req$results$uri))
  )
}

unnest_req <- function(req) {
  req %>% 
    dplyr::select(
      -.data$label$value,
      -.data$label_score$value, 
      -.data$label_uri$value
  ) %>%
    tidyr::unnest(c(.data$label, .data$label_uri), names_repair = "universal",
                keep_empty = TRUE) %>% 
    rename(label = `value...2`,
           uri = `value...4`)
}

#----------------
# Broader terms
#----------------

t_fetch <- function(uri = NULL, lang = NULL) { 
  
  resp <- httr::GET(url = paste0("https://api.finto.fi/rest/v1/yso/broader?uri=", uri, "&lang=", lang),
                    user_agent("https://github.com/tts/minatutkintweets"))
  
  if (httr::status_code(resp) == 404) {
    NULL
  } else {
    httr::content(resp, "text", encoding = "UTF-8") %>%
      jsonlite::fromJSON() %>%
      purrr::map_if(is.null, ~ NA_character_) %>%
      parse_req_b()
  }
}

parse_req_b <- function(req) {
  tibble::tibble(
    uri = req[["uri"]],
    # The uri/term can be deprecated
    broader_term = ifelse(length(req[["broader"]]) == 0, NA_character_, req[["broader"]]$prefLabel),
    broader_term_uri = ifelse(length(req[["broader"]]) == 0, NA_character_, req[["broader"]]$uri)
  )
}


#---------------
# Groups
#---------------

g_fetch <- function(uri = NULL, lang = NULL) { 
  
  resp <- httr::GET(url = paste0("https://api.finto.fi/rest/v1/yso/data?uri=", uri, "&lang=", lang),
                    user_agent("https://github.com/tts/minatutkintweets"),
                    accept_json())
  
  if (httr::status_code(resp) == 404) {
    NULL
  } else {
    c <- httr::content(resp, "text", encoding = "UTF-8") %>%
      jsonlite::fromJSON() %>%
      purrr::map_if(is.null, ~ NA_character_) 
    
    c_f <- parse_req_g(c$graph$prefLabel, uri)
  }
}

parse_req_g <- function(req, uri) {
  s <- str_extract_all(unlist(req),"^[0-9]+.*$") 
  sn <- unlist(s) # group can be empty
  if (length(sn) == 0) {
    sn <- "-"
  }
  df <- data.frame(sn, uri, stringsAsFactors = FALSE)
}


#-----------------------
# Finnish group names
#----------------------

fetch_fi_g <- function() {
  resp <- httr::GET(url = "https://api.finto.fi/rest/v1/yso/groups?lang=fi",
                    user_agent("https://github.com/tts/minatutkintweets"))
  
  c <- httr::content(resp, "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON() %>%
    purrr::map_if(is.null, ~ NA_character_)
  
  gl <- unlist(c$groups$prefLabel)
  gu <- unlist(c$groups$uri)
  g_df <- data.frame(gl, gu, stringsAsFactors = FALSE)
  
}

#-------------
# Plot theme
#-------------

do_theme <- function() {
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "grey10", color = NA),
    axis.text.x = element_text(size = 20, face = "bold", margin = margin(10, 0, 0, 0), color = "grey97"),
    plot.margin = margin(20, 5, 20, 5),
    plot.title = element_text(face = "bold", size = 30, color = "grey97"),
    plot.subtitle = element_text(size = 18, margin = margin(5, 0, 10, 0), color = "grey97"),
    plot.caption = element_text(size = 8, margin = margin(10, 0, 0, 0), color = "grey97")
  )
}

#------------
# Plot by day
#------------

do_g <- function(data) {
  ggplot(data = data, aes(x = day, y = n, fill = fct_reorder(group, n))) +
    geom_bar(stat = "identity", position = "fill", width = 1) +
    geom_text(aes(label = group, size = n), position = position_fill(vjust = 0.5), check_overlap = TRUE, color = "grey10") +
    scale_fill_viridis_d(option = "cividis") +
    scale_size_continuous(range = c(2, 5)) +
    scale_x_continuous(breaks = seq(6, 12, 1)) +
    coord_cartesian(expand = FALSE, clip = "off") +
    theme_void() + do_theme()
}
