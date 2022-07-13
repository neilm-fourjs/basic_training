IMPORT FGL fgldialog
IMPORT os

DEFINE m_log_file STRING
DEFINE m_log      base.Channel
--------------------------------------------------------------------------------------------------------------
-- Connect to the default database.
FUNCTION db_connect()
	DEFINE l_db STRING

	LET l_db = fgl_getenv("DBNAME")
	IF l_db.getLength() < 1 THEN
		LET l_db = "training.db"
	END IF

	IF NOT os.Path.exists(l_db) THEN
		IF base.Application.getProgramName() != "mk_db" THEN
			RUN SFMT("fglrun mk_db %1", l_db)
		ELSE
			CALL show_error(SFMT("Database doesnt exist %1", l_db))
			EXIT PROGRAM
		END IF
	END IF

	TRY
		CONNECT TO l_db || "+driver='dbmsqt'"
	CATCH
		CALL show_error(SQLERRMESSAGE)
		EXIT PROGRAM
	END TRY
	CALL log(SFMT("Connected to %1", l_db))
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Exit the program and log the exit
FUNCTION exit_program(l_stat SMALLINT, l_msg STRING)
	CALL log(l_msg)
	CALL m_log.close()
	EXIT PROGRAM l_stat
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- A log a timestamped message.
FUNCTION log(l_msg STRING)
	IF m_log IS NULL THEN
		LET m_log_file = os.Path.join("..", "logs")
		IF NOT os.Path.exists(m_log_file) THEN
			IF NOT os.Path.mkdir(m_log_file) THEN
				CALL fgldialog.fgl_winMessage("Error", SFMT("Failed to mkdir %1", m_log_file), "exclamation")
				LET m_log_file = "." -- fall back to current dir!
			END IF
		END IF
		LET m_log_file = os.Path.join(m_log_file, SFMT("%1.log", base.Application.getProgramName()))
		LET m_log      = base.Channel.create()
		CALL m_log.openFile(m_log_file, "a+")
	END IF
	LET l_msg = SFMT("%1: %2", CURRENT, l_msg)
	CALL m_log.writeLine(l_msg)
	DISPLAY l_msg
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Show an error message and log that message.
FUNCTION show_error(l_err STRING)
	CALL log(l_err)
	CALL fgldialog.fgl_winMessage("Error", l_err, "exclamation")
END FUNCTION
--------------------------------------------------------------------------------------------------------------
--
FUNCTION pop_combo(l_cb ui.ComboBox)
	CASE l_cb.getColumnName()
		WHEN "disc_code"
			CALL l_cb.addItem("AA", "This is item 'AA'")
			CALL l_cb.addItem("BB", "This is item 'BB'")
			CALL l_cb.addItem("CC", "This is item 'CC'")
	END CASE
END FUNCTION
