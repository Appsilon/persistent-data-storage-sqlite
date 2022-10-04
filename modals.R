renderSaveDataModal <- function() {
  modalDialog(
    title = "Save Data",
    size = "s",
    footer = NULL,
    easyClose = TRUE,
    div(
      style = "width: 100%",
      textInput(
        inputId = "data_name",
        placeholder = "e.g.: My table",
        label = "Table Name"
      )
    ),
    div(
      style = "margin: 15px",
      actionButton(
        inputId = "close_modal",
        label = "Cancel",
        icon = icon("times"),
        class = "btn-danger btn-secondary"
      ),
      actionButton(
        inputId = "confirm_save_data",
        label = "Confirm",
        icon = icon("check"),
        class = "btn-success float-right",
        style = "position: absolute; right: 15px;"
      )
    )
  )
}

renderLoadDataModal <- function() {
  modalDialog(
    title = "Load Data",
    size = "m",
    footer = NULL,
    easyClose = TRUE,
    div(
      style = "width: 100%",
      reactableOutput("entries_table")
    ),
    div(
      style = "margin: 15px",
      actionButton(
        inputId = "close_modal",
        label = "Cancel",
        icon = icon("times"),
        class = "btn-danger btn-secondary"
      ),
      actionButton(
        inputId = "confirm_load_data",
        label = "Confirm",
        icon = icon("check"),
        class = "btn-success float-right",
        style = "position: absolute; right: 15px;"
      )
    )
  )
}
