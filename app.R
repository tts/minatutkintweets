library(shiny)
library(tidyverse)
library(lubridate)
library(httr)

data <- read_csv("cleaned_tweets_by_user.csv")

ui <- fluidPage(
  
  title = "#minätutkin-twiitit",
  
  titlePanel("Finto AI ehdottaa asiasanoja"),
  
  fluidRow(
    column(1,
           selectInput(inputId = "day",
                       label = "Päivä",
                       choices = sort(unique(day(data$created_at))),
                       multiple = FALSE,
                       selected = NULL)),
    column(11,
            selectizeInput(inputId = "tw",
                        label = "Twiitti",
                        choices = NULL,
                        multiple = FALSE,
                        selected = NULL,
                        width = "100%"))),
  fluidRow(
    column(2,
           sliderInput(inputId = "nr",
                       label = "Asiasanoja (kpl)",
                       min = 1,
                       max = 10,
                       value = 3,
                       step = 1))
  ),
  fluidRow(
    column(1,
          actionButton("do", "Hae!"),
    )
  ),
  fluidRow(
    column(8,
           tableOutput("kw"))
    )
  )
  
 
server <- function(input, output, session) {
  
  # Filter tweets by selected day
  day_selected <- reactive({
      data %>% filter(day(created_at) == input$day)
  })

  # Update the list of selectable tweets based on the day
  observeEvent(day_selected(), {
    choices <- day_selected()$alltext
    #updateSelectInput(inputId = 'tw', choices = choices)
    updateSelectizeInput(session, inputId = 'tw', choices = choices, server = TRUE)
    })
  
  # Filter tweets by text
  tw_selected <- reactive({
    req(input$tw)
    filter(day_selected(), alltext == input$tw)
  })
  
  # When the button is clicked
  observeEvent(input$do, {
    
    parse_req <- function(req) {
      tibble::tibble(
        label = list(tibble::as_tibble(req$results$label)),
        label_score = list(tibble::as_tibble(req$results$score)),
        label_uri = list(tibble::as_tibble(req$results$uri))
      )
    }
    
    unnest_req <- function(r) {
      r %>% 
        dplyr::select(
          -.data$label$value,
          -.data$label_score$value, 
          -.data$label_uri$value
        ) %>%
        tidyr::unnest(c(.data$label, .data$label_score, .data$label_uri), names_repair = "universal",
                      keep_empty = TRUE) %>% 
        rename(asiasana = `value...1`,
               score = `value...2`,
               uri = `value...3`)
    }
    
    tw_text <- tw_selected() %>% 
      select(alltext) %>% 
      as.character()
    
    tw_lang <- tw_selected() %>% 
      select(lang) %>% 
      as.character()
    
    project <- ifelse(tw_lang == "fi", "yso-fi",
                      ifelse(tw_lang == "sv", "yso-sv",
                             "yso-en"))
    
    # API call
    req <- httr::RETRY(verb = "POST",
                        url = paste0("https://ai.finto.fi/v1/projects/", project, "/suggest"),
                        body = list(text = tw_text, limit = input$nr, lang = tw_lang),
                        user_agent("https://github.com/tts/minatutkintweets"))
    
    # Parse result to a tibble
    r <- if (httr::status_code(req) != 200) {
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
      httr::content(req, "text", encoding = "UTF-8") %>%
        jsonlite::fromJSON() %>%
        purrr::map_if(is.null, ~ NA_character_) %>%
        parse_req()
    }
    
    # Unndest result from tibble to dataframe
    req_parsed <-  unnest_req(r)
    
    output$kw <- renderTable(req_parsed)
    
  })

}


shinyApp(ui = ui, server = server)
