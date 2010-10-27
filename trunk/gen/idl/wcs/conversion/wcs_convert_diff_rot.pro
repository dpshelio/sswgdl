;+
; Project     :	STEREO
;
; Name        :	WCS_CONVERT_DIFF_ROT
;
; Purpose     :	Apply differential rotation to solar longitudes
;
; Category    :	Coordinates, WCS
;
; Explanation : This routine takes heliographic coordinates (either Stonyhurst
;               or Carrington) from one WCS structure, and applies a
;               differential rotation model (via diff_rot.pro) to match the
;               time of another WCS structure.
;
; Syntax      :	WCS_CONVERT_DIFF_ROT, WCS_IN, WCS_OUT, LONGITUDE, LATITUDE
;
; Examples    :	The following example shows how to convert coordinates between
;               a STEREO/EUVI and SOHO/EIT image.
;
;               COORD_EUVI = WCS_GET_COORD(WCS_EUVI, PIXEL_EUVI)
;               WCS_CONVERT_FROM_COORD, WCS_EUVI, COORD_EUVI, 'HG', HGLN, HGLT
;               WCS_CONVERT_DIFF_ROT, WCS_EUVI, WCS_EIT, HGLN, HGLT
;               WCS_CONVERT_TO_COORD, WCS_EIT, COORD_EIT, 'HG', HGLN, HGLT
;               PIXEL_EIT = WCS_GET_PIXEL(WCS_EIT, COORD_EIT)
;
; Inputs      :	WCS_IN  = WCS structure for input observation
;               WCS_OUT = WCS structure for output observation
;               LONGITUDE = Heliographic longitude, in degrees
;               LATITUDE  = Heliographic latitude, in degrees
;
; Opt. Inputs :	None.
;
; Outputs     :	LONGITUDE = The updated longitude values are returned in place
;
; Opt. Outputs:	None.
;
; Keywords    :	CARRINGTON = If set, then the longitude and latitude are in the
;                            Carrington coordinate system.  Otherwise, they are
;                            in the Stonyhurst coordinate system.
;
;               Can also pass /ALLEN or /HOWARD to diff_rot.pro.
;
; Calls       :	TAG_EXIST, ANYTIM2TAI, DIFF_ROT
;
; Common      :	None.
;
; Restrictions:	The underlying routine, diff_rot.pro, is slightly more accurate
;               when used with Carrington rather than Stonyhurst coordinates.
;
; Side effects:	
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 9-Mar-2009, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro wcs_convert_diff_rot, wcs_in, wcs_out, longitude, latitude, $
                       carrington=carrington, _extra=_extra
;
;  Get the start and end times from the WCS structures.
;
if tag_exist(wcs_in.time, 'observ_avg') then $
  t0 = wcs_in.time.observ_avg else $
  t0 = wcs_in.time.observ_date
;
if tag_exist(wcs_out.time, 'observ_avg') then $
  t1 = wcs_out.time.observ_avg else $
  t1 = wcs_out.time.observ_date
;
;  Calculate the time difference in days.
;
dd = (anytim2tai(t1) - anytim2tai(t0)) / 86400
;
;  Apply the differential rotation rate.
;
synodic = 1 - keyword_set(carrington)
longitude = longitude + diff_rot(dd, latitude, synodic=synodic, $
                                 carrington=carrington, sidereal=0, rigid=0, $
                                 _extra=_extra)
;
end
