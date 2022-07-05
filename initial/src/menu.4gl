
IMPORT FGL lib
&include "schema.inc"
MAIN
	DEFINE l_menu RECORD LIKE menus.*

	CALL lib.db_connect()

	DECLARE cur CURSOR FOR SELECT * FROM menus
	FOREACH cur INTO l_menu.*
		DISPLAY l_menu.m_text
	END FOREACH

	MENU
		COMMAND "Cust Maint"
			RUN "fglrun cust_mnt" WITHOUT WAITING
		COMMAND "Menu Maint"
			RUN "fglrun menu_mnt" WITHOUT WAITING
		COMMAND "Quit"
			EXIT MENU
		ON ACTION close
			EXIT MENU
	END MENU
	CALL lib.exit_program(0, "Program Finished")
END MAIN