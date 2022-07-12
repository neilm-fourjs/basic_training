IMPORT FGL fgldialog
IMPORT FGL lib
&include "schema.inc"
MAIN
	DEFINE l_cust RECORD LIKE customers.*

	CALL lib.db_connect()

	CALL ui.Interface.setText("Customers")
	CALL ui.Interface.setImage("fa-users")

	OPEN FORM f FROM "cust_mnt"
	DISPLAY FORM f

	DECLARE cur CURSOR FOR SELECT * FROM customers
	FOREACH cur INTO l_cust.*
		DISPLAY l_cust.cust_name
	END FOREACH

	DISPLAY BY NAME l_cust.*

	MENU
		ON ACTION changelab
			CALL ui.Window.getCurrent().getForm().setElementText("cust_code","This is a very long label")

		ON ACTION quit EXIT MENU
		ON ACTION close EXIT MENU
	END MENU

	CALL lib.exit_program(0, "Program Finished")
END MAIN