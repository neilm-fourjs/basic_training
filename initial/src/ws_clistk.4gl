#+
#+ Generated from ws_clistk
#+
IMPORT com
IMPORT util

#+
#+ Global Endpoint user-defined type definition
#+
TYPE tGlobalEndpointType RECORD # Rest Endpoint
	Address RECORD                # Address
		Uri STRING                  # URI
	END RECORD,
	Binding RECORD                      # Binding
		Version STRING,                   # HTTP Version (1.0 or 1.1)
		Cookie  STRING,                   # Cookie to be set
		Request RECORD                    # HTTP request
			Headers DYNAMIC ARRAY OF RECORD # HTTP Headers
				Name  STRING,
				Value STRING
			END RECORD
		END RECORD,
		Response RECORD                   # HTTP request
			Headers DYNAMIC ARRAY OF RECORD # HTTP Headers
				Name  STRING,
				Value STRING
			END RECORD
		END RECORD,
		ConnectionTimeout INTEGER, # Connection timeout
		ReadWriteTimeout  INTEGER, # Read write timeout
		CompressRequest   STRING   # Compression (gzip or deflate)
	END RECORD
END RECORD

PUBLIC DEFINE Endpoint tGlobalEndpointType = (Address:(Uri: "http://localhost:8080/stk"))

# Unexpected error details
PUBLIC DEFINE wsError RECORD
	code        INTEGER,
	description STRING
END RECORD

# Error codes
PUBLIC CONSTANT C_SUCCESS      = 0
PUBLIC CONSTANT C_WSSTOCKERROR = 1001

# components/schemas/stock
PUBLIC TYPE stock RECORD
	stock_code      STRING,
	stock_cat       STRING,
	pack_flag       STRING,
	supp_code       STRING,
	barcode         STRING,
	description     STRING,
	colour_code     INTEGER,
	price           DECIMAL(12, 2),
	cost            DECIMAL(12, 2),
	tax_code        STRING,
	disc_code       STRING,
	physical_stock  INTEGER,
	allocated_stock INTEGER,
	free_stock      INTEGER,
	long_desc       VARCHAR(100),
	img_url         VARCHAR(100)
END RECORD

# components/schemas/t_stk
PUBLIC TYPE t_stk RECORD
	stockItem stock,
	messsage  STRING
END RECORD

# generated wsStockErrorErrorType
PUBLIC TYPE wsStockErrorErrorType RECORD
	host    STRING,
	status  INTEGER,
	message STRING
END RECORD

# components/schemas/t_stkItems
PUBLIC TYPE t_stkItems RECORD
	items DYNAMIC ARRAY OF RECORD
		stock_code  STRING,
		description STRING
	END RECORD,
	no_of_item INTEGER
END RECORD

# components/schemas/t_serviceInfo
PUBLIC TYPE t_serviceInfo RECORD
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
END RECORD

PUBLIC # WSStockError
		DEFINE wsStockError wsStockErrorErrorType

################################################################################
# Operation /exit
#
# VERB: GET
# ID:          exit
# DESCRIPTION: Exit the service
#
PUBLIC FUNCTION exit() RETURNS(INTEGER, STRING)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE headerName  STRING
	DEFINE ind         INTEGER
	DEFINE req         com.HttpRequest
	DEFINE resp        com.HttpResponse
	DEFINE resp_body   STRING
	DEFINE txt         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.create()
		CALL fullpath.append("/exit")

		# Create request and configure it
		LET req = com.HttpRequest.Create(SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
		IF Endpoint.Binding.Version IS NOT NULL THEN
			CALL req.setVersion(Endpoint.Binding.Version)
		END IF
		IF Endpoint.Binding.Cookie IS NOT NULL THEN
			CALL req.setHeader("Cookie", Endpoint.Binding.Cookie)
		END IF
		IF Endpoint.Binding.Request.Headers.getLength() > 0 THEN
			FOR ind = 1 TO Endpoint.Binding.Request.Headers.getLength()
				CALL req.setHeader(Endpoint.Binding.Request.Headers[ind].Name, Endpoint.Binding.Request.Headers[ind].Value)
			END FOR
		END IF
		CALL Endpoint.Binding.Response.Headers.clear()
		IF Endpoint.Binding.ConnectionTimeout <> 0 THEN
			CALL req.setConnectionTimeOut(Endpoint.Binding.ConnectionTimeout)
		END IF
		IF Endpoint.Binding.ReadWriteTimeout <> 0 THEN
			CALL req.setTimeOut(Endpoint.Binding.ReadWriteTimeout)
		END IF
		IF Endpoint.Binding.CompressRequest IS NOT NULL THEN
			CALL req.setHeader("Content-Encoding", Endpoint.Binding.CompressRequest)
		END IF

		# Perform request
		CALL req.setMethod("GET")
		CALL req.setHeader("Accept", "text/plain")
		CALL req.doRequest()

		# Retrieve response
		LET resp = req.getResponse()
		# Process response
		INITIALIZE resp_body TO NULL
		LET contentType = resp.getHeader("Content-Type")
		CASE resp.getStatusCode()

			WHEN 200 #Success
				# Retrieve response runtime headers
				IF resp.getHeaderCount() > 0 THEN
					FOR ind = 1 TO resp.getHeaderCount()
						LET headerName = resp.getHeaderName(ind)
						CALL Endpoint.Binding.Response.Headers.appendElement()
						LET Endpoint.Binding.Response.Headers[Endpoint.Binding.Response.Headers.getLength()].Name = headerName
						LET Endpoint.Binding.Response.Headers[Endpoint.Binding.Response.Headers.getLength()].Value =
								resp.getHeader(headerName)
					END FOR
				END IF
				IF contentType MATCHES "*text/plain*" THEN
					# Parse TEXT response
					LET txt       = resp.getTextResponse()
					LET resp_body = txt
					RETURN C_SUCCESS, resp_body
				END IF
				LET wsError.code = resp.getStatusCode()
				LET wsError.code = "Unexpected Content-Type"
				RETURN -1, resp_body

			OTHERWISE
				LET wsError.code        = resp.getStatusCode()
				LET wsError.description = resp.getStatusDescription()
				RETURN -1, resp_body
		END CASE
	CATCH
		LET wsError.code        = status
		LET wsError.description = sqlca.sqlerrm
		RETURN -1, resp_body
	END TRY
END FUNCTION
################################################################################

################################################################################
# Operation /get/{stockCode}
#
# VERB: GET
# ID:          get
# DESCRIPTION: Returns requested stock item
#
PUBLIC FUNCTION get(p_stockCode STRING) RETURNS(INTEGER, t_stk)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE headerName  STRING
	DEFINE ind         INTEGER
	DEFINE req         com.HttpRequest
	DEFINE resp        com.HttpResponse
	DEFINE resp_body   t_stk
	DEFINE json_body   STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.create()
		CALL fullpath.append("/get/{stockCode}")
		CALL fullpath.replace("{stockCode}", util.Strings.urlEncode(p_stockCode), 1)

		# Create request and configure it
		LET req = com.HttpRequest.Create(SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
		IF Endpoint.Binding.Version IS NOT NULL THEN
			CALL req.setVersion(Endpoint.Binding.Version)
		END IF
		IF Endpoint.Binding.Cookie IS NOT NULL THEN
			CALL req.setHeader("Cookie", Endpoint.Binding.Cookie)
		END IF
		IF Endpoint.Binding.Request.Headers.getLength() > 0 THEN
			FOR ind = 1 TO Endpoint.Binding.Request.Headers.getLength()
				CALL req.setHeader(Endpoint.Binding.Request.Headers[ind].Name, Endpoint.Binding.Request.Headers[ind].Value)
			END FOR
		END IF
		CALL Endpoint.Binding.Response.Headers.clear()
		IF Endpoint.Binding.ConnectionTimeout <> 0 THEN
			CALL req.setConnectionTimeOut(Endpoint.Binding.ConnectionTimeout)
		END IF
		IF Endpoint.Binding.ReadWriteTimeout <> 0 THEN
			CALL req.setTimeOut(Endpoint.Binding.ReadWriteTimeout)
		END IF
		IF Endpoint.Binding.CompressRequest IS NOT NULL THEN
			CALL req.setHeader("Content-Encoding", Endpoint.Binding.CompressRequest)
		END IF

		# Perform request
		CALL req.setMethod("GET")
		CALL req.setHeader("Accept", "application/json")
		CALL req.doRequest()

		# Retrieve response
		LET resp = req.getResponse()
		# Process response
		INITIALIZE resp_body TO NULL
		LET contentType = resp.getHeader("Content-Type")
		CASE resp.getStatusCode()

			WHEN 200 #Success
				# Retrieve response runtime headers
				IF resp.getHeaderCount() > 0 THEN
					FOR ind = 1 TO resp.getHeaderCount()
						LET headerName = resp.getHeaderName(ind)
						CALL Endpoint.Binding.Response.Headers.appendElement()
						LET Endpoint.Binding.Response.Headers[Endpoint.Binding.Response.Headers.getLength()].Name = headerName
						LET Endpoint.Binding.Response.Headers[Endpoint.Binding.Response.Headers.getLength()].Value =
								resp.getHeader(headerName)
					END FOR
				END IF
				IF contentType MATCHES "*application/json*" THEN
					# Parse JSON response
					LET json_body = resp.getTextResponse()
					CALL util.JSON.parse(json_body, resp_body)
					RETURN C_SUCCESS, resp_body.*
				END IF
				LET wsError.code = resp.getStatusCode()
				LET wsError.code = "Unexpected Content-Type"
				RETURN -1, resp_body.*

			WHEN 404 #WSStockError
				IF contentType MATCHES "*application/json*" THEN
					# Parse JSON response
					LET json_body = resp.getTextResponse()
					CALL util.JSON.parse(json_body, wsStockError)
					RETURN C_WSSTOCKERROR, resp_body.*
				END IF
				LET wsError.code        = resp.getStatusCode()
				LET wsError.description = "Unexpected Content-Type"
				RETURN -1, resp_body.*

			OTHERWISE
				LET wsError.code        = resp.getStatusCode()
				LET wsError.description = resp.getStatusDescription()
				RETURN -1, resp_body.*
		END CASE
	CATCH
		LET wsError.code        = status
		LET wsError.description = sqlca.sqlerrm
		RETURN -1, resp_body.*
	END TRY
END FUNCTION
################################################################################

################################################################################
# Operation /getItems
#
# VERB: GET
# ID:          getItems
# DESCRIPTION: Returns requested stock items
#
PUBLIC FUNCTION getItems() RETURNS(INTEGER, t_stkItems)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE headerName  STRING
	DEFINE ind         INTEGER
	DEFINE req         com.HttpRequest
	DEFINE resp        com.HttpResponse
	DEFINE resp_body   t_stkItems
	DEFINE json_body   STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.create()
		CALL fullpath.append("/getItems")

		# Create request and configure it
		LET req = com.HttpRequest.Create(SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
		IF Endpoint.Binding.Version IS NOT NULL THEN
			CALL req.setVersion(Endpoint.Binding.Version)
		END IF
		IF Endpoint.Binding.Cookie IS NOT NULL THEN
			CALL req.setHeader("Cookie", Endpoint.Binding.Cookie)
		END IF
		IF Endpoint.Binding.Request.Headers.getLength() > 0 THEN
			FOR ind = 1 TO Endpoint.Binding.Request.Headers.getLength()
				CALL req.setHeader(Endpoint.Binding.Request.Headers[ind].Name, Endpoint.Binding.Request.Headers[ind].Value)
			END FOR
		END IF
		CALL Endpoint.Binding.Response.Headers.clear()
		IF Endpoint.Binding.ConnectionTimeout <> 0 THEN
			CALL req.setConnectionTimeOut(Endpoint.Binding.ConnectionTimeout)
		END IF
		IF Endpoint.Binding.ReadWriteTimeout <> 0 THEN
			CALL req.setTimeOut(Endpoint.Binding.ReadWriteTimeout)
		END IF
		IF Endpoint.Binding.CompressRequest IS NOT NULL THEN
			CALL req.setHeader("Content-Encoding", Endpoint.Binding.CompressRequest)
		END IF

		# Perform request
		CALL req.setMethod("GET")
		CALL req.setHeader("Accept", "application/json")
		CALL req.doRequest()

		# Retrieve response
		LET resp = req.getResponse()
		# Process response
		INITIALIZE resp_body TO NULL
		LET contentType = resp.getHeader("Content-Type")
		CASE resp.getStatusCode()

			WHEN 200 #Success
				# Retrieve response runtime headers
				IF resp.getHeaderCount() > 0 THEN
					FOR ind = 1 TO resp.getHeaderCount()
						LET headerName = resp.getHeaderName(ind)
						CALL Endpoint.Binding.Response.Headers.appendElement()
						LET Endpoint.Binding.Response.Headers[Endpoint.Binding.Response.Headers.getLength()].Name = headerName
						LET Endpoint.Binding.Response.Headers[Endpoint.Binding.Response.Headers.getLength()].Value =
								resp.getHeader(headerName)
					END FOR
				END IF
				IF contentType MATCHES "*application/json*" THEN
					# Parse JSON response
					LET json_body = resp.getTextResponse()
					CALL util.JSON.parse(json_body, resp_body)
					RETURN C_SUCCESS, resp_body.*
				END IF
				LET wsError.code = resp.getStatusCode()
				LET wsError.code = "Unexpected Content-Type"
				RETURN -1, resp_body.*

			WHEN 404 #WSStockError
				IF contentType MATCHES "*application/json*" THEN
					# Parse JSON response
					LET json_body = resp.getTextResponse()
					CALL util.JSON.parse(json_body, wsStockError)
					RETURN C_WSSTOCKERROR, resp_body.*
				END IF
				LET wsError.code        = resp.getStatusCode()
				LET wsError.description = "Unexpected Content-Type"
				RETURN -1, resp_body.*

			OTHERWISE
				LET wsError.code        = resp.getStatusCode()
				LET wsError.description = resp.getStatusDescription()
				RETURN -1, resp_body.*
		END CASE
	CATCH
		LET wsError.code        = status
		LET wsError.description = sqlca.sqlerrm
		RETURN -1, resp_body.*
	END TRY
END FUNCTION
################################################################################

################################################################################
# Operation /info
#
# VERB: GET
# ID:          info
# DESCRIPTION: Returns service info
#
PUBLIC FUNCTION info() RETURNS(INTEGER, t_serviceInfo)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE headerName  STRING
	DEFINE ind         INTEGER
	DEFINE req         com.HttpRequest
	DEFINE resp        com.HttpResponse
	DEFINE resp_body   t_serviceInfo
	DEFINE json_body   STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.create()
		CALL fullpath.append("/info")

		# Create request and configure it
		LET req = com.HttpRequest.Create(SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
		IF Endpoint.Binding.Version IS NOT NULL THEN
			CALL req.setVersion(Endpoint.Binding.Version)
		END IF
		IF Endpoint.Binding.Cookie IS NOT NULL THEN
			CALL req.setHeader("Cookie", Endpoint.Binding.Cookie)
		END IF
		IF Endpoint.Binding.Request.Headers.getLength() > 0 THEN
			FOR ind = 1 TO Endpoint.Binding.Request.Headers.getLength()
				CALL req.setHeader(Endpoint.Binding.Request.Headers[ind].Name, Endpoint.Binding.Request.Headers[ind].Value)
			END FOR
		END IF
		CALL Endpoint.Binding.Response.Headers.clear()
		IF Endpoint.Binding.ConnectionTimeout <> 0 THEN
			CALL req.setConnectionTimeOut(Endpoint.Binding.ConnectionTimeout)
		END IF
		IF Endpoint.Binding.ReadWriteTimeout <> 0 THEN
			CALL req.setTimeOut(Endpoint.Binding.ReadWriteTimeout)
		END IF
		IF Endpoint.Binding.CompressRequest IS NOT NULL THEN
			CALL req.setHeader("Content-Encoding", Endpoint.Binding.CompressRequest)
		END IF

		# Perform request
		CALL req.setMethod("GET")
		CALL req.setHeader("Accept", "application/json")
		CALL req.doRequest()

		# Retrieve response
		LET resp = req.getResponse()
		# Process response
		INITIALIZE resp_body TO NULL
		LET contentType = resp.getHeader("Content-Type")
		CASE resp.getStatusCode()

			WHEN 200 #Success
				# Retrieve response runtime headers
				IF resp.getHeaderCount() > 0 THEN
					FOR ind = 1 TO resp.getHeaderCount()
						LET headerName = resp.getHeaderName(ind)
						CALL Endpoint.Binding.Response.Headers.appendElement()
						LET Endpoint.Binding.Response.Headers[Endpoint.Binding.Response.Headers.getLength()].Name = headerName
						LET Endpoint.Binding.Response.Headers[Endpoint.Binding.Response.Headers.getLength()].Value =
								resp.getHeader(headerName)
					END FOR
				END IF
				IF contentType MATCHES "*application/json*" THEN
					# Parse JSON response
					LET json_body = resp.getTextResponse()
					CALL util.JSON.parse(json_body, resp_body)
					RETURN C_SUCCESS, resp_body.*
				END IF
				LET wsError.code = resp.getStatusCode()
				LET wsError.code = "Unexpected Content-Type"
				RETURN -1, resp_body.*

			OTHERWISE
				LET wsError.code        = resp.getStatusCode()
				LET wsError.description = resp.getStatusDescription()
				RETURN -1, resp_body.*
		END CASE
	CATCH
		LET wsError.code        = status
		LET wsError.description = sqlca.sqlerrm
		RETURN -1, resp_body.*
	END TRY
END FUNCTION
################################################################################

################################################################################
# Operation /status
#
# VERB: GET
# ID:          status
# DESCRIPTION: Returns status of service
#
PUBLIC FUNCTION status() RETURNS(INTEGER, STRING)
	DEFINE fullpath    base.StringBuffer
	DEFINE contentType STRING
	DEFINE headerName  STRING
	DEFINE ind         INTEGER
	DEFINE req         com.HttpRequest
	DEFINE resp        com.HttpResponse
	DEFINE resp_body   STRING
	DEFINE txt         STRING

	TRY

		# Prepare request path
		LET fullpath = base.StringBuffer.create()
		CALL fullpath.append("/status")

		# Create request and configure it
		LET req = com.HttpRequest.Create(SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
		IF Endpoint.Binding.Version IS NOT NULL THEN
			CALL req.setVersion(Endpoint.Binding.Version)
		END IF
		IF Endpoint.Binding.Cookie IS NOT NULL THEN
			CALL req.setHeader("Cookie", Endpoint.Binding.Cookie)
		END IF
		IF Endpoint.Binding.Request.Headers.getLength() > 0 THEN
			FOR ind = 1 TO Endpoint.Binding.Request.Headers.getLength()
				CALL req.setHeader(Endpoint.Binding.Request.Headers[ind].Name, Endpoint.Binding.Request.Headers[ind].Value)
			END FOR
		END IF
		CALL Endpoint.Binding.Response.Headers.clear()
		IF Endpoint.Binding.ConnectionTimeout <> 0 THEN
			CALL req.setConnectionTimeOut(Endpoint.Binding.ConnectionTimeout)
		END IF
		IF Endpoint.Binding.ReadWriteTimeout <> 0 THEN
			CALL req.setTimeOut(Endpoint.Binding.ReadWriteTimeout)
		END IF
		IF Endpoint.Binding.CompressRequest IS NOT NULL THEN
			CALL req.setHeader("Content-Encoding", Endpoint.Binding.CompressRequest)
		END IF

		# Perform request
		CALL req.setMethod("GET")
		CALL req.setHeader("Accept", "text/plain")
		CALL req.doRequest()

		# Retrieve response
		LET resp = req.getResponse()
		# Process response
		INITIALIZE resp_body TO NULL
		LET contentType = resp.getHeader("Content-Type")
		CASE resp.getStatusCode()

			WHEN 200 #Success
				# Retrieve response runtime headers
				IF resp.getHeaderCount() > 0 THEN
					FOR ind = 1 TO resp.getHeaderCount()
						LET headerName = resp.getHeaderName(ind)
						CALL Endpoint.Binding.Response.Headers.appendElement()
						LET Endpoint.Binding.Response.Headers[Endpoint.Binding.Response.Headers.getLength()].Name = headerName
						LET Endpoint.Binding.Response.Headers[Endpoint.Binding.Response.Headers.getLength()].Value =
								resp.getHeader(headerName)
					END FOR
				END IF
				IF contentType MATCHES "*text/plain*" THEN
					# Parse TEXT response
					LET txt       = resp.getTextResponse()
					LET resp_body = txt
					RETURN C_SUCCESS, resp_body
				END IF
				LET wsError.code = resp.getStatusCode()
				LET wsError.code = "Unexpected Content-Type"
				RETURN -1, resp_body

			OTHERWISE
				LET wsError.code        = resp.getStatusCode()
				LET wsError.description = resp.getStatusDescription()
				RETURN -1, resp_body
		END CASE
	CATCH
		LET wsError.code        = status
		LET wsError.description = sqlca.sqlerrm
		RETURN -1, resp_body
	END TRY
END FUNCTION
################################################################################
