;+
; Project     : SOHO-CDS
;
; Name        : GET_MAP_XRANGE
;
; Purpose     : Extract min/max X-coordinate of map.
;               Coordinates correspond to the pixel center.
;
; Category    : imaging
;
; Syntax      : xrange=get_map_xrange(map)
;
; Inputs      : MAP = image map
;
; Outputs     : XRANGE = [xmin,xmax]
;
; Keywords    : ERR = error string
;               EDGE = return outer edges of pixels in range
;
; History     : Written, 16 Feb 1998, D. Zarro (SAC/GSFC)
;               Modified, 15 Dec 2008, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_xrange,map,err=err,edge=edge

err=''
if ~valid_map(map,err=err) then return,-1

use_edge=keyword_set(edge)
sz=size(map.data)
nx=sz[1]
dx=map.dx & xc=map.xc
xmin=min(xc-dx*(nx-1.)/2.)-use_edge*dx/2.
xmax=max(xc+dx*(nx-1.)/2.)+use_edge*dx/2.
xrange=[xmin,xmax]

return,xrange

end
