library(shiny)
library(reactable)
library(dplyr)
library(shinyWidgets)
source("modals.R")
source("utils.R")

ui <- fluidPage(
    titlePanel("Persistent data storage"),
    sidebarLayout(
        sidebarPanel(
            numericInput(
                "n_rows",
                "Number of rows to display",
                min = 1,
                step = 1,
                max = nrow(mtcars),
                value = nrow(mtcars)
            ),
            pickerInput(
                "show_vars",
                "Columns to display",
                names(mtcars),
                selected = names(mtcars),
                multiple = TRUE,
                options = pickerOptions(
                    actionsBox = TRUE,
                    selectAllText = "All",
                    deselectAllText = "None",
                    noneSelectedText = "None"
                )
            ),
            actionButton("load_data", label = "Load Data", icon = icon("download")),
            actionButton("save_data", label = "Save Data", icon = icon("upload"))
        ),
        mainPanel(
            DT::DTOutput("table")
        )
    )
)

server <- function(input, output, session) {
    # Load last state on app init ----
    loaded_data <- get_last_data()

    observeEvent(loaded_data, {
        update_app_widgets(loaded_data)
    }, ignoreNULL = TRUE)

    # Create output table ----
    output$table <- DT::renderDT({
        shiny::validate(need(input$n_rows > 0, "Select at least 1 row."))
        mtcars %>%
            dplyr::select(input$show_vars) %>%
            dplyr::slice_head(n = input$n_rows)
    })

    # Save data ----
    observeEvent(input$save_data, {
        showModal(renderSaveDataModal())
    }, ignoreInit = TRUE)

    observeEvent(input$confirm_save_data, {
        save_data(
            create_unique_random_id(),
            get_data_list(input),
            input$data_name
        )
        removeModal()
    }, ignoreInit = TRUE)

    # Load data ----
    data_rows <- c()
    observeEvent(input$load_data, {
        data_rows <<- get_data_rows()
        output$entries_table <- renderReactable({
            reactable(
                data_rows,
                columns = list(
                    data = colDef(show = FALSE),
                    id = colDef(show = FALSE)
                ),
                selection = "single",
                onClick = "select",
                highlight = TRUE
            )
        })

        showModal(renderLoadDataModal())
    }, ignoreInit = TRUE)

    selected_entry <- reactive(getReactableState("entries_table", "selected"))
    observeEvent(input$confirm_load_data, {
        req(selected_entry())
        data_rows[selected_entry(), ] %>%
            pull(data) %>%
            jsonlite::fromJSON(.) %>%
            update_app_widgets()

        removeModal()
    }, ignoreInit = TRUE)

    # Close modals ----
    observeEvent(input$close_modal, {
        req(input$close_modal)
        removeModal()
    }, ignoreInit = TRUE)

    # Register callback to save last state and disconnect from DB upon end of R process ----
    onStop(function() {
        auto_save(get_data_list(input))
        RSQLite::dbDisconnect(DB_CONN)
        message("Disconnected from local DB")
    }, session = NULL)
}

shinyApp(ui = ui, server = server)
