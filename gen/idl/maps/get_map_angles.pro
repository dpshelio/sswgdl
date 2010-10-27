;+
; Project     : STEREO
;
; Name        : GET_MAP_ANGLES
;
; Purpose     : return spacecraft-dependent coordinate transformation
;                angles for a map
;
; Category    : imaging, maps
;
; Syntax      : IDL> angles=get_map_angles(map)
;
; Inputs      : MAP = map structure or MAP ID and time
;
; Outputs     : ANGLES = {l0,b0,roll_angle,rsun}
;
; Keywords    : NO_ROLL_ANGLE = set to not include roll angle
;
; History     : Written 6 September 2008 - Zarro (ADNET)
;               Modified 21 July 2009, Zarro (ADNET)
;                - added check for whether SOHO map has already been corrected
;                  to Earth-view.
;
; Contact     : dzarro@solar.stanford.edu
;-

function get_map_angles,map,time,use_ephemeris=use_ephemeris,$
                no_roll_angle=no_roll_angle,_ref_extra=extra,verbose=verbose


angles={l0:0.,b0:0.,roll_angle:0.,rsun:960.}
return_roll=~keyword_set(no_roll_angle) 
if ~return_roll then angles=rem_tag(angles,'roll_angle')

map_input=valid_map(map)
id_input=is_string(map) and valid_time(time)
if ~map_input and ~id_input then return,angles

;-- if map already has one of these angles, then use them

soho=0b
if map_input then begin
 id=map.id
 mtime=get_map_time(map)
endif
if id_input then begin
 id=map & mtime=time
endif

;-- if SOHO, have to check whether image was previously remapped to Earth-view.

use_ephemeris=keyword_set(use_ephemeris) or ~have_tag(map,'l0')
soho=stregex(id,'SOHO',/bool,/fold)

if map_input and ~use_ephemeris then begin
 struct_assign,map,angles
 if soho then if have_tag(map,'soho') then if ~map.soho then begin
  soho=0b & use_ephemeris=1b
 endif
 if ~use_ephemeris then return,angles
endif

;-- check if SOHO or STEREO
 
stereo=0b
stereo_a=stregex(id,'STEREO[_|-]?A',/bool,/fold)
stereo_b=stregex(id,'STEREO[_|-]?B',/bool,/fold)
if stereo_a then stereo='A'
if stereo_b then stereo='B'

verbose=keyword_set(verbose)
if verbose then begin
 if soho then message,'Checking SOHO ephemeris..',/cont else $
  message,'Checking ephemeris..',/cont 
 if is_string(stereo) then message,'Checking STEREO ephemeris..',/cont
endif

temp=pb0r(mtime,l0=l0,/arcsec,soho=soho,stereo=stereo,roll=roll,$
          _extra=extra,verbose=verbose)
angles.l0=l0
angles.b0=temp[1]
angles.rsun=temp[2]
if is_string(stereo) and return_roll then angles.roll_angle=roll

return,angles
end
