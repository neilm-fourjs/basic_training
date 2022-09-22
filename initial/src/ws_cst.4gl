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
		(title: "customerService", description: "A RESTFUL backend for the basicTraining demo - cst", version: "v1.0",
				contact:(name: "Neil J Martin", email: "neilm@4js.com"), modules:["One", "Two", "Three"])

TYPE t_cst RECORD
	customer RECORD LIKE customers.*,
	messsage STRING
END RECORD

PUBLIC DEFINE wsCustError RECORD ATTRIBUTE(WSError = "WSCustError")
	host    STRING,
	status  SMALLINT,
	message STRING
END RECORD

--------------------------------------------------------------------------------------
-- Return a cust item
PUBLIC FUNCTION getCust(custCode STRING ATTRIBUTE(WSParam))
		ATTRIBUTES(WSGet, WSPath = "/get/{custCode}", WSDescription = "Returns requested customer",
				WSThrows = "404:@wsCustError")
		RETURNS t_cst
	DEFINE l_cst t_cst
	CALL logging.logIt("get", SFMT("Getting '%1'.", custCode))
	SELECT * INTO l_cst.customer.* FROM customers WHERE cust_code = custCode
	IF STATUS = NOTFOUND THEN
		INITIALIZE l_cst.customer TO NULL
		LET l_cst.messsage = "Customer Not Found"
		CALL setCustError(404, l_cst.messsage)
	ELSE
		LET l_cst.messsage = "Record Found"
	END IF
	RETURN l_cst
END FUNCTION

--------------------------------------------------------------------------------
FUNCTION setCustError(l_stat SMALLINT, l_msg STRING)
	LET wsCustError.host    = fgl_getenv("HOSTNAME")
	LET wsCustError.status  = l_stat
	LET wsCustError.message = l_msg
	CALL com.WebServiceEngine.SetRestError(l_stat, wsCustError)
END FUNCTION
