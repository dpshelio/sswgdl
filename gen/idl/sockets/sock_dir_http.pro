;+
; Project     : VSO
;
; Name        : SOCK_DIR_HTTP
;
; Purpose     : Wrapper around SOCK_FIND to perform
;               directory listing via HTTP
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_dir_http,url,out_list
;
; Inputs      : URL = remote URL directory name to list
;
; Outputs     : OUT_LIST = optional output variable to store list
;
; History     : 27-Dec-2009, Zarro (ADNET) - Written
;-

pro sock_dir_http,url,out_list,_ref_extra=extra

out_list=''
if is_blank(url) then begin
 pr_syntax,'sock_dir_http,url'
 return
endif

;-- parse keywords

stc=url_parse(url)
file=file_break(stc.path)
path=file_break(stc.path,/path)+'/'
if is_string(file) then path=path+file+'/'
url_scheme=stc.scheme
if is_blank(url_scheme) then url_scheme='http'

;-- perform listing

out_list=sock_find(stc.host,'*',path=path,_extra=extra)

return & end  
