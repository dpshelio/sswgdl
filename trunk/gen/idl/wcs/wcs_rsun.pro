;+
; Project     :	SOHO - CDS
;
; Name        :	WCS_RSUN()
;
; Purpose     :	Returns the solar radius in meters
;
; Category    :	Coordinates, WCS
;
; Explanation : Returns the solar radius as 6.95508D8 meters, based on Brown,
;               T. M., and Christensen-Dalsgaard, J. (1998) "Accurate
;               Determination of the Solar Photospheric Radius', Ap. J. Lett.,
;               500, L195.
;
;               The purpose of having this in a separate routine is so that
;               various routines using this parameter can access it from a
;               single location, avoiding inconsistent definitions across
;               routines.
;
; Syntax      :	Rsun = WCS_RSUN()
;
; Keywords    : UNITS   = By default, this routine returns the value of 1
;                         Rsun in meters, since that is the FITS standard.
;                         Other length units can be passed through the UNITS
;                         keyword, e.g.
;
;                               Rsun = WCS_RSUN(units='km')
;
;                         The routine WCS_PARSE_UNITS is used to parse the
;                         UNITS string.  Note that the units string is case
;                         sensitive: 'mm' is different from 'Mm'.
;
; Calls       : WCS_PARSE_UNITS
;
; History     :	Version 1, 8-Dec-2008, William Thompson, GSFC
;               Version 2, 9-Sep-2009, WTT, added keyword UNITS
;
; Contact     :	WTHOMPSON
;-
;
function wcs_rsun, units=units
on_error, 2
;
rsun = 6.95508d8
;
if datatype(units) eq 'STR' then begin
    if n_elements(units) gt 1 then message, 'UNITS must be a scalar'
    wcs_parse_units, units, base_units, factor, /quiet
    if base_units ne 'm' then begin
        wcs_parse_units, strlowcase(units), base_units, factor, /quiet
        if base_units ne 'm' then begin
            wcs_parse_units, strupcase(units), base_units, factor, /quiet
            if base_units ne 'm' then message, 'Units "' + units + $
              '" not recognized as units of length'
        endif
    endif
    rsun = rsun / factor
endif
;
;
return, rsun
end
