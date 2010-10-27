;+
; Project     : SOHO-CDS
;
; Name        : ROT_MAP
;
; Purpose     : rotate image contained within structure created by MAKE_MAP
;
; Category    : imaging
;
; Syntax      : rmap=rot_map(map,angle)
;
; Inputs      : MAP = map structure 
;               ANGLE = angle in degrees to rotate image map (+ for clockwise)
;
; Opt. Inputs : None
;
; Outputs     : RMAP = map with rotated coordinates
;
; Keywords    : CENTER= [XC,YC] = center of rotation 
;               Use MAP.ROLL_CENTER if CENTER is not entered and MAP.ROLL_ANGLE ne 0
;               Use center of image otherwise
;             : NO_REMAP = don't remap image data (just rotate coords)
;             : FULL_SIZE = adjust image size to fit all rotated pixels
;             : ROLL_ANGLE = new roll angle for map
;
; History     : Written 22 November 1996, D. Zarro (ARC/GSFC)
;               Modified 27 December 2002, Zarro (EER/GSFC) - made image center
;               the default roll center for zero roll data
;               Modified 23 March 2009, Zarro (ADNET)
;                - added checks for NaN's
;
; Contact     : dzarro@solar.stanford.edu
;-

function rot_map,map,angle,center=center,no_remap=no_remap,err=err,$
                verbose=verbose,full_size=full_size,_extra=extra,$
                roll_angle=roll_angle

err=''

if ~valid_map(map) then begin
 err='rmap=rot_map(map,angle) OR rmap=rot_map(map,roll_angle=roll_angle)'
 pr_syntax,err 
 print,'% ANGLE = angle (deg clockwise to roll) or ROLL = new map ROLL angle'
 if exist(map) then return,map else return,-1
endif

angle_entered=exist(angle)
roll_entered=exist(roll_angle)

if (~angle_entered) and (~roll_entered) then begin
 err='Enter rotation angle in degrees clockwise from North'
 message,err,/cont
 if exist(map) then return,map else return,-1
endif 

verbose=keyword_set(verbose)
adjust_resolution=keyword_set(full_size)

;-- don't rotate if multiple of 360.

if angle_entered then begin
 if (angle mod 360.) eq 0. then return,map
endif 

;-- read image and pixel arrays

nmp=n_elements(map)
for i=0,nmp-1 do begin

 dx=map[i].dx
 dy=map[i].dy
 xc=map[i].xc
 yc=map[i].yc
 xp=get_map_xp(map[i])
 yp=get_map_yp(map[i])

 icenter=[xc,yc]
 roll_center=get_map_prop(map[i],/roll_center,def=icenter)
 curr_roll=get_map_prop(map[i],/roll_angle,def=0.)
 if (curr_roll mod 360.) eq 0 then roll_center=icenter
 if valid_map(center) then roll_center=get_map_center(center) else $
  if n_elements(center) eq 2 then roll_center=float(center)
 if angle_entered then ang=float(angle) else ang=float(roll_angle)-curr_roll

 nmap=map[i]
 new_roll=(ang+curr_roll) mod 360
 if have_tag(nmap,'roll_angle') then nmap.roll_angle=new_roll else nmap=add_tag(nmap,new_roll,'roll_angle')
 if have_tag(nmap,'roll_center') then nmap.roll_center=roll_center else $
  nmap=add_tag(nmap,roll_center,'roll_center',index='roll_angle') 

 apply_roll=(ang mod 360.) ne 0.
 if apply_roll then begin
  roll_xy,xp,yp,ang,rx,ry,center=roll_center,verbose=verbose
  nmap=repack_map(nmap,rx,ry,/no_copy)

;-- rebin image
;-- do this by regridding rotated coordinates and
;   and computing image data value in pre-rotated image by interpolation

  if ~keyword_set(no_remap) then begin
   grid_xy,rx,ry,gx,gy,space=[dx,dy],$
   _extra=extra,adjust_resolution=adjust_resolution
   roll_xy,gx,gy,-ang,rx,ry,center=roll_center,verbose=verbose
   xmin=min(xp,max=xmax) & ymin=min(yp,max=ymax) 
   out=where((rx lt xmin) or (rx gt xmax) or $
             (ry lt ymin) or (ry gt ymax),count)
   count=0
   if count eq n_elements(rx) then begin
    err='No data in rotated image'
    message,err,/cont
   endif else begin
    if verbose then $
     dprint,'% ROT_MAP: # of unrotated points = ',trim(string(count))
    in=where( (rx ge xmin) and (rx le xmax) and $
              (ry ge ymin) and (ry le ymax),icount)
    find=where(finite(nmap.data,/nan),ncount)
    if ncount gt 0 then begin
     nmap.data[find]=0.
     rx[find]=-999999.
     ry[find]=-999999.
    endif
    rdata=interp2d(float(nmap.data),xp,yp,rx,ry,_extra=extra,missing=0)
    chk=array_equal(size(rdata),size(nmap.data))
    if chk then nmap.data=temporary(rdata) else $
     nmap=rep_tag_value(nmap,temporary(rdata),'data')
    nmap=repack_map(nmap,gx,gy,/no_copy)
   endelse
  endif else nmap.roll_angle=curr_roll
 endif 
 rmap=merge_struct(rmap,temporary(nmap),/no_copy)
endfor

if ~valid_map(rmap) then rmap=-1
delvarx,xp,yp,gx,gy,rx,ry,data

return,rmap & end
