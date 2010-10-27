;+
; Project     : VSO
;
; Name        : SOCK_CHECK
;
; Purpose     : Check if URL file exists by sending a GET request for it
;
; Category    : utility system sockets
;
; Syntax      : IDL> chk=sock_check(url)
;
; Inputs      : URL = remote URL file name to check
;
; Outputs     : CHK = 1 or 0 if exists or not
;
; Keywords    : RESPONSE = server response
;
; History     : 10-March-2010, Zarro (ADNET) - Written
;-

function sock_check,url,response=response,_ref_extra=extra

response=''
if is_blank(url) then return,0b
durl=strtrim(url,2)

http=obj_new('http')
chk=http->file_found(durl,response,_extra=extra)
obj_destroy,http

return,chk

end
