;+
; Project     : STEREO
;
; Name        : COMP_PC_CEN
;
; Purpose     : compute XCEN and YCEN from FITS PC-matrix standard keywords
;
; Category    : imaging, FITS
;
; Syntax      : IDL> comp_pc_cen,index,index,data
;
; Inputs      : INPUT = FITS header or equivalent index

; Outputs     : XCEN, YCEN (arcsecs)
;
; History     : Written 19 September 2008, Zarro (ADNET)

pro comp_pc_cen,input,xcen,ycen

xcen=0. & ycen=0.

error=0
catch,error
if error ne 0 then begin
 message,!err_string,/cont
 return
endif

if is_string(input) then index=fitshead2struct(input) else index=input

i = (index.naxis1 + 1.) / 2. - index.crpix1
j = (index.naxis2 + 1.) / 2. - index.crpix2
xcen=index.crval1 + (index.cdelt1 * ( ( index.pc1_1 * i ) + $
                    (index.pc1_2 * j ) ) )

ycen=index.crval2 + (index.cdelt2 * ( ( index.pc2_1 * i ) + $
                    (index.pc2_2 * j ) ) )

return & end
