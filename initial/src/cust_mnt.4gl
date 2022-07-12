IMPORT FGL fgldialog
IMPORT FGL lib
&include "schema.inc"

DEFINE m_arr    DYNAMIC ARRAY OF RECORD LIKE customers.*
DEFINE m_curRow SMALLINT
MAIN

	CALL lib.db_connect()

	CALL ui.Interface.setText("Customers")
	CALL ui.Interface.setImage("fa-users")
	OPEN FORM f FROM "cust_mnt"
	DISPLAY FORM f

	CALL getData()

	MENU
		BEFORE MENU
			CALL DIALOG.getForm().setElementHidden("group1", FALSE)
			CALL setRow(DIALOG, 1)

		ON ACTION insert
			IF doInput(TRUE) THEN
				CALL getData()
			END IF
		ON ACTION update
			IF doInput(FALSE) THEN
				CALL getData()
			END IF
		ON ACTION delete
			IF fgl_winQuestion("Confirm", "Delete row?", "No", "Yes|No", "question", 0) = "Yes" THEN
				DELETE FROM customers WHERE cust_code = m_arr[m_curRow].cust_code
				CALL getData()
				CALL setRow(DIALOG, 1)
			END IF

		ON ACTION find
			CALL constr()

		ON ACTION first
			CALL setRow(DIALOG, 1)

		ON ACTION next
			IF m_curRow < m_arr.getLength() THEN
				CALL setRow(DIALOG, m_curRow + 1)
			END IF

		ON ACTION previous
			IF m_curRow > 1 THEN
				CALL setRow(DIALOG, m_curRow - 1)
			END IF

		ON ACTION last
			CALL setRow(DIALOG, m_arr.getLength())

		ON ACTION quit
			EXIT MENU

		ON ACTION close
			EXIT MENU
	END MENU

	CALL lib.exit_program(0, "Program Finished")
END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION getData()
	DEFINE i INT
	CALL m_arr.clear()
	DECLARE cur CURSOR FOR SELECT * FROM customers ORDER BY cust_code
	FOREACH cur INTO m_arr[i := i + 1].*
	END FOREACH
	CALL m_arr.deleteElement(i)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION setRow(d ui.Dialog, i INT)
	LET m_curRow = i
	DISPLAY BY NAME m_arr[m_curRow].*
	CALL d.setActionActive("previous", m_curRow > 1)
	CALL d.setActionActive("first", m_curRow > 1)
	CALL d.setActionActive("next", m_curRow < m_arr.getLength())
	CALL d.setActionActive("last", m_curRow < m_arr.getLength())
	DISPLAY SFMT("Row %1 of %2", m_curRow, m_arr.getLength()) TO stat
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION doInput(l_new BOOLEAN) RETURNS BOOLEAN
	DEFINE l_cust RECORD LIKE customers.*
	IF NOT l_new THEN
		LET l_cust.* = m_arr[m_curRow].*
	END IF
	LET int_flag = FALSE
	INPUT BY NAME l_cust.* ATTRIBUTE(WITHOUT DEFAULTS)
		BEFORE INPUT
			IF NOT l_new THEN
				CALL DIALOG.setFieldActive("cust_code", FALSE)
			END IF
		AFTER FIELD cust_code
			IF l_new THEN
				SELECT * FROM customers WHERE cust_code = l_cust.cust_code
				IF STATUS != NOTFOUND THEN
					CALL lib.show_error(SFMT("Customer '%1' code already exists!", l_cust.cust_code CLIPPED))
					NEXT FIELD cust_code
				END IF
			END IF
	END INPUT
	IF int_flag THEN
		RETURN FALSE
	END IF
	IF l_new THEN
		INSERT INTO customers VALUES l_cust.*
	ELSE
		UPDATE customers SET customers.* = l_cust.* WHERE cust_code = l_cust.cust_code
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION constr()
END FUNCTION
