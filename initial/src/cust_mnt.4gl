IMPORT FGL fgldialog
IMPORT FGL lib
&include "schema.inc"
MAIN
	DEFINE l_cust RECORD LIKE customers.*

	CALL lib.db_connect()

	CALL ui.Interface.setText("Customers")
	CALL ui.Interface.setImage("fa-users")

	DECLARE cur CURSOR FOR SELECT * FROM customers
	FOREACH cur INTO l_cust.*
		DISPLAY l_cust.cust_name
	END FOREACH

	CALL fgldialog.fgl_winMessage("Welcome","Customer Maintenance","information")

	CALL lib.exit_program(0, "Program Finished")
END MAIN