;+
; Project     : VSO
;
; Name        : GET_FITS_EXTN
;
; Purpose     : Empirically determine number of extensions in a FITS file 
;               by sequentially reading headers until end of file
;
; Category    : FITS
;
; Syntax      : IDL> next=get_fits_extn(file)
;
; Inputs      : FILE = FITS file name
;
; Outputs     : N_EXT = number of valid extensions in file
;
; Keywords    : VERBOSE = set for noisy output
;
; History     : 10 Oct 2009, Zarro (ADNET) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_fits_extn,file,err=err,_extra=extra

i=0
repeat begin
 err=''
 mrd_head,file,ext=i,err=err,_extra=extra
 if is_blank(err) then i=i+1
endrep until is_string(err)

return,i

end
