;+
; Project     : HESSI
;
; Name        : SOCK_HEAD
;
; Purpose     : read a FITS header file via HTTP sockets end extract a
;               keyword value
;
; Category    : utility sockets fits
;
; Syntax      : IDL> value=sock_head(file,key)
;                   
; Inputs      : FILE = remote file name 
;               KEY = keyword to extract
;
; Outputs     : VALUE = keyword value
;
; Keywords    : ERR   = string error message
;
; History     : 26-April-2009, Zarro (ADNET) - written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function sock_head,file,key,err=err,_ref_extra=extra

if is_blank(key) or is_blank(file) then begin
 pr_syntax,'value=sock_head(file,key)'
 return,''
endif

sock_fits,file,data,header=header,/nodata,err=err
if is_string(err) then return,''

out=stregex(header,key+" *= *'?([^']+)'?.*",/extra,/fold,/sub)

value=''
chk=where(out[1,*] ne '',count)
if count gt 0 then value=out[1,chk[0]]
return,value[0]
end


