;+
; Project     : VSO
;
; Name        : SOCK_DIR
;
; Purpose     : Perform directory listing of files at a URL 
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_dir,url,out_list
;
; Inputs      : URL = remote URL directory to list
;
; Outputs     : OUT_LIST = optional output variable to store list
;
; History     : 27-Dec-2009, Zarro (ADNET) - Written
;-

pro sock_dir,url,out_list,_ref_extra=extra

out_list=''
stc=url_parse(url)
is_ftp=stregex(stc.scheme,'ftp',/bool)
is_http=stregex(stc.scheme,'http',/bool)
if ~is_ftp and ~is_http then is_http=1b
 
if is_ftp then sock_dir_ftp,url,out_list,_extra=extra else $
 sock_dir_http,url,out_list,_extra=extra

return & end
