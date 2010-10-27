;+
; Project     : RHESSI
;
; Name        : FILE_SETENV
;
; Purpose     : Read file containing SETENV commands and set 
;               environment within IDL
;
; Category    : system utility 
;
; Inputs      : FILE = ascii file with entries like: setenv AAA BBB
;
; Outputs     : Environment variables: $AAA=BBB
;
; Keywords    : None
;
; History     : 21-Feb-2010, Zarro (ADNET) - Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro file_setenv,file,verbose=verbose

verbose=keyword_set(verbose)
dfile=local_name(file)
chk=loc_file(dfile,count=count)
if count eq 0 then return

a=strcompress(rd_ascii(chk[0]))
d=stregex(a,' *(setenv) +([^ ]+) +([^ ]+)',/extract,/sub,/fold)
ok=where(strlowcase(d[1,*]) eq 'setenv',count)
if count eq 0 then begin
 message,'No SETENV commands found.',/cont
 return
endif


d=d[*,ok]
for i=0,count-1 do begin
 if verbose then message,'Setting '+d[2,i]+' to '+d[3,i],/cont
 mklog,d[2,i],d[3,i],/local
endfor
return & end
