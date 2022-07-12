IMPORT FGL lib
IMPORT FGL lookup
&include "schema.inc"

DEFINE m_cust       RECORD LIKE customers.*
DEFINE m_cnt, m_row INTEGER
MAIN
	DEFINE l_mode       CHAR(1)
	DEFINE l_lookup     lookup.lookup
	DEFINE l_rowActions STRING
	DEFINE l_form       ui.Form

	CALL lib.init()
	CALL lib.db_connect()

	LET l_lookup.sql_count    = "SELECT COUNT(*) FROM customers"
	LET l_lookup.columnTitles = "Code,Name,Address"
	LET l_lookup.sql_getData  = "SELECT cust_code, cust_name, addr_line1 FROM customers ORDER BY cust_name"
	LET l_lookup.windowTitle  = "Customers"

	LET l_mode           = base.Application.getArgument(2)
	LET m_cust.cust_code = base.Application.getArgument(3)
	IF l_mode IS NULL THEN LET l_mode = "." END IF

	IF m_cust.cust_code IS NOT NULL THEN
		CALL ui.Interface.setText(SFMT("Cust: %1", m_cust.cust_code))
		CALL ui.Interface.setImage("fa-user")
	ELSE
		CALL ui.Interface.setText("Customers")
		CALL ui.Interface.setImage("fa-users")
	END IF

	IF l_mode = "e" THEN
		LET m_cust.cust_code = "."
		WHILE m_cust.cust_code IS NOT NULL
			LET m_cust.cust_code = l_lookup.lookup()
			IF m_cust.cust_code IS NOT NULL THEN
				RUN SFMT("fglrun cust_mnt %1 X %2", base.Application.getArgument(1), m_cust.cust_code) WITHOUT WAITING
			END IF
		END WHILE
		EXIT PROGRAM
	END IF

	OPEN FORM c FROM "cust_mnt"
	DISPLAY FORM c

	IF l_mode = "E" THEN
		LET m_cust.cust_code = l_lookup.lookup()
	END IF
	IF l_mode = "X" THEN
		LET l_form = ui.Window.getCurrent().getForm()
		CALL l_form.setElementHidden("lookup", TRUE)
		CALL l_form.setElementHidden("search", TRUE)
		CALL l_form.setElementHidden("first", TRUE)
		CALL l_form.setElementHidden("last", TRUE)
		CALL l_form.setElementHidden("next", TRUE)
		CALL l_form.setElementHidden("previous", TRUE)
	END IF
	LET l_rowActions = "update|delete"
	DISPLAY "Actions: ", l_rowActions

	LET m_cnt = 0
	LET m_row = 0
	IF m_cust.cust_code IS NOT NULL THEN
		SELECT * INTO m_cust.* FROM customers WHERE cust_code = m_cust.cust_code
		DISPLAY BY NAME m_cust.*
		LET m_row = 1
	END IF

	MENU
		BEFORE MENU
			CALL DIALOG.setActionActive("lookup", (l_mode!="X"))
			CALL DIALOG.setActionActive("search", (l_mode!="X"))
			CALL lib.setActions(DIALOG, m_cnt, m_row, l_rowActions)
		ON ACTION lookup
			LET m_cust.cust_code = l_lookup.lookup()
			IF m_cust.cust_code IS NOT NULL THEN
				SELECT * INTO m_cust.* FROM customers WHERE cust_code = m_cust.cust_code
				DISPLAY BY NAME m_cust.*
				CALL ui.Interface.setText("Customers")
				CALL ui.Interface.setImage("fa-users")
				LET m_cnt = 0
				LET m_row = 1
				CALL lib.setActions(DIALOG, m_cnt, m_row, l_rowActions)
			END IF
		ON ACTION search
			CALL doConstruct()
			CALL lib.setActions(DIALOG, m_cnt, m_row, l_rowActions)
		ON ACTION first
			CALL navi("f")
			CALL lib.setActions(DIALOG, m_cnt, m_row, l_rowActions)
		ON ACTION next
			CALL navi("n")
			CALL lib.setActions(DIALOG, m_cnt, m_row, l_rowActions)
		ON ACTION previous
			CALL navi("p")
			CALL lib.setActions(DIALOG, m_cnt, m_row, l_rowActions)
		ON ACTION last
			CALL navi("l")
			CALL lib.setActions(DIALOG, m_cnt, m_row, l_rowActions)

		ON ACTION delete
			CALL doDelete()
		ON ACTION insert
			CALL doInput(TRUE)
		ON ACTION update
			CALL doInput(FALSE)
		ON ACTION about
			CALL lib.about()
		ON ACTION close
			EXIT MENU
		ON ACTION quit
			EXIT MENU

		COMMAND "Test Item" MESSAGE "Test Menu Item"
	END MENU

	CALL lib.exit_program(0, "Program Finished")
END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION doDelete() RETURNS()
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION doInput(l_new BOOLEAN) RETURNS()
	DEFINE l_cust RECORD LIKE customers.*
	LET int_flag = FALSE
	IF NOT l_new THEN
		LET l_cust.* = m_cust.*
	ELSE
		LET l_cust.total_invoices     = 0
		LET l_cust.outstanding_amount = 0
		LET l_cust.credit_limit       = 1000
	END IF
	INPUT BY NAME l_cust.* ATTRIBUTES(WITHOUT DEFAULTS)
		BEFORE INPUT
			IF NOT l_new THEN
				CALL DIALOG.setFieldActive("cust_code", FALSE)
			END IF
		AFTER FIELD cust_code
			IF l_new THEN
				SELECT * FROM customers WHERE cust_code = l_cust.cust_code
				IF STATUS != NOTFOUND THEN
					ERROR SFMT("Customer code '%1' already exist!", l_cust.cust_code)
					NEXT FIELD cust_code
				END IF
			END IF
		ON ACTION test ATTRIBUTES(TEXT="Test Action") MESSAGE "Test Action" 
	END INPUT
	IF int_flag THEN
		RETURN
	END IF
	LET m_cust.* = l_cust.*
	IF l_new THEN
		INSERT INTO customers VALUES m_cust.*
	ELSE
		UPDATE customers SET customers.* = m_cust.* WHERE cust_code = m_cust.cust_code
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION doConstruct() RETURNS()
	DEFINE l_where STRING
	DEFINE l_stmt  STRING

	LET int_flag = FALSE
	CONSTRUCT BY NAME l_where ON customers.*
	IF int_flag THEN
		RETURN
	END IF
	LET l_stmt = SFMT("SELECT COUNT(*) FROM customers WHERE %1", l_where)
	DECLARE cust_cnt_cur CURSOR FROM l_stmt
	OPEN cust_cnt_cur
	FETCH cust_cnt_cur INTO m_cnt
	IF m_cnt > 0 THEN
		LET l_stmt = SFMT("SELECT cust_code FROM customers WHERE %1", l_where)
		DECLARE cust_cur SCROLL CURSOR FROM l_stmt
		OPEN cust_cur
		CALL navi("f")
	END IF
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION navi(l_dir CHAR(1)) RETURNS()
	DEFINE l_cust_code LIKE customers.cust_code
	IF m_cnt = 0 THEN
		RETURN
	END IF
	CASE l_dir
		WHEN "f"
			FETCH FIRST cust_cur INTO l_cust_code
			IF STATUS = 0 THEN
				LET m_row = 1
			END IF
		WHEN "n"
			FETCH NEXT cust_cur INTO l_cust_code
			IF STATUS = 0 THEN
				LET m_row = m_row + 1
			END IF
		WHEN "p"
			FETCH PREVIOUS cust_cur INTO l_cust_code
			IF STATUS = 0 THEN
				LET m_row = m_row - 1
			END IF
		WHEN "l"
			FETCH LAST cust_cur INTO l_cust_code
			IF STATUS = 0 THEN
				LET m_row = m_cnt
			END IF
	END CASE
	IF STATUS = 0 THEN
		SELECT * INTO m_cust.* FROM customers WHERE cust_code = l_cust_code
		IF STATUS = NOTFOUND THEN
			ERROR "Row has been deleted!"
		END IF
	END IF
	DISPLAY BY NAME m_cust.*
	DISPLAY SFMT("Customer %1 of %2", m_row, m_cnt) TO stat
END FUNCTION
