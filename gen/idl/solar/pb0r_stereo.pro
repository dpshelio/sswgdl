;+
; Project     : STEREO
;
; Name        : pb0r_stereo
;
; Purpose     : return p0, b0, l0, and solar radius as viewed from
;               STEREO A or STEREO B
;
; Category    : imaging, maps
;
; Syntax      : IDL> pbr=pb0r(time,l0=l0,roll_angle=roll_angle)
;
; Inputs      : TIME = UT time to compute 
;
; Outputs     : PBR = [p0,b0,rsun]
;
; Keywords    : STEREO = A or /AHEAD for STEREO A [def]
;                      = B or /BEHIND for STEREO B
;               L0 = central meridian [deg]
;               ROLL_ANGLE = spacecraft roll [deg]
;               ARCSEC = return radius in arcsecs
;
; History     : Written 21 August 2008 - Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function pb0r_stereo,time,arcsec=arcsec,l0=l0,error=error,$
                     roll_angle=roll_angle,$
                     stereo=stereo,ahead=ahead,behind=behind

forward_function get_stereo_lonlat,get_stereo_roll

error=''
l0=0 & roll_angle=0.
pbr=[0.,0.,16.]
if keyword_set(arcsec) then pbr=[0.,0.,960.]
if ~have_proc('get_stereo_lonlat') then begin
 error='STEREO orbital position routine - get_stereo_lonlat - not found'
 message,error,/cont
 return,pbr
endif

proj_time=anytim2tai(time,err=error)
if is_string(error) then begin
 pr_syntax,'pbr=pb0r_stereo(time)'
 return,pbr
endif

stereo_launch=anytim2tai('26-oct-2006')
if proj_time lt stereo_launch then begin
 error='STEREO orbital data unavailable for this input time'
 message,error,/cont
 return,pbr
endif

;-- STEREO values of l0, b0, rsun, and roll for input time

spacecraft='A'
case 1 of
 is_string(stereo): if strupcase(stereo) eq 'B' then spacecraft='B'
 keyword_set(behind): spacecraft='B'
 else: spacecraft='A'
endcase
 
error=''
pos=get_stereo_lonlat(time, spacecraft, system="HEEQ", /degrees,err=error)

if is_string(error) then begin
 message,error,/cont
 return,pbr
endif

b0=pos[2]
l0=pos[1]
rsun=sol_rad(pos[0])
if ~keyword_set(arcsec) then rsun=rsun/60.

;-- compute roll

roll_corr= -1.1249928
roll_angle=-get_stereo_roll(time, spacecraft,err=error,/degrees)+roll_corr
if is_string(err) then begin
 message,err,/cont
 return,pbr
endif

;-- compute p0

p0=get_stereo_roll(time,spacecraft,system='HEEQ') - $
    get_stereo_roll(time, spacecraft,system='GEI')

return,[p0,b0,rsun]
end

