;+
; Project     : SOHO-CDS
;
; Name        : SHIFT_MAP
;
; Purpose     : Shift an image map.
;               Note that this operation does not rebin pixels.
;
; Category    : imaging
;
; Explanation : translate a map in x- and y-directions by moving
;               it's centroid
;
; Syntax      : smap=shift_map(map,xshift,yshift)
;;
; Inputs      : MAP = image map structure
;               XSHIFT,YSHIFT = shift values in x- and y- directions (arcsec +W, +N)
;
; Outputs     : SMAP = shifted map
;
; Keywords    : XC = new X-center (ignored if XSHIFT entered)
;               YC = new Y-center (ignored if YSHIFT entered)
;               REVERSE = reverse operation
;
; History     : Written 12 May 1998, D. Zarro, SAC/GSFC
;               Modified 22 March 2000, Zarro (SM&A/GSFC) -- added
;               check for ROLL_CENTER
;
; Contact     : dzarro@solar.stanford.edu
;-

function shift_map,map,xshift,yshift,err=err,xc=xc,yc=yc,no_copy=no_copy,$
                reverse=reverse,_extra=extra

err=''

;-- check inputs 

if ~valid_map(map) then begin
 err='Invalid input map'
 pr_syntax,'smap=shift_map(map,xshift,yshift,[xc=xc,yc=yc])'
 if exist(map) then return,map else return,-1
endif

err=''
if keyword_set(no_copy) then tmap=temporary(map) else tmap=map
pxc=tmap.xc
pyc=tmap.yc

pxshift=0.
pyshift=0.

if is_number(xshift) then pxshift=float(xshift) else $
 if exist(xc) then pxshift=xc-pxc

if is_number(yshift) then pyshift=float(yshift) else $
 if exist(yc) then pyshift=yc-pyc

reverse=keyword_set(reverse)
if reverse then begin
 pxshift=-pxshift & pyshift=-pyshift
endif

if (pxshift ne 0.) or (pyshift ne 0.) then begin
 tmap.xc=tmap.xc+pxshift
 tmap.yc=tmap.yc+pyshift
 if have_tag(tmap,'roll_center') then begin  
   xrange=get_map_xrange(map)
   yrange=get_map_yrange(map)
   rcenter=tmap.roll_center
   inside= (rcenter[0] le max(xrange)) and (rcenter[0] ge max(xrange)) and $
           (rcenter[1] le max(yrange)) and (rcenter[1] ge max(yrange))
   if inside then tmap.roll_center=tmap.roll_center+[pxshift,pyshift]
 endif
endif

return,tmap
end
