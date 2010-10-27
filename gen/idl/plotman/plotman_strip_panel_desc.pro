;+
; Function to strip the panel description and return the main description.
; The part before the comma and the current time part of the description are removed.
; Kim Tolbert 8-May-2007
;----

function plotman_strip_panel_desc, desc

if strpos(desc,',') ne -1 then desc = ssw_strsplit(desc,',', /tail)
desc = ssw_strsplit(desc, '(', /head)  ; get rid of time in desc
return, desc
end