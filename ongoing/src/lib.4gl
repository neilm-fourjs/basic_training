IMPORT FGL fgldialog
IMPORT os

DEFINE m_log_file STRING
DEFINE m_log base.Channel
PUBLIC DEFINE m_mdi BOOLEAN = FALSE
--------------------------------------------------------------------------------------------------------------
-- Connect to the default database.
FUNCTION db_connect() RETURNS ()
	DEFINE l_db STRING

	LET l_db = fgl_getenv("DBNAME")
	IF l_db.getLength() < 1 THEN
		LET l_db = "training.db"
	END IF

	IF NOT os.Path.exists(l_db) THEN
		IF base.Application.getProgramName() != "mk_db" THEN
			RUN SFMT("fglrun mk_db %1", l_db)
		ELSE
			CALL showError(SFMT("Database doesnt exist %1", l_db))
			EXIT PROGRAM
		END IF
	END IF

	TRY
		CONNECT TO l_db || "+driver='dbmsqt'"
	CATCH
		CALL showError(SQLERRMESSAGE)
		EXIT PROGRAM
	END TRY
	CALL log(1, SFMT("Connected to %1",l_db))
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Initialize the program environment
FUNCTION init()
	DEFINE l_contName STRING
	DEFINE n om.DomNode
	IF base.Application.getArgument(1) = "M" THEN
		IF base.Application.getProgramName() = "menu" THEN
			LET l_contName = SFMT("cont%1",fgl_getpid())
			CALL fgl_setenv("CONTAINER",l_contName)
			CALL ui.Interface.setType("container")
			CALL ui.Interface.setName(l_contName)
			CALL log(1, SFMT("Program is MDI Container, name: '%1'", l_contName))
			LET m_mdi = TRUE
		ELSE
			LET l_contName = fgl_getenv("CONTAINER")
			IF l_contName.getLength() < 1 THEN
				CALL log(1, "Program passed 'M' but no container name is set, so working SDI.")
			ELSE
				CALL ui.Interface.setType("child")
				CALL ui.Interface.setContainer(l_contName)
				CALL log(1, SFMT("Program is MDI Child, Container is '%1'", l_contName))
				LET m_mdi = TRUE
			END IF
		END IF
	ELSE
		CALL log(1, "Program is SDI")
	END IF
-- change the style name to handle MDI / SDI styles
	LET n = ui.Interface.getRootNode().selectByPath(SFMT("//Style[@name='UserInterface.%1']",IIF(m_mdi,"mdi","sdi"))).item(1)
	IF n IS NOT NULL THEN
		CALL n.setAttribute("name","UserInterface")
	ELSE
		CALL log(0, "Failed to find UserInterface style")
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Exit the program and log the exit
FUNCTION exit_program(l_stat SMALLINT, l_msg STRING) RETURNS ()
	CALL log(1, l_msg )
	CALL m_log.close()
	EXIT PROGRAM l_stat
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- A log a timestamped message.
FUNCTION log(l_lev SMALLINT, l_msg STRING) RETURNS () 
	IF m_log IS NULL THEN
		LET m_log_file = os.Path.join("..","logs")
		IF NOT os.Path.exists( m_log_file ) THEN
			IF NOT os.Path.mkdir( m_log_file ) THEN
				CALL fgldialog.fgl_winMessage("Error", SFMT("Failed to mkdir %1", m_log_file), "exclamation")
				LET m_log_file = "." -- fall back to current dir!
			END IF
		END IF
		LET m_log_file = os.Path.join(m_log_file, SFMT("%1.log", base.Application.getProgramName()))
		LET m_log = base.Channel.create()
		CALL m_log.openFile(m_log_file, "a+")
	END IF
	LET l_msg = SFMT("%1: %2", CURRENT, l_msg)
	CALL m_log.writeLine(l_msg)
	DISPLAY SFMT("%1:%2", base.Application.getProgramName(),l_msg)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- Show an error message and log that message.
FUNCTION showError(l_err STRING) RETURNS ()
	CALL log(0, l_err )
	CALL fgldialog.fgl_winMessage("Error", l_err, "exclamation")
END FUNCTION
