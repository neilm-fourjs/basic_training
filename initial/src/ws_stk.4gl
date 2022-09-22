IMPORT FGL logging
IMPORT FGL ws_lib
IMPORT com

&include "schema.inc"

PUBLIC DEFINE serviceInfo RECORD ATTRIBUTES(WSInfo)
  title         STRING,
  description   STRING,
  termOfService STRING,
  contact RECORD
    name  STRING,
    url   STRING,
    email STRING
  END RECORD,
  version STRING,
  modules DYNAMIC ARRAY OF STRING
END RECORD =
    (title: "stockService", description: "A RESTFUL backend for the basicTraining demo - stk",
        version: "v1.0", contact:(name: "Neil J Martin", email: "neilm@4js.com"), modules:["One", "Two", "Three"])

TYPE t_stk RECORD
	stockItem RECORD LIKE stock.*,
	messsage  STRING
END RECORD

PUBLIC DEFINE wsError RECORD ATTRIBUTE(WSError = "WS Error")
  host    STRING,
  status  SMALLINT,
  message STRING
END RECORD

--------------------------------------------------------------------------------------
-- Return the status of the service
PUBLIC FUNCTION status() ATTRIBUTES(WSGet, WSPath = "/status", WSDescription = "Returns status of service")
		RETURNS STRING
	CALL logging.logIt("status", "Doing Status checks.")
	RETURN "Okay"
END FUNCTION
--------------------------------------------------------------------------------------
-- Return the version of the service
PUBLIC FUNCTION info() ATTRIBUTES(WSGet, WSPath = "/info", WSDescription = "Returns info")
		RETURNS t_serviceInfo
	CALL logging.logIt("version", "Return version.")
	RETURN serviceInfo
END FUNCTION
----------------------------------------------------------------------------------------------------
-- Just exit the service
FUNCTION exit() ATTRIBUTES(WSGet, WSPath = "/exit", WSDescription = "Exit the service") RETURNS STRING
	CALL logging.logIt("exit", "Stopping service.")
	LET ws_lib.m_stop = TRUE
	RETURN "Stopped"
END FUNCTION


--------------------------------------------------------------------------------------
-- Return the status of the service
PUBLIC FUNCTION get(stockCode STRING ATTRIBUTE(WSParam))
		ATTRIBUTES(WSGet, WSPath = "/get/{stockCode}", WSDescription = "Returns requested stock item",
WSThrows = "404:@wsError") RETURNS t_stk
	DEFINE l_stk t_stk
	CALL logging.logIt("get", SFMT("Getting '%1'.", stockCode))
	SELECT * INTO l_stk.stockItem.* FROM stock WHERE stock_code = stockCode
	IF STATUS = NOTFOUND THEN
		INITIALIZE l_stk.stockItem TO NULL
		LET l_stk.messsage = "Stock Item Not Found"
		CALL setError(404, l_stk.messsage)
	ELSE
		LET l_stk.messsage = "Record Found"
	END IF
	RETURN l_stk
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION setError(l_stat SMALLINT, l_msg STRING)
  LET wsError.host    = fgl_getenv("HOSTNAME")
  LET wsError.status  = l_stat
  LET wsError.message = l_msg
  CALL com.WebServiceEngine.SetRestError(l_stat, wsError)
END FUNCTION
