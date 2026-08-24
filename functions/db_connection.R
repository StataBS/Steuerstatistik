# Create a database connection
#
# This function creates either:
# - a local SQLite connection for the public/test environment, or
# - an ODBC connection for the productive environment.
#
# The connection type is controlled by `db_mode` from config.R.
#
# The connection is automatically closed after 1 hour (3600 seconds)
# if it is still valid.
#
# return A database connection object.

db_connection <- function() {

  if (db_mode == "sqlite") {

    conn <- DBI::dbConnect(
      RSQLite::SQLite(),
      ":memory:"
    )

    DBI::dbExecute(
      conn,
      sprintf("ATTACH DATABASE '%s' AS sas", sqlite_sas)
    )

    DBI::dbExecute(
      conn,
      sprintf("ATTACH DATABASE '%s' AS sasqst", sqlite_sasqst)
    )

    DBI::dbExecute(
      conn,
      sprintf("ATTACH DATABASE '%s' AS JurP", sqlite_jurp)
    )

    message("SQLite-Beispieldatenbanken verbunden.")

    later::later(
      function() {
        if (DBI::dbIsValid(conn)) {
          DBI::dbDisconnect(conn)
          message("Verbindung wurde automatisch nach 1 Stunde geschlossen.")
        }
      },
      3600
    )

    return(conn)
  }

  conn <- DBI::dbConnect(
    odbc::odbc(),
    Driver = driver,
    Server = server,
    Database = database,
    Trusted_Connection = "Yes"
  )

  message("Produktive Datenbank verbunden.")

  later::later(
    function() {
      if (DBI::dbIsValid(conn)) {
        DBI::dbDisconnect(conn)
        message("Verbindung wurde automatisch nach 1 Stunde geschlossen.")
      }
    },
    3600
  )

  return(conn)
}