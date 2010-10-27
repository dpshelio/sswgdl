;+
; Project     : SOHO-CDS
;
; Name        : ROLL_MAP
;
; Purpose     : Roll or rotate image map by adjusting roll angle.
;               Note that this operation does not rebin pixels.
;
; Category    : imaging
;
; Syntax      : rmap=roll_map(map,angle)
;
; Inputs      : MAP = image map structure
;               ANGLE = degrees to adjust roll (clockwise positive)
;
; Outputs     : RMAP = rolled map
;
; Keywords    : NO_COPY = do not make copy of input map
;
; History     : Written 24 June 2008, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function roll_map,map,angle,err=err,no_copy=no_copy

err=''

if ~valid_map(map) then begin
 err='Invalid input map'
 pr_syntax,'rmap=roll_map(map,angle)'
 if exist(map) then return,map else return,-1
endif

if ~exist(angle) then return,map
if (angle mod 360.) eq 0. then return,map
xc=map.xc
yc=map.yc
if keyword_set(no_copy) then tmap=temporary(map) else tmap=map
if ~tag_exist(tmap,'roll_angle') then tmap=add_tag(tmap,0.,'roll_angle')
if ~tag_exist(tmap,'roll_center') then tmap=add_tag(tmap,[xc,yc],'roll_center')
tmap.roll_angle=tmap.roll_angle+float(angle)
return,tmap
end
