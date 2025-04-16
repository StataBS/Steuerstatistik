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
    .connection_string = connection_string
  )
  
  message("Verbindung erstellt. Sie wird automatisch nach 1 Stunde geschlossen.")
  
   # Automatic closure after 3600 seconds (1 hour)
  later::later(function() {
    if (dbIsValid(conn)) {
      dbDisconnect(conn)
      message("Verbindung wurde automatisch nach 1 Stunde geschlossen.")
    }
  }, 3600) # 3600 seconds = 1 hour
  
  return(conn)
}


