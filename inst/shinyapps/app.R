# assemblykor Tutorial Launcher
# Deploy to shinyapps.io for browser-based access

library(shiny)

tutorials <- c(
  "01 R 기초와 tidyverse" = "01-tidyverse-basics",
  "02 데이터 시각화" = "02-data-visualization",
  "03 회귀분석" = "03-regression",
  "04 패널 데이터" = "04-panel-data",
  "05 텍스트 분석" = "05-text-analysis",
  "06 네트워크 분석" = "06-network-analysis",
  "07 표결 분석" = "07-roll-call-analysis",
  "08 법안 성공" = "08-bill-success",
  "09 발언 패턴" = "09-speech-patterns"
)

ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { font-family: -apple-system, 'Noto Sans KR', sans-serif; max-width: 800px; margin: 0 auto; padding: 40px; }
    h1 { color: #57068C; }
    .btn-tutorial { display: block; width: 100%; margin: 8px 0; padding: 15px 20px; text-align: left;
                    font-size: 16px; border: 2px solid #e0d6ec; border-radius: 8px; background: #fff; }
    .btn-tutorial:hover { background: #f5f0fa; border-color: #57068C; }
  "))),
  h1("assemblykor Tutorials"),
  p("한국 국회 데이터를 활용한 정치학 방법론 튜토리얼"),
  p(tags$a(href = "https://github.com/kyusik-yang/assemblykor", "GitHub"), " | ",
    tags$a(href = "https://kyusik-yang.github.io/assemblykor/", "Documentation")),
  hr(),
  uiOutput("tutorial_buttons")
)

server <- function(input, output, session) {
  output$tutorial_buttons <- renderUI({
    buttons <- lapply(seq_along(tutorials), function(i) {
      actionButton(
        inputId = paste0("tut_", i),
        label = names(tutorials)[i],
        class = "btn-tutorial"
      )
    })
    do.call(tagList, buttons)
  })

  lapply(seq_along(tutorials), function(i) {
    observeEvent(input[[paste0("tut_", i)]], {
      learnr::run_tutorial(tutorials[i], package = "assemblykor")
    })
  })
}

shinyApp(ui, server)
