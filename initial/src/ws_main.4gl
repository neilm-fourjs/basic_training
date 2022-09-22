IMPORT FGL ws_lib
IMPORT FGL lib
IMPORT FGL logging

MAIN

	CALL lib.db_connect()

	CALL logging.logIt("MAIN", SFMT("Started - port: %1", fgl_getenv("FGLAPPSERVER")))

	DISPLAY SFMT("URL Example: http://localhost:%1/stk/status", fgl_getenv("FGLAPPSERVER"))

	IF NOT ws_lib.init("ws_stk", "stk") THEN
		EXIT PROGRAM
	END IF

	IF NOT ws_lib.init("ws_cst", "cst") THEN
		EXIT PROGRAM
	END IF

	CALL ws_lib.process()

	CALL logging.logIt("MAIN", "Finished")
END MAIN
