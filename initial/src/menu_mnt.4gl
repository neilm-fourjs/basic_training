IMPORT FGL fgldialog
IMPORT FGL lib
&include "schema.inc"
MAIN
	DEFINE l_menu RECORD LIKE menus.*

	CALL lib.db_connect()

	DECLARE cur CURSOR FOR SELECT * FROM menus
	FOREACH cur INTO l_menu.*
		DISPLAY l_menu.m_text
	END FOREACH

	CALL fgldialog.fgl_winMessage("Welcome","Menu Maintenance","information")
	CALL lib.exit_program(0, "Program Finished")
END MAIN