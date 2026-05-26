# Create a database connection with auto-close
#
# This function creates a database connection using a predefined connection string
# and automatically closes the connection after 1 hour (3600 seconds).
#
# param connection_string A string specifying the database connection.
# return A database connection object.

# Establish connection using the file DSN path
db_connection <- function() {
  conn <- dbConnect(
    odbc::odbc(),
    Driver = "ODBC Driver 18 for SQL Server",
    Server = Server,
    Database = Database,
    Trusted_Connection = "Yes",
    TrustServerCertificate = "Yes")

  return(conn)
}


