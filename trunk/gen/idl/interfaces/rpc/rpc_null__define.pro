; ------------------------------------------------------------------------------------------------

FUNCTION rpc_null::xdr_data, xdr

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_null::is_router

RETURN, 0

END

; ------------------------------------------------------------------------------------------------

FUNCTION rpc_null::init

RETURN, 1

END

; ------------------------------------------------------------------------------------------------

PRO rpc_null::cleanup

RETURN

END

; ------------------------------------------------------------------------------------------------

PRO rpc_null__define

struct = {RPC_NULL, empty_data_struct: 0}

RETURN

END

