# Fetch data from a database table
#
# This function fetches specified columns from a given table in the database.
#
# param conn A database connection object.
# param table_name The name of the table to query.
# param columns A vector of column names to select. Use "*" to select all columns.
# return A data frame containing the requested data.
fetch_table_data <- function(conn, view, table_name, columns = NULL) {
  if (!DBI::dbIsValid(conn)) {
    stop("The connection is not valid. Please check your connection.")
  }

  # Create the column list for the query
  columns_query <- paste(
    if (is.null(columns)) "*" else columns,
    collapse = ", "
  )

  # Create SQL query
  query <- sprintf("SELECT %s FROM %s.%s", columns_query, view, table_name)

  # Execute query and return result
  result <- DBI::dbGetQuery(conn, query)
  return(result)
}
