
-- fglrestful -o ws_clistk.4gl https://generodemos.dynu.net/g/ws/r/wsbt/stk?openapi.json
IMPORT FGL ws_clistk

MAIN
	DEFINE l_ret SMALLINT
	DEFINE l_rec ws_clistk.t_stk

--	LET ws_clistk.Endpoint.Address.Uri = "http://localhost:8080/stk"
	LET ws_clistk.Endpoint.Address.Uri = "https://generodemos.dynu.net/g/ws/r/wsbt/stk"

	CALL ws_clistk.get("FR02") RETURNING l_ret, l_rec

	IF l_ret = C_WSSTOCKERROR THEN
		DISPLAY SFMT("Failed: %1 %2", ws_clistk.wsStockError.status, ws_clistk.wsStockError.message)
	ELSE
		DISPLAY SFMT("Status: %1 Desc: %2", l_ret, l_rec.stockItem.description)
	END IF

END MAIN