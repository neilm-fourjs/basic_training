IMPORT FGL lib
&include "schema.inc"

TYPE t_disp_menu RECORD
	key     LIKE menus.m_key,
	type    LIKE menus.m_type,
	name    LIKE menus.m_name,
	m_text  LIKE menus.m_text,
	m_child LIKE menus.m_child,
	m_cmd   LIKE menus.m_cmd,
	img     STRING
END RECORD
DEFINE m_menus     DYNAMIC ARRAY OF t_disp_menu
DEFINE m_menu      DYNAMIC ARRAY OF t_disp_menu
DEFINE m_menu_back LIKE menus.m_name
MAIN
	DEFINE x SMALLINT

	CALL lib.db_connect()

	CALL ui.Interface.setText("Menu")
	CALL ui.Interface.setImage("fa-navicon")

	DECLARE cur CURSOR FOR SELECT * FROM menus
	FOREACH cur INTO m_menus[x := x + 1].*
		CASE m_menus[x].type
			WHEN "M"
				LET m_menus[x].img = "fa-arrow-right"
			WHEN "F"
				LET m_menus[x].img = "fa-cog"
		END CASE
	END FOREACH
	CALL m_menus.deleteElement(x) -- delete the last empty row

	OPEN FORM f FROM "menu"
	DISPLAY FORM f

	CALL getMenu("main")
	DISPLAY ARRAY m_menu TO menu.* ATTRIBUTE(FOCUSONFIELD, CANCEL = FALSE, ACCEPT = FALSE)
		BEFORE DISPLAY
			CALL DIALOG.setCurrentRow("menu", m_menu.getLength() + 1)
		BEFORE ROW
			IF m_menu[arr_curr()].m_text IS NOT NULL THEN
				IF m_menu[arr_curr()].type = "F" THEN
					RUN SFMT("fglrun %1", m_menu[arr_curr()].m_cmd) WITHOUT WAITING
				END IF
				IF m_menu[arr_curr()].type = "M" THEN
					CALL getMenu(m_menu[arr_curr()].m_child)
				END IF
				IF m_menu[arr_curr()].type = "Q" THEN
					EXIT DISPLAY
				END IF
				IF m_menu[arr_curr()].type = "B" THEN
					CALL getMenu(m_menu_back)
				END IF
			END IF
			CALL DIALOG.setCurrentRow("menu", m_menu.getLength() + 1)
	END DISPLAY
	CALL lib.exit_program(0, "Program Finished")
END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION getMenu(l_name STRING)
	DEFINE x, y SMALLINT
	CALL m_menu.clear()
	FOR x = 1 TO m_menus.getLength()
		IF m_menus[x].name = l_name THEN
			IF m_menus[x].type = "T" THEN
				DISPLAY m_menus[x].m_text TO menu_title
			ELSE
				LET m_menu[y := y + 1].* = m_menus[x].*
			END IF
			IF m_menus[x].m_child IS NOT NULL THEN
				LET m_menu_back = m_menus[x].m_child
			END IF
		END IF
	END FOR
	IF l_name = "main" THEN
		LET m_menu[y := y + 1].m_text = "Exit Program"
		LET m_menu[y].type            = "Q"
		LET m_menu[y].img             = "fa-power-off"
	ELSE
		LET m_menu[y := y + 1].m_text = "Back"
		LET m_menu[y].type            = "B"
		LET m_menu[y].img             = "fa-arrow-left"
	END IF
	LET m_menu[y := y + 1].m_text = NULL -- hidden last row.
END FUNCTION
