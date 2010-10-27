;+
; Project     : VSO
;
; Name        : GET_FITS_DET
;
; Purpose     : Get instrument detector name from FITS header
;
; Category    : imaging, FITS
;
; Syntax      : inst=get_fits_inst(file)
;
; Inputs      : FILE = FITS file name or header
;
; Outputs     : INST = instrument acronym
;
; Keywords    : PREPPED = 1/0 if file is prepped or not
;
; History     : 24 July 2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_fits_det,file,_ref_extra=extra,err=err,stc=stc,prepped=prepped,$
             quiet=quiet

verbose=~keyword_set(quiet)

err='' & prepped=0b

if is_blank(file) then begin
 err='Invalid input file name entered.'
 return,''
endif

;-- check if remote or local file, or header input

if n_elements(file) gt 1 then header=file else begin
 if stregex(file_basename(file),'^tri',/bool) then return,'TRACE'
 if is_url(file,read_remote=read_remote) then begin
  if read_remote then sock_fits,file,header=header,/nodata,_extra=extra,err=err else $
   err='Cannot determine instrument from header of remote compressed file.'
 endif else mrd_head,file,header,_extra=extra,err=err
 if is_string(err) then begin
  if verbose then message,err,/cont & return,''
 endif
endelse

;-- look for "standard" keywords

inst=''
stc=fitshead2struct(header)
chk=['detec','instr','tele']
for i=0,n_elements(chk)-1 do begin
 if have_tag(stc,chk[i],/start,index) then begin
  tinst=stc.(index)
  if is_string(tinst) then begin
   inst=tinst & break
  endif
 endif
endfor

if is_blank(inst) then begin
 err='Could not determine instrument.'
 return,''
endif

;-- check if prepped by looking for "Degrid" or "Flat Field" keywords

inst=strupcase(inst)
if inst eq 'XRT' then inst='XRT2'

prepped=0b
chk=where(stregex(header,'(Flat fielded|Applied Flat Field|Prepped)',/bool,/fold),count)

prepped=count gt 0

return,inst
end
