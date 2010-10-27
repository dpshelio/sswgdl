;+
; Project     : Hinode/EIS
;
; Name        : IS_URL
;
; Purpose     : check if file name is URL
;
; Category    : utility system sockets
;
; Inputs      : FILE = file to check
;
; Outputs     : 1/0 if valid URL
;
; Keywords    : READ_REMOTE= 1/0 if file is directly readable 
;               SCHEME = http:// or ftp:// has to appear in the input
;
; History     : Written 19-Nov-2007, D.M. Zarro (ADNET/GSFC)
;               11-March-2010, Zarro (ADNET)
;               - added SCHEME
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function is_url,file,read_remote=read_remote,scheme=scheme

read_remote=0b
if is_blank(file) then return,0b
if file_test(file[0]) then return,0b

stc=url_parse(file[0])
chk=is_string(stc.host)
if keyword_set(scheme) then $
 chk=is_string(stc.host) and is_string(stc.scheme)
if chk then read_remote= ~stregex(stc.scheme,'ftp:\/\/',/bool) and $
                         ~stregex(stc.path,'(\.gz|\.Z)$',/bool)

return,chk
end
