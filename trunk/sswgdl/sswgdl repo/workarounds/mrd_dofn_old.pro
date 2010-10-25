function  mrd_dofn_old, name, index, use_colnum 
 
; Convert the string name to a valid variable name.  If name 
; is not defined generate the string Cnn when nn is the index 
; number. 

 reserved_names = ['AND','BEGIN','CASE','COMMON','DO','ELSE','END','ENDCASE', $
 'ENDELSE','ENDFOR','ENDIF','ENDREP','ENDWHILE','EQ','FOR','FUNCTION','GE', $
 'GOTO','GT','IF','INHERITS','LE','LT','MOD','NE','NOT','OF','ON_IOERROR', $
 'OR','PRO','REPEAT','THEN','UNTIL','WHILE','XOR' ]
;stop
table = 0
sz = size(name) 
nsz = n_elements(sz) 
if not use_colnum and (sz(nsz-2) ne 0) then begin 
        if sz(nsz-2) eq 7 then begin 
                str = name(0) 
        endif else begin 
                str = 'C'+string(index) 
        endelse 
endif else begin 
        str = 'C'+string(index) 
endelse 
;is_gdl() change strcompress(str, /remove_all) because we need to change space to underscore 

str = str_replace(strcompress(str) , ' ','_')  
;str = strcompress(str, /remove_all)
reserved = where(strupcase(str) EQ reserved_names, Nreserv)
if Nreserv GT 0 then str = str + '_'

len = strlen(str) 
c = strmid(str, 0, 1) 
 
; First character must be alphabetic. 
 
if  not (('a' le c  and 'z' ge c) or ('A' le c  and 'Z' ge c)) then begin 
        str = 'X' + str 
endif 
 
; 
; Replace invalid characters with underscores. 
; We assume ASCII ordering.
;
for i=1, len-1 do begin 
        c = strmid(str, i, 1) 
        if not (('a' le c  and 'z' ge c)  or  $ 
                ('A' le c  and 'Z' ge c)  or  $ 
                ('0' le c  and '9' ge c)  or  $ 
                (c eq '_') or (c eq '$')      $ 
               ) then strput, str, '_', i 
endfor 
 
return, str 
end 

;***************************************************************


