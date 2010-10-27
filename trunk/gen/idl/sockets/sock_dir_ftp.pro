;+
; Project     : VSO
;
; Name        : SOCK_DIR_FTP
;
; Purpose     : Wrapper around IDLnetURL object to perform
;               directory listing via FTP
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_dir_ftp,url,out_list
;
; Inputs      : URL = remote URL directory name to list
;
; Outputs     : OUT_LIST = optional output variable to store list
;
; History     : 27-Dec-2009, Zarro (ADNET) - Written
;-

function sock_dir_ftp_callback, status, progress, data

xstatus,'Searching',wbase=wbase,cancelled=cancelled
if cancelled then xkill,wbase

print,status,progress

return,1 & end

;-------------------------------------------------------------------------

pro sock_dir_ftp,url,out_list,err=err,passive=passive,progress=progress,$
  username=username,password=password,_ref_extra=extra,verbose=verbose

err='' 
out_list=''

if is_blank(url) then begin
 pr_syntax,'sock_dir_ftp,url'
 return
endif

if ~since_version('6.4') then begin
 err='Requires IDL version 6.4 or greater.'
 message,err,/cont
 return
endif

verbose=keyword_set(verbose)
CATCH, errorStatus
IF (errorStatus NE 0) THEN BEGIN  
      CATCH, /CANCEL  
  
      ; Display the error msg in a dialog and at the IDL  
      ; command line.  
      if verbose then PRINT, !ERROR_STATE.msg  
  
      ; Get the properties more details about the error and  
      ; display at the IDL command line.  
      ourl->GetProperty, RESPONSE_CODE=rspCode, $  
         RESPONSE_HEADER=rspHdr, RESPONSE_FILENAME=rspFn  
      if verbose then begin
       PRINT, 'rspCode = ', rspCode  
       PRINT, 'rspHdr= ', rspHdr  
       PRINT, 'rspFn= ', rspFn  
      endif
      if obj_valid(ourl) then obj_destroy,ourl
      return
 ENDIF  
  
;-- parse keywords

stc=parse_url(url)
file=file_break(stc.path)
path=file_break(stc.path,/path)+'/'
if is_string(file) then path=path+file+'/'
user='anonymous'
pass='nobody'
if is_string(stc.username) then user=stc.username
if is_string(stc.password) then pass=stc.password
if is_string(username) then user=username
if is_string(password) then pass=password
url_scheme=stc.scheme
if is_blank(url_scheme) then url_scheme='ftp'
active=0
if is_number(passive) then active=1-passive 
ourl=obj_new('idlneturl')
callback_function=''
if keyword_set(progress) then callback_function='sock_dir_ftp_callback' 
ourl->setproperty,url_scheme=url_scheme,$
                  verbose=verbose,callback_function=callback_function,$
                  url_host=stc.host,url_username=user,url_password=pass,$
                  _extra=extra,ftp_connection_mode=active,url_path=path

;-- start listing 

out_list = ourl->getftpdirlist(/short,_extra=extra)

obj_destroy,ourl

;-- construct full URL

if (user ne 'anonymous') and is_string(pass) then $
 server='ftp://'+user+':'+pass+'@'+stc.host else $
  server='ftp://'+stc.host

out_list=server+'/'+path+out_list

return & end  
