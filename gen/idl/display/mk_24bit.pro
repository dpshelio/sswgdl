;+
; Project     : SOHO-CDS
;
; Name        : MK_24BIT
;
; Purpose     : scale image to 24 bit color table
;
; Category    : imaging
;
; Syntax      : mk_24bit,image,r,g,b
;
; Inputs      : IMAGE = input image
;               R,G,B = color table vectors
;
; Outputs     : IMAGE24 = scaled image
;
; Keywords    : NO_SCALE = set to not byte scale
;               TRUE= 1,2,3 [def=1]
;               OUTSIZE = output dimensions
;               LOG = convert to log scale
;
; History     : Written 11 Jan 2000, D. Zarro (SM&A)
;               Modified 16 Oct 2008, Zarro (ADNET)
;                - added LOG, TRUE, and OUTSIZE keywords
;
; Contact     : dzarro@solar.stanford.edu
;-

function mk_24bit,image,r,g,b,no_scale=no_scale,true=true,$
                outsize=outsize,log=log

dim=data_chk(image,/ndim)
if dim ne 2 then begin
 message,'input image must be 2-d',/cont
 pr_syntax,'image24=mk_24bit(image,r,g,b)
 return,''
endif

;-- usr current internal color table if one not provided

if n_params(0) ne 4 then tvlct,r,g,b,/get

scaled=image
if keyword_set(log) then begin
 ok=where(scaled gt 0.,count,complement=nok,ncomplement=cnok)
 if count eq 0 then begin
  message,'All data are negative. Cannot use log scale',/cont
  return,image
 endif
 if cnok gt 0 then begin
  pmin=min(scaled[ok])
  scaled[nok]=pmin
 endif
 scaled=alog10(scaled)
endif
 
if ~keyword_set(no_scale) then scaled = bytscl(scaled, top=!d.table_size-1)
s = size(scaled, /dimensions)

if exist(outsize) then begin
 nx=outsize[0] & ny=nx
 if n_elements(outsize) gt 1 then ny=outsize[1]
 if (nx ne s[0]) or (ny ne s[1]) then begin
  scaled=congrid(scaled,nx,ny)
  s[0]=nx & s[1]=ny
 endif
endif

if is_number(true) then true=  (1 > true < 3) else true=1
case true of
 1: begin
     image24 = bytarr(3, s[0],s[1],/nozero)
     image24[0, *, *] = r[scaled]
     image24[1, *, *] = g[scaled]
     image24[2, *, *] = b[scaled]
    end
 2: begin
     image24 = bytarr(s[0],3,s[1],/nozero)
     image24[*,0,*] = r[scaled]
     image24[*,1,*] = g[scaled]
     image24[*,2,*] = b[scaled]
    end
 else: begin
     image24 = bytarr(s[0],s[1],3,/nozero)
     image24[*,*,0] = r[scaled]
     image24[*,*,1] = g[scaled]
     image24[*,*,2] = b[scaled]
    end
endcase

return,image24

end


