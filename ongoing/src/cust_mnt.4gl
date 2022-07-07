IMPORT FGL lib
IMPORT FGL lookup
&include "schema.inc"

MAIN
	DEFINE l_cust   RECORD LIKE customers.*
	DEFINE l_mode   CHAR(1)
	DEFINE l_lookup lookup.lookup

	CALL lib.init()
	CALL lib.db_connect()

	CALL ui.Interface.setText("Customers")
	CALL ui.Interface.setImage("fa-users")

	LET l_mode           = base.Application.getArgument(2)
	LET l_cust.cust_code = base.Application.getArgument(3)

	OPEN FORM c FROM "cust_mnt"
	DISPLAY FORM c

	LET l_lookup.sql_count    = "SELECT COUNT(*) FROM customers"
	LET l_lookup.columnTitles = "Code,Name,Address"
	LET l_lookup.sql_getData  = "SELECT cust_code, cust_name, addr_line1 FROM customers ORDER BY cust_name"
	LET l_lookup.windowTitle  = "Customers"

	IF l_mode = "E" THEN
		LET l_cust.cust_code      = l_lookup.lookup()
	END IF

	IF l_cust.cust_code IS NOT NULL THEN
		SELECT * INTO l_cust.* FROM customers WHERE cust_code = l_cust.cust_code
		DISPLAY BY NAME l_cust.*
	END IF

	MENU
		ON ACTION lookup
			LET l_cust.cust_code      = l_lookup.lookup()
			IF l_cust.cust_code IS NOT NULL THEN
				SELECT * INTO l_cust.* FROM customers WHERE cust_code = l_cust.cust_code
				DISPLAY BY NAME l_cust.*
			END IF
		ON ACTION quit
			EXIT MENU
	END MENU

	CALL lib.exit_program(0, "Program Finished")
END MAIN
