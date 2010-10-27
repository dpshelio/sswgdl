;+
; Project     : HESSI
;
; Name        : SOCK_LIST
;
; Purpose     : list remote WWW page via sockets
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_list,url,page
;                  
; Inputs      : URL = URL path to list [e.g. www.cnn.com]
;
; Opt. Outputs: PAGE= captured HTML 
;
; Keywords    : ERR   = string error message
;               CGI_BIN = set this if URL is a CGI_BIN command (faster)
;
; History     : 27-Dec-2001,  D.M. Zarro (EITI/GSFC)  Written
;               26-Dec-2003, Zarro (L-3Com/GSFC) - added FTP capability
;               23-Dec-2005, Zarro (L-3Com/GSFC) - removed COMMON
;               27-Dec-2009, Zarro (ADNET)
;                - piped FTP list thru sock_dir
;
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro sock_list,url,page,err=err,_ref_extra=extra

;--- start with error checking

err=''

spit=~arg_present(page)

if is_blank(url) then begin
 err='missing input URL'
 pr_syntax,'sock_list,url,page'
 return
endif

;-- check if using FTP

is_ftp=stregex(url,'ftp://',/bool)
if is_ftp then begin
 delvarx,page
 sock_dir,url,page
 if spit then print,page
 return
endif

;-- else use HTTP

http=obj_new('http',err=err)

http->hset,_extra=extra

http->list,url,page,_extra=extra,err=err 
if spit then print,page

obj_destroy,http

return

end


