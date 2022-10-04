library(RSQLite)
library(jsonlite)

# Generate connection to local DB ----
DB_CONN <- RSQLite::dbConnect(
  RSQLite::SQLite(),
  "data/app_db.sqlite"
)

create_statement <- paste0(readLines("data/table_create.sql"), collapse = "")

RSQLite::dbExecute(
  conn = DB_CONN,
  statement = create_statement
)

# Get all entries ----
get_data_rows <- function() {
  DBI::dbGetQuery(
    conn = DB_CONN,
    statement = "SELECT * FROM app_data_storage WHERE id != ('last_data');"
  )
}

# Get latest (i.e., auto-saved) entry ----
get_last_data <- function() {
  last_data <- DBI::dbGetQuery(
    conn = DB_CONN,
    statement = "SELECT data FROM app_data_storage WHERE id = ('last_data');",
  ) %>%
    pull(data)

  if (!rlang::is_empty(last_data)) {
    last_data %>%
      jsonlite::fromJSON(.) %>%
      do.call(reactiveValues, .)
  } else {
    NULL
  }
}

update_app_widgets <- function(data) {
  updateNumericInput(
    inputId = "n_rows",
    value = data$n_rows
  )
  updatePickerInput(
    session = getDefaultReactiveDomain(),
    inputId = "show_vars",
    selected = data$show_vars
  )
}

# Save data ----
save_data <- function(unique_id, data, entry_name = "") {
  new_entry <- list(
    id = unique_id,
    data = jsonlite::toJSON(data),
    name = entry_name,
    timestamp = as.character(Sys.time())
  )

  values <- unlist(new_entry, use.names = FALSE)
  column_names <- purrr::map(names(new_entry), ~ DBI::Id(column = .x))

  insert_statement <- glue::glue_sql(
    "REPLACE INTO app_data_storage ({`column_names`*}) VALUES ({values*});",
    .con = DB_CONN
  )
  RSQLite::dbExecute(DB_CONN, insert_statement)
  message("Data was saved successfully!")
}

auto_save <- function(data) {
  save_data("last_data", data)
}

create_unique_random_id <- function() {
  paste0(paste(sample(letters, 10), collapse = ""), as.integer(Sys.time()))
}

get_data_list <- function(input) {
  list(
    show_vars = isolate(input$show_vars),
    n_rows = isolate(input$n_rows)
  )
}

drop_table <- function() {
  RSQLite::dbExecute(
    conn = DB_CONN,
    statement = "DROP TABLE app_data_storage;"
  )
}
