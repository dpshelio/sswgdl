;+
; Project     : SOHO-CDS
;
; Name        : MK_MAP_YP
;
; Purpose     : compute Y-coordinate arrays from center and spacing
;
; Category    : imaging
;
; Syntax      : yp=mk_map_yp(yc,dy,nx,ny)
;
; Inputs      : YC = y-coord image center (arcsecs)
;               DY = pixel spacing in y-direc (arcsecs)
;               NX,NY = output dimensions
;
; Outputs     : YP = 2d Y-coordinate array
;
; History     : Written 16 Feb 1998, D. Zarro, SAC/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-


function mk_map_yp,yc,dy,nx,ny
dumy = ny*dy/2.
if ~exist(nx) then nx=1

yp=(findgen(ny)+.5)*dy - dumy + yc

if nx gt 1 then begin
 yp=rebin(temporary(yp),ny,nx,/sample)
 return,rotate(temporary(yp),1)
endif else return,yp
 
end

