IMPORT FGL lib
&include "schema.inc"

TYPE t_disp_menu RECORD
	m_key   LIKE menus.m_key,
	m_type  LIKE menus.m_type,
	m_name  LIKE menus.m_name,
	m_text  LIKE menus.m_text,
	m_child LIKE menus.m_child,
	m_cmd   LIKE menus.m_cmd,
	m_args  LIKE menus.m_args,
	img     STRING
END RECORD
DEFINE m_menus     DYNAMIC ARRAY OF t_disp_menu
DEFINE m_menu      DYNAMIC ARRAY OF t_disp_menu
DEFINE m_menu_back LIKE menus.m_name
MAIN
	DEFINE x     SMALLINT
	DEFINE l_cmd STRING

	CALL lib.init()
	CALL lib.db_connect()

	CALL ui.Interface.setText("Menu")
	CALL ui.Interface.setImage("fa-navicon")

	DECLARE cur CURSOR FOR SELECT * FROM menus
	FOREACH cur INTO m_menus[x := x + 1].*
		CASE m_menus[x].m_type
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
	DISPLAY ARRAY m_menu TO menu.* ATTRIBUTE(UNBUFFERED, FOCUSONFIELD, CANCEL = FALSE, ACCEPT = FALSE)
		BEFORE DISPLAY
			CALL DIALOG.setCurrentRow("menu", m_menu.getLength() + 1)
		BEFORE ROW
			LET x = arr_curr()
			IF m_menu[x].m_text IS NOT NULL THEN
				CALL lib.log(1, SFMT("Before row %1 '%2'", x, m_menu[x].m_text))
				CASE m_menu[x].m_type
				  WHEN "F"
						LET l_cmd =
								SFMT("fglrun %1 %2 %3", m_menu[x].m_cmd, IIF(lib.m_mdi, "M", "S"), m_menu[x].m_args)
						RUN l_cmd WITHOUT WAITING
					WHEN "M"
						CALL getMenu(m_menu[arr_curr()].m_child)
				  WHEN "Q"
						EXIT DISPLAY
				  WHEN "B"
						CALL getMenu(m_menu_back)
				END CASE
			END IF
			CALL DIALOG.setCurrentRow("menu", m_menu.getLength() + 1)
		ON ACTION quit EXIT DISPLAY
		ON ACTION close EXIT DISPLAY
		ON ACTION about CALL lib.about()
	END DISPLAY
	CALL lib.exit_program(0, "Program Finished")
END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION getMenu(l_name STRING) RETURNS()
	DEFINE x, y SMALLINT
	CALL m_menu.clear()
	CALL lib.log(1, SFMT("Load menu '%1' ...", l_name))
	FOR x = 1 TO m_menus.getLength()
		IF m_menus[x].m_name = l_name THEN
			IF m_menus[x].m_type = "T" THEN
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
		LET m_menu[y].m_type          = "Q"
		LET m_menu[y].img             = "fa-power-off"
	ELSE
		LET m_menu[y := y + 1].m_text = "Back"
		LET m_menu[y].m_type          = "B"
		LET m_menu[y].img             = "fa-arrow-left"
	END IF
	LET m_menu[y := y + 1].m_text = NULL -- hidden last row.
END FUNCTION
