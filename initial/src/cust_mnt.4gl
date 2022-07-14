IMPORT FGL fgldialog
IMPORT FGL lib
&include "schema.inc"

DEFINE m_arr    DYNAMIC ARRAY OF RECORD LIKE customers.*
DEFINE m_curRow SMALLINT
DEFINE m_where  STRING
MAIN
	DEFINE l_cust        RECORD LIKE customers.*
	DEFINE l_new         BOOLEAN = FALSE
	DEFINE l_dataChanged BOOLEAN = TRUE
	DEFINE l_mess        STRING
	DEFINE l_accept      BOOLEAN = FALSE
	CALL lib.db_connect()

	CALL ui.Interface.setText("Customers")
	CALL ui.Interface.setImage("fa-users")
	OPEN FORM f FROM "cust_mnt"
	DISPLAY FORM f
  OPTIONS INPUT WRAP

	LET m_where = " 1=1"

	DIALOG ATTRIBUTES(UNBUFFERED)
		DISPLAY ARRAY m_arr TO arr.*
			BEFORE DISPLAY
				CALL DIALOG.getForm().setElementHidden("group1", FALSE)
				LET l_new = FALSE
				IF l_dataChanged THEN
					CALL getData()
					LET l_dataChanged = FALSE
				END IF

			BEFORE ROW
				DISPLAY SFMT("Before Row %1", arr_curr())
				CALL setRow(DIALOG, arr_curr()) RETURNING l_cust.*

			ON ACTION find
				CALL doConstruct()
				CALL getData()
				CALL setRow(DIALOG, 1) RETURNING l_cust.*

			ON ACTION first
				CALL setRow(DIALOG, 1) RETURNING l_cust.*

			ON ACTION next
				IF m_curRow < m_arr.getLength() THEN
					CALL setRow(DIALOG, m_curRow + 1) RETURNING l_cust.*
				END IF

			ON ACTION previous
				IF m_curRow > 1 THEN
					CALL setRow(DIALOG, m_curRow - 1) RETURNING l_cust.*
				END IF

			ON ACTION last
				CALL setRow(DIALOG, m_arr.getLength()) RETURNING l_cust.*

			ON ACTION delete
				IF fgl_winQuestion("Confirm", "Delete row?", "No", "Yes|No", "question", 0) = "Yes" THEN
					DELETE FROM customers WHERE cust_code = m_arr[m_curRow].cust_code
					CALL getData()
					CALL setRow(DIALOG, 1) RETURNING l_cust.*
				END IF

			ON ACTION insert
				INITIALIZE l_cust.* TO NULL
				LET l_new = TRUE
				NEXT FIELD cust_code

			ON ACTION update
				NEXT FIELD cust_code

		END DISPLAY
		INPUT BY NAME l_cust.* ATTRIBUTE(WITHOUT DEFAULTS)
			BEFORE INPUT
				LET l_accept = FALSE
				LET int_flag = FALSE
				DISPLAY "Before Input"
				IF l_new THEN
					CALL DIALOG.setFieldActive("cust_code", TRUE)
				ELSE
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

			ON ACTION accept
				IF DIALOG.validate("customers.*") = 0 THEN
					LET l_accept = TRUE
					CALL DIALOG.accept()
				END IF

			ON ACTION cancel
				CALL DIALOG.cancel()

			AFTER INPUT
				DISPLAY SFMT("After Input int_flag: %1", int_flag)
				IF int_flag THEN
					MESSAGE "Cancelled"
					NEXT FIELD a_cust_code
				END IF
				IF NOT l_accept THEN
					MESSAGE "Aborted"
					NEXT FIELD a_cust_code
				END IF	
				IF l_new THEN
					INSERT INTO customers VALUES l_cust.*
				ELSE
					UPDATE customers SET customers.* = l_cust.* WHERE cust_code = l_cust.cust_code
				END IF
				IF sqlca.sqlcode = 0 THEN
					LET l_mess = SFMT("Customer '%1' %2.", l_cust.cust_code, IIF(l_new,"Inserted","Updated"))
					MESSAGE l_mess
				ELSE
					LET l_mess = SFMT("%1 of '%2' Failed: %3", IIF(l_new,"Insert","Update"), l_cust.cust_code, SQLERRMESSAGE)
					ERROR l_mess
				END IF
				CALL lib.log(l_mess)
				LET l_dataChanged = TRUE
				NEXT FIELD a_cust_code
		END INPUT

		ON ACTION quit
			EXIT DIALOG

		ON ACTION close
			EXIT DIALOG
	END DIALOG

	CALL lib.exit_program(0, "Program Finished")
END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION getData() RETURNS()
	DEFINE i      INT
	DEFINE l_stmt STRING
	LET l_stmt = SFMT("SELECT * FROM customers WHERE %1 ORDER BY cust_name", m_where)
	CALL m_arr.clear()
	DECLARE cur CURSOR FROM l_stmt
	FOREACH cur INTO m_arr[i := i + 1].*
	END FOREACH
	CALL m_arr.deleteElement(i)
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION setRow(d ui.Dialog, i INT) RETURNS( RECORD LIKE customers.* )
	LET m_curRow = i
	DISPLAY SFMT("Set Row %1", m_curRow)
	CALL d.setCurrentRow("arr", m_curRow)

	CALL d.setActionActive("previous", m_curRow > 1)
	CALL d.setActionActive("first", m_curRow > 1)
	CALL d.setActionActive("next", m_curRow < m_arr.getLength())
	CALL d.setActionActive("last", m_curRow < m_arr.getLength())
	DISPLAY SFMT("Row %1 of %2 Criteria: %3", m_curRow, m_arr.getLength(), IIF(m_where == " 1=1", "All", m_where)) TO stat
	RETURN m_arr[ m_curRow ].*
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION doConstruct() RETURNS()
	DEFINE l_where STRING
	DEFINE l_stmt  STRING
	DEFINE l_cnt   INT
	LET int_flag = FALSE
	CONSTRUCT BY NAME l_where ON customers.*
	IF int_flag THEN
		RETURN
	END IF
	LET l_stmt = SFMT("SELECT COUNT(*) FROM customers WHERE %1 ORDER BY cust_code", l_where)
	DISPLAY SFMT("SQL: %1", l_stmt)
	DECLARE cnt_cur CURSOR FROM l_stmt
	OPEN cnt_cur
	FETCH cnt_cur INTO l_cnt
	CLOSE cnt_cur
	IF l_cnt = 0 THEN
		ERROR "No Rows Found"
		LET l_where = " 1=1"
	END IF
	LET m_where = l_where
END FUNCTION
