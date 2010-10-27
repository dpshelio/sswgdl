;+
; Project     : SOHO-CDS
;
; Name        : GET_MAP_YRANGE
;
; Purpose     : Extract min/max Y-coordinate of map.
;               Coordinates correspond to the pixel center.
;
; Category    : imaging
;
; Syntax      : yrange=get_map_yrange(map)
;
; Inputs      : MAP = image map
;
; Outputs     : YRANGE = [ymin,ymax]
;
; Keywords    : ERR = error string
;               EDGE = return outer edges of pixels in range
;
; History     : Written, 16 Feb 1998, D. Zarro (SAC/GSFC)
;               Modified, 15 Dec 2008, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_yrange,map,err=err,edge=edge

err=''
if ~valid_map(map,err=err) then return,-1
use_edge=keyword_set(edge)
sz=size(map.data)
ny=sz[2]
dy=map.dy & yc=map.yc

ymin=min(yc-dy*(ny-1.)/2.)-use_edge*dy/2.
ymax=max(yc+dy*(ny-1.)/2.)+use_edge*dy/2.
yrange=[ymin,ymax]

return,yrange

end
