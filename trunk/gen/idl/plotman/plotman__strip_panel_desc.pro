;+
; Function to strip the panel description and return the main description.
; The part before the comma and the current time part of the description are removed.
; Keywords:
; current - if set, use description of current panel
; overlay - # of overlay panel description to use
; If overlay is not set, defaults to /current
;
; Kim Tolbert 8-May-2007
;----

function plotman::strip_panel_desc, current=current, ov_panel_desc=ov_panel_desc

current = keyword_set(current)

desc = exist(ov_panel_desc) ? ov_panel_desc : 'self'
if desc eq 'self' then desc = self -> get(/current_panel_desc)
;if exist(ov_panel_desc) then begin
;	ov_panels = self->get(/overlay_panel)
;	desc = ov_panels[overlay]
;	if desc eq 'self' then current = 1
;endif else current = 1
;
;if current then desc = self -> get(/current_panel_desc)

if strpos(desc,',') ne -1 then desc = ssw_strsplit(desc,',', /tail)
desc = ssw_strsplit(desc, '(', /head)  ; get rid of time in desc
return, desc
end