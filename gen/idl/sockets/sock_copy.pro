;+                                                                              
; Project     : HESSI                                                           
;                                                                               
; Name        : SOCK_COPY                                                       
;                                                                               
; Purpose     : copy file via HTTP sockets                                      
;                                                                               
; Category    : utility system sockets                                          
;                                                                               
; Syntax      : IDL> sock_copy,url_file,outdir=outdir                           
;                                                                               
; Inputs      : URL_FILE = remote file name to copy with URL path               
;               OUT_NAME = optional output name for copied file
;                                                                               
; Outputs     : None                                                            
;                                                                               
; Keywords    : OUT_DIR = output directory to copy file                         
;               ERR   = string error message                                    
;               USE_GET = force using sock_get
;                                                                  
; History     : 27-Dec-2001,  D.M. Zarro (EITI/GSFC) - Written                  
;               23-Dec-2005, Zarro (L-3Com/GSFC) - removed COMMON               
;               26-Dec-2005, Zarro (L-3Com/GSFC) 
;                - added /HEAD_FIRST to HTTP->COPY to ensure checking for              
;                  file before copying                               
;               18-May-2006, Zarro (L-3Com/GSFC) 
;                - added IDL-IDL bridge capability for background copying                  
;               10-Nov-2006, Zarro (ADNET/GSFC) 
;                - replaced read_ftp call by ftp object
;                1-Feb-2007, Zarro (ADNET/GSFC)
;                - allowed for vector OUT_DIR
;               4-June-2009, Zarro (ADNET)
;                - improved FTP support
;               27-Dec-2009, Zarro (ADNET)
;                - piped FTP copy thru sock_get
;               18-March-2010, Zarro (ADNET)
;                - moved err and out_dir keywords into _ref_extra
;                8-Oct-2010, Zarro (ADNET)
;                - dropped support for COPY_FILE. Use LOCAL_FILE to
;                  grab name of downloaded file.
;                                                                               
; Contact     : DZARRO@SOLAR.STANFORD.EDU                                       
;-                                                                              
                                                                                
pro sock_copy,url,out_name,_ref_extra=extra,local_file=local_file,$
                     use_get=use_get
                                         
if is_blank(url) then begin                                                     
 pr_syntax,'sock_copy,url'                                                      
 return                                                                         
endif                                                                           
                         
use_get=keyword_set(use_get)                           
n_url=n_elements(url)                                                           
local_file=strarr(n_url)    
for i=0,n_url-1 do begin                                                        
 is_ftp=stregex(url[i],'ftp://',/bool)
 do_get=is_ftp or use_get
 if do_get then begin
  sock_get,url[i],out_name,_extra=extra,local_file=temp
 endif else begin
  if ~obj_valid(sock) then sock=obj_new('http',_extra=extra)             
  sock->copy,url[i],out_name,_extra=extra,local_file=temp
 endelse
 if file_test(temp) then local_file[i]=temp
endfor                                                 
                         
if n_url eq 1 then local_file=local_file[0]
                                                                                
if obj_valid(sock) then obj_destroy,sock
                                                                                
return                                                                          
end                                                                             
