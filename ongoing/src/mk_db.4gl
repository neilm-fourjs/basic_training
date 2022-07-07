IMPORT os
IMPORT FGL lib
&include "schema.inc"
DEFINE m_tabs DYNAMIC ARRAY OF STRING
MAIN
	DEFINE l_db STRING
	DEFINE c    base.Channel

	LET l_db = base.Application.getArgument(1)
	IF l_db.getLength() < 1 THEN
		LET l_db = fgl_getenv("DBNAME")
		IF l_db.getLength() < 1 THEN
			LET l_db = "training.db"
		END IF
	END IF

	IF NOT os.Path.exists(l_db) THEN
		CALL lib.log(1, SFMT("Create DB %1", l_db))
		LET c = base.Channel.create()
		CALL c.openFile(l_db, "a+")
		CALL c.close()
	END IF

	CALL lib.db_connect()

	LET m_tabs[1] = "menus"
	LET m_tabs[2] = "customers"

	CALL dropTables()
	CALL createTables()
	CALL insertTestData()

	CALL lib.exit_program(0, "Program Finished")
END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION dropTables()
	DEFINE x      SMALLINT
	DEFINE l_stmt STRING
	FOR x = 1 TO m_tabs.getLength()
		LET l_stmt = "DROP TABLE " || m_tabs[x]
		CALL lib.log(1, l_stmt)
		TRY
			EXECUTE IMMEDIATE l_stmt
		CATCH
			DISPLAY SQLERRMESSAGE
		END TRY
	END FOR
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION createTables()
	CALL lib.log(1, "Create Menus ...")
	CREATE TABLE menus(
			m_key SERIAL, m_type CHAR(1), m_name VARCHAR(8), m_text VARCHAR(50), m_child VARCHAR(8), m_cmd VARCHAR(50), m_args VARCHAR(50))

	CALL lib.log(1, "Create customers ...")
	CREATE TABLE customers(
			cust_code CHAR(8), cust_name VARCHAR(50), cont_name VARCHAR(50), email VARCHAR(50), disc_code CHAR(2),
			credit_limit DECIMAL(12, 2), total_invoices DECIMAL(12, 2), outstanding_amount DECIMAL(12, 2),
			addr_line1 VARCHAR(50), addr_line2 VARCHAR(50), addr_line3 VARCHAR(50), addr_line4 VARCHAR(50),
			postal_sort VARCHAR(10), country VARCHAR(3))

END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION insertTestData()

	CALL lib.log(1, "Loading Menus ...")
	CALL insMenu(0, "T", "main", "Main Menu", "", "", "")
	CALL insMenu(0, "M", "main", "Maintenance Programs", "maint", "", "")
	CALL insMenu(0, "M", "main", "Enquiry Programs", "enq", "", "")
	CALL insMenu(0, "T", "maint", "Maintenance Programs", "main", "", "")
	CALL insMenu(0, "F", "maint", "Menu Maintenance", "", "menu_mnt", "")
	CALL insMenu(0, "F", "maint", "Customer Maintenance", "", "cust_mnt", "")
	CALL insMenu(0, "T", "enq", "Enquiry Programs", "main", "", "")
	CALL insMenu(0, "F", "enq", "Customer Enquiry 1", "", "cust_mnt", "E")
	CALL insMenu(0, "F", "enq", "Customer Enquiry 2", "", "cust_mnt", "e")

	CALL lib.log(1, "Loading Customers ...")
	LOAD FROM "../etc/customers.unl" INSERT INTO customers
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION insMenu(l_menu RECORD LIKE menus.*)
	INSERT INTO menus VALUES l_menu.*
END FUNCTION
--------------------------------------------------------------------------------------------------------------
