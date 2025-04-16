# Close a database connection
#
# This function closes a database connection if it is still active.
#
# param conn A database connection object.
# return None. Prints a message about the connection status.

close_connection <- function(conn) {
  if (DBI::dbIsValid(conn)) {
    DBI::dbDisconnect(conn)
    message("Verbindung wurde erfolgreich geschlossen.")
  } else {
    message("Die Verbindung ist bereits geschlossen oder ungültig.")
  }
}
