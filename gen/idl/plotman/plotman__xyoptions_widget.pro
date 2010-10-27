;+
; Name: plotman__xyoptions_widget
;
; Purpose: Widget to set options for displaying xy or ut plots
;
; CATEGORY:  HESSI WIDGETS
;
; Calling sequence:  Called from plotman::options. Not called directly.
;
; Input arguments:
;   event - event structure
;	defaults - defaults structure (see plotman::options)
; Output arguments:
;	ostate - structure with all of widget settings
;
; Output: changes display of plot in plot window
;
; Output Keyword:  None
;
; Written: Kim Tolbert
;
; Modifications:
; 1-May-2001 - Use dim1_name instead of dim1_unit
; 8-Jul-2001 - Added overlay options
; ?-April-2002 - Added options to apply settings to current plot, all plots, or all future plots
; 27-May-2002 - Added derivative option
; 20-Aug-2002 - Added options to put legend outside plot on left or right of plot
; 19-Sep-2002 - Added integral option
; 02-Mar-2003 - Call cw_ut_range instead of hsi_cw_ut_range
; 14-Jul-2003 - Added thick and color options
; 30-Jun-2004, Kim.  Added no_timestamp option
; 29-Apr-2005, Sandhia, Previously set multi_channel flag if dim1_id was a valid pointer
;    Now also require non-blank dim1_id
; 21-Aug-2006, Kim.  Added user_label option
; 9-May-2007, Kim. Use overlay_panel [1,2,3] instead of [0,1,2].  Oth is now reserved for
;    overlaying self (for images only)
; 8-Jun-2007, Kim.  Added charthick option (controls xthick and ythick too) for better PS plots.
; 30-Oct-2007, Kim. Major changes.
;	  1. Now plotman__options handles the stuff common to all plot types, and calls this for xy,ut plots
;	  2. This is now a method instead of a procedure.
;	  3. Call all widgets that we can set defaults for by calling plotman_defaults_wrapper, so
;	   that a little red or green box will appear next to option, letting user control if it
;	   should be used.  All red box items are ignored.
;	  4. Added checkvals method
; 28-Mar-2008, Kim. Set multi_channel only if more than one dim1_id is not ''.
; 24-Apr-2008, Kim. Allow selection of channels to plot even when setting defaults (will
;   only appear when changing defaults for selected plots from plotman_conf_panels)
; 16-May-2008, Kim.  Added overlay_squish option (don't leave space between stacked overlays)
; 07-Jul-2008, Kim. Call get_font instead of hsi_ui_getfont (for move of plotman to ssw gen)
; 26-Apr-2009, Kim. Add widgets for nmax_overlay overlays in scrollable base
; 18-Nov-2009, Kim. Add list button for overlay panel selection.  On some platforms the droplist becomes
;   scrollable (windows), but on some can't select any panels that don't show on screen (mac,unix)


pro plotman::xyopt_widget_update, ostate
w = ostate

;widget_control, w.parent, get_uvalue=state
pc = self -> get (/plot_control)
pp = pc.pp

if xalive(w.w_noverlay) then begin
  q = where (pc.overlay_panel ne '', n)
  widget_control, w.w_noverlay, set_value='Currently ' + trim(n)+' overlay(s) set.'
endif

; no overlays in defaults widget
if xalive (w.w_overlay_panel[1]) then begin  ; skipped 0th, just checking if any overlay widgets are there
  for i=1,pc.nmax_overlay-1 do begin
	  q = where (pc.overlay_panel[i] eq ostate.ov_panel_descs, count)
	  q = count gt 0 ? q[0] : 0
	  widget_control, w.w_overlay_panel[i], set_droplist_select = q
	endfor
endif
;	q = where (pc.overlay_panel[2] eq ostate.ov_panel_descs, count)
;	q = count gt 0 ? q[0] : 0
;	widget_control, w.w_overlay_panel2, set_droplist_select = q
;
;	q = where (pc.overlay_panel[3] eq ostate.ov_panel_descs, count)
;	q = count gt 0 ? q[0] : 0
;	widget_control, w.w_overlay_panel3, set_droplist_select = q
;endif

widget_control, w.w_squish, set_value = pc.overlay_squish eq 1
widget_control, w.w_deriv, set_value = pc.derivative eq 1
widget_control, w.w_integ, set_value = pc.integral eq 1
widget_control, w.w_fill_gaps, set_value = pc.fill_gaps eq 1

nsum = pp.nsum > 1
charsize = pp.charsize eq 0. ? 1. : pp.charsize
thick = pp.thick eq 0. ? 1. : pp.thick
charthick = pp.charthick eq 0. ? 1. : pp.charthick
widget_control, w.w_nsum, set_value = strtrim(string(nsum, format='(i4)'), 2)
widget_control, w.w_hist, set_value = pp.psym eq 10
widget_control, w.w_thick, set_value=strtrim(string(thick, format='(i2)'), 2)
widget_control, w.w_sym, set_droplist_select = abs(pp.psym)
widget_control, w.w_connect, set_value = pp.psym le 0
widget_control, w.w_symsize, set_value = strtrim(string(pp.symsize, format='(f4.2)'), 2)
widget_control, w.w_charsize, set_value=strtrim( string(charsize, format='(f5.2)'), 2)
widget_control, w.w_charthick, set_value=strtrim(string(charthick, format='(i2)'), 2)
widget_control, w.w_legend_loc, set_droplist_select = pc.legend_loc
widget_control, w.w_timestamp, set_value = pc.no_timestamp eq 0
widget_control, w.w_user_label, set_value=pc.user_label

ncolors = self->get(/ncolors)
if widget_info(w.w_color, /name) ne 'BUTTON' then begin
	color_ind = (*pc.dim1_colors)[0] - ncolors - 1
	widget_control, w.w_color, set_droplist_select=color_ind
endif

if xalive(w.w_index1) then begin
	schan = ['All', *pc.dim1_ids]
	nchan = n_elements(schan)-1
	sel = intarr(nchan)
	sel(*pc.dim1_use) = 1
	if min(sel) eq 1 then set=0 else set = *pc.dim1_use + 1
	widget_control, w.w_index1, set_value=schan
	widget_control, w.w_index1, set_list_select=set
endif

if xalive(w.w_sumindex1) then $
	widget_control, w.w_sumindex1, set_value=pc.dim1_sum

if pp.psym eq 10 then begin
	widget_control, w.w_sym_base, sensitive = 0
endif else begin
	widget_control, w.w_sym_base, sensitive = 1
endelse

end

;--------- This is the real event handler

pro plotman::xyoptions_event, event, com, exit, redraw, found

found = 1

widget_control, event.top, get_uvalue=ostate

widget_control, event.id, get_uvalue=uvalue

sel_overlay = -1

case uvalue of

  'list_panels': begin  ;added 16-nov-09 for Macs and Linux
    overlay_num = (where (event.id eq ostate.w_list_panels))[0]
    status = 0
    title = 'Select panel for overlay #' + trim(overlay_num)
    overlay_panel = self -> get(/overlay_panel) 
    sel_overlay = xsel_list(ostate.ov_panel_descs, title=title, initial=overlay_panel[overlay_num], ysize=30, $
      /index, /no_remove, /no_sort, status=status)
    if status eq 0 then sel_overlay = -1
    end
    
	'overlay_panel': begin
	  overlay_num = (where (event.id eq ostate.w_overlay_panel))[0]
	  sel_overlay = event.index
	  end

	'squish': com = 'self -> set, overlay_squish=event.select'

	'unset_overlays': com = 'self -> set, overlay_panel=strarr(n_elements(ostate.w_overlay_panel))'

	'nsum': com = 'self -> set, nsum = event.value'

	'hist': begin
		if event.select eq 1 then psym = '10' else psym = '0'
		com = 'self -> set, psym = ' + psym
		end

  'fillgaps': com = 'self -> set, fill_gaps = event.select'

	'thick': com = 'self -> set, thick = event.value'

	'deriv':  com = 'self -> set, derivative = event.select, integral=0'

	'integ': com = 'self -> set, integral = event.select, derivative=0'

	'sym': begin
		psym = self->get(/psym)
		if psym gt 0 then sign = 1 else sign = -1
		;com = 'self -> set, psym =' + strtrim(sign * event.index)
		com = 'self -> set, psym = sign * event.index'
		end

	'connect': begin
		if event.select eq 1 then sign = -1 else sign = 1
		psym = self->get(/psym)
	;	com = 'self -> set, psym =' + strtrim(sign * abs(psym))
		com = 'self -> set, psym = sign * abs(psym)'
		end

	'symsize': com = 'self -> set, symsize = event.value'

	'1color': begin
		cn = self -> get(/color_names)
		com = 'self -> set, dim1_colors = cn.(event.index)'
		end

	'colors': com = 'self -> select_channel_colors, group=ostate.tlb, do_def=ostate.defaults.do_def'

	'charsize': com = 'self -> set, charsize = event.value'

	'charthick': com = 'self -> set,charthick=event.value, ' + $
		'xthick=event.value, ythick=event.value'

	'legend_loc': com = 'self -> set, legend_loc = event.index'

	'timestamp': com = 'self -> set, no_timestamp = (event.select eq 0)'

	'user_label': com = 'self -> set, user_label=event.value[0]'

	'chan': begin
		ind = widget_selected(event.id, /index)
		q = where (ind eq 0, count)	; 0 index is the all option
		if count gt 0 then $
			ind = indgen(n_elements(*ostate.original_plot_control.dim1_ids)) $
		else $
			ind = (ind - 1) > 0
		com = 'self -> set, dim1_use=ind'
		end

	'sum': com='self -> set, dim1_sum = event.select'

	else: found = 0

endcase

if sel_overlay ne -1 then begin
    overlay_panel = self -> get(/overlay_panel)
    if sel_overlay eq 0 then overlay_panel[overlay_num] = '' else $
      overlay_panel[overlay_num] = ostate.ov_panel_descs[sel_overlay]
    com = 'self -> set, overlay_panel = overlay_panel'
endif
    
if com ne '' then result = execute(com)

end


; gather up all values that wouldn't cause an event unless user hit return
; note: cw_field does not cause an event, but cw_range and cw_edroplist do cause
; event when value has changed and focus is placed on another field in widget.
; If anything's changed, set ostate.any_change to 1, and set the all the values
; into plotman object (don't bother checking which ones changed, set all)

pro plotman::xyoptions_checkvals, ostate

pc = self -> get(/plot_control)

if xalive(ostate.w_xrange) then widget_control, ostate.w_xrange, get_value=xrange else xrange=[0.,0.]
if xalive(ostate.w_timerange) then widget_control, ostate.w_timerange, get_value=timerange else timerange=[0.d,0.d]
widget_control, ostate.w_yrange, get_value=yrange
widget_control, ostate.w_nsum, get_value=nsum
widget_control, ostate.w_symsize, get_value=symsize
widget_control, ostate.w_charsize, get_value=charsize
widget_control, ostate.w_thick, get_value=thick
widget_control, ostate.w_charthick, get_value=charthick
widget_control, ostate.w_user_label, get_value=user_label


; If any of these values have changed, set any_change (which may have already been 1).
; If any_change is set, set them in object.
if (pc.pp.nsum ne nsum[0]) or $
	(pc.pp.symsize ne symsize[0]) or $
	(pc.pp.charsize ne charsize[0]) or $
	(pc.pp.charthick ne charthick[0]) or $
	(pc.pp.thick ne thick[0]) or $
	(pc.user_label ne user_label[0]) or $
	not same_data(pc.xx.range, xrange, /notype_check) or $
	not same_data(pc.timerange, timerange, /notype_check) or $
	not same_data(pc.yy.range, yrange, /notype_check) then $
		ostate.any_change = 1

if ostate.any_change then begin
	; note: use charthick for axes thickness too
	self -> set, nsum=nsum, symsize=symsize, charsize=charsize, $
		thick=thick, charthick=charthick, xthick=charthick, ythick=charthick, $
		user_label=user_label[0], xrange=xrange, timerange=timerange, yrange=yrange
endif

end

;-----

pro plotman::xyoptions_widget, event, ostate, defaults

parent = event.top

plot_control = self -> get(/plot_control)
plot_type = plot_control.plot_type

panel_plot_types = self -> get(/all_panel_plot_type)
if plot_type eq 'utplot' then $
	ov_panel_numbers = where (panel_plot_types eq 'utplot' or panel_plot_types eq 'specplot', count) $
else $
	ov_panel_numbers = where (panel_plot_types eq 'xyplot', count)
panel_descs = self -> get(/all_panel_desc)
ov_panel_descs = 'No Overlay'
if count gt 0 then ov_panel_descs = [ov_panel_descs, panel_descs[ov_panel_numbers]]

vals = get_pointer(plot_control.dim1_ids, status=status)
multi_channel = 0
if status then begin
	q = where (vals ne '', count)
	if count gt 1 then multi_channel = 1
endif
;multi_channel = status ? ( vals[0] eq ''  ? 0 : 1) : 0

sym_selections = ['None', 'Plus', 'Asterisk', 'Period', 'Diamond', $
	'Triangle', 'Square', 'X']

colorstr = self -> get(/color_names)

if defaults.do_def then $
	title = defaults.do_existing ? 'Plot Display Options for Selected Plots' : 'Plot Default Options for Future Plots' $
else title = 'Plot Display Options for Current Plot'
if not defaults.do_existing then title = (plot_type eq 'xyplot' ? 'XY ' : 'UT ') + title

redgreen_text1 = 'Click red/green buttons to enable/disable default setting.'
redgreen_text2 = 'ONLY green items are used on exit. Red items are ignored.'

get_font, font, big_font=big_font
widget_control, default_font = font

tlb = widget_base (group_leader=parent, $
					title=title, $
					/base_align_center, $
					/column, $
					ypad=0, $
					space=1, $
					/modal )

w_box = widget_base (tlb, /column, /frame, space=1)
tmp = widget_label (w_box, value=title, /align_center, font=big_font)
if defaults.do_def then tmp = widget_label (w_box, value=redgreen_text1, /align_center, font=big_font)
if defaults.do_def then tmp = widget_label (w_box, value=redgreen_text2, /align_center, font=big_font)

if not defaults.do_def then begin
  scroll = 1
  y_scroll_size = 1.5
  units = 1
endif
w_overlay_base = widget_base (w_box, /column, /frame, scroll=scroll, y_scroll_size=y_scroll_size, units=units)

tmp = widget_label (w_overlay_base, value='Current Plot:  ' + self->get(/current_panel_desc), /align_left)

w_overlay_row1 = widget_base(w_overlay_base, /row, space=10)
w_squish =  plotman_defaults_wrapper(defaults, 'cw_bgroup', w_overlay_row1, $
            'Remove extra labels between overlays', $
            uvalue='squish', $
            /nonexclusive, $
            uname='overlay_squish', space=0, ypad=0 )

if not defaults.do_def then tmp = widget_button (w_overlay_row1, value='Unset all overlays', uvalue='unset_overlays')

 if not defaults.do_def then w_noverlay = widget_label (w_overlay_row1, value='', /dynamic_resize) else w_noverlay=0L

; 0th overlay always reserved for self for images, so not used for xyplots.
;  w_overlay_panel indexed from 0 to n-1, but we won't use 0th.
w_overlay_panel = lonarr(plot_control.nmax_overlay)
w_list_panels = lonarr(plot_control.nmax_overlay)

if not defaults.do_def then begin
  for i=1,plot_control.nmax_overlay-1 do begin
  
    w_overlay = widget_base (w_overlay_base, /row, space=10)

	  w_overlay_panel[i] = widget_droplist (w_overlay, $
						title='Overlay #' + trim(i) + ': ', $
						value=ov_panel_descs, $
						uvalue='overlay_panel')
						
		w_list_panels[i] = widget_button(w_overlay, value='List', uvalue='list_panels')
  endfor
endif

;	w_overlay_panel2 = widget_droplist (w_overlay_base, $
;						title='Overlay #2: ', $
;						value=ov_panel_descs, $
;						uvalue='overlay_panel2')
;
;	w_overlay_panel3= widget_droplist (w_overlay_base, $
;						title='Overlay #3: ', $
;						value=ov_panel_descs, $
;						uvalue='overlay_panel3')
;endif else begin
;	w_overlay_panel1 = 0L
;	w_overlay_panel2 = 0L
;	w_overlay_panel3 = 0L
;endelse

w_timerange = 0L & w_xrange = 0L
w_xy_base = widget_base (w_box, /column, space=0, /frame)

if plot_type eq 'utplot' then begin

	w_time_base = widget_base (w_xy_base, $
						/row )

	w_timerange = plotman_defaults_wrapper(defaults, 'cw_ut_range',w_time_base, $
					value=plot_control.utrange, $
					uvalue='axes_timerange', $
					label='', $
					space=1, ypad=1, /align_left, frame=0, $
					uname='timerange')

	w_yrange_base = w_xy_base

endif else begin

	;w_xbase = widget_base (w_box, $
	;					/row, $
	;					space=5, $
	;					ypad=0, $
	;					frame=0 )

	w_xy = widget_base (w_xy_base, /row, space=10)

	w_xrange = plotman_defaults_wrapper(defaults,'cw_range', w_xy, $
						uvalue='axes_xrange', $
						value=[0.,0.], $
						format='(g12.4)', $
						label1='X Limits: ', $
						label2=' - ', $
						uname='xrange' )

	w_yrange_base = w_xy
endelse

w_ybase = widget_base (w_yrange_base, $
						/row, $
						space=5 )

w_yrange = plotman_defaults_wrapper(defaults, 'cw_range', w_ybase, $
						uvalue='axes_yrange', $
						value=[0.,0.], $
						format='(g12.4)', $
						label1='Y Limits: ', $
						label2=' - ', $
						uname='yrange' )

; if utplot, then base is wider, so put reset button to right of y limit stuff.  Otherwise
; put reset below.
if plot_type eq 'utplot' then base = w_ybase else base = w_xy_base
w_reset = widget_button (base, $
					value='Reset limits', $
					/align_center, $
					/menu)

temp = widget_button (w_reset, $
						value='X only', $
						uvalue='axes_xreset' )

temp = widget_button (w_reset, $
					value='Y only', $
					uvalue='axes_yreset' )

temp = widget_button (w_reset, $
					value='X and Y', $
					uvalue='axes_xyzreset' )

w_xybase = widget_base (w_box, $
					/row, $
					space=10)
					;/align_center )

w_x = widget_base (w_xybase, /row, /frame)

temp = widget_label (w_x, value='X axis:  ')

w_xlog = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_x, $
					'Log', $
					uvalue='axes_xlog', $
					/nonexclusive, $
					;sensitive= (plot_type ne 'utplot'), $
					uname='xlog', space=0, ypad=0 )


w_xexact = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_x, $
					'Exact', $
					uvalue='axes_xexact', $
					/nonexclusive, $
					uname='xexact', space=0, ypad=0 )

w_y = widget_base (w_xybase, /row, /frame)

temp = widget_label (w_y, value='Y axis:  ')

w_ylog = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_y, $
					'Log', $
					uvalue='axes_ylog', $
					/nonexclusive, $
					uname='ylog' )

w_yexact = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_y, $
					'Exact', $
					uvalue='axes_yexact', $
					/nonexclusive, $
					uname='yexact', space=0, ypad=0 )

w_deriv = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_y, $
					'Derivative', $
					uvalue='deriv', $
					/nonexclusive, $
					uname='derivative,integral' )

w_integ = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_y, $
					'Integral', $
					uvalue='integ', $
					/nonexclusive, $
					uname='derivative,integral', space=0, ypad=0 )

w_npt_row = widget_base (w_box, /row, space=4)

w_nsum_base = widget_base (w_npt_row, /row, space=0) ; just to get red box closer
w_nsum = plotman_defaults_wrapper(defaults, 'cw_field', w_nsum_base, $
					title='Number of points to average:', $
					value='', $
					xsize=5, $
					/return_events, $
					uvalue='nsum', $
					uname='nsum' )

w_opt_base1 = widget_base (w_npt_row, /row, space=0)

w_hist = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_opt_base1, $
					'Histogram Mode', $
					uvalue='hist', $
					/nonexclusive, $
					uname='psym', space=0, ypad=0 )

w_thick_base = widget_base(w_npt_row, /row, space=0)  ; just to get red box closer
w_thick =  plotman_defaults_wrapper(defaults, 'cw_field', w_thick_base, $
					title='Thickness: ', $
					value='', $
					xsize=2, $
					/return_events, $
					uvalue='thick', $
					uname='thick')

w_fill_base = widget_base (w_npt_row, /row, space=0)
w_fill_gaps = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_fill_base, $
          'Fill Gaps', $
          uvalue='fillgaps', $
          /nonexclusive, $
          uname='fill_gaps', space=0, ypad=0 )

w_opt_row2 = widget_base (w_box, /row, space=10, frame=0)

w_sym_base = widget_base (w_opt_row2, /row )

w_sym =  plotman_defaults_wrapper(defaults, 'widget_droplist' ,w_sym_base, $
					title='Data Point Symbols:', $
					value=sym_selections, $
					uvalue='sym', $
					uname='psym' )

w_connect =  plotman_defaults_wrapper(defaults, 'cw_bgroup', w_sym_base, $
						'Connect', $
						uvalue='connect', $
						/nonexclusive, $
						uname='psym', space=0, ypad=0 )

w_symsize =  plotman_defaults_wrapper(defaults, 'cw_field', w_sym_base, $
					title='Size:', $
					value='', $
					xsize=4, $
					/return_events, $
					uvalue='symsize', $
					uname='symsize' )

if multi_channel or defaults.do_def then begin
	w_color = plotman_defaults_wrapper(defaults, 'widget_button', w_opt_row2, value='Colors', uvalue='colors', $
		uname='dim1_colors')
endif else begin
	w_color = widget_droplist (w_opt_row2, title='Color:', value=tag_names(colorstr), uvalue='1color')
endelse

w_char_base0 = widget_base (w_box, /column, /frame)

w_char_base = widget_base (w_char_base0, /row, space=4)

w_charsize =  plotman_defaults_wrapper(defaults, 'cw_field', w_char_base, $
					title='Char size: ', $
					value='', $
					xsize=5, $
					/return_events, $
					uvalue='charsize', $
					uname='charsize')

w_charthick =   plotman_defaults_wrapper(defaults, 'cw_field', w_char_base, $
					title='Char/Axes Thickness: ', $
					value='', $
					xsize=2, $
					/return_events, $
					uvalue='charthick', $
					uname='charthick,xthick,ythick')

w_legend_loc =  plotman_defaults_wrapper(defaults, 'widget_droplist', w_char_base, $
					title='Legend: ', $
					value=['None', 'Upper Left', 'Upper Right', 'Lower Left', 'Lower Right', $
						'Outside Plot, Left', 'Outside Plot, Right'], $
					uvalue='legend_loc', $
					uname='legend_loc')

w_label_base = widget_base (w_char_base0, /row)

w_user_label =  plotman_defaults_wrapper(defaults, 'cw_field' ,w_label_base, $
					/string, $
					/return_events, $
					title='User Label: ', $
					value=' ', $
					xsize=50,  $
					uvalue='user_label', $
					uname='user_label')

w_timestamp =  plotman_defaults_wrapper(defaults, 'cw_bgroup', w_label_base, $
					'Timestamp', $
					uvalue='timestamp', $
					/nonexclusive, $
					uname='no_timestamp', space=0, ypad=0 )

;if defaults.do_def then begin
;	w_sum = widget_base (w_box, /row, /frame)
;	w_index1 = 0L
;	w_sumindex1 = plotman_defaults_wrapper(defaults, 'cw_bgroup', w_sum, $
;						'Sum all channels', $
;						uvalue='sum', $
;						/nonexclusive, $
;						uname='dim1_sum', $
;						sensitive= plot_control.dim1_enab_sum, space=0, ypad=0 )
;endif else begin

	if multi_channel then  begin

		w_dim1 = widget_base (w_box, /column, /frame, space=1)

		temp = widget_label (w_dim1, /align_center, value='Select ' + plot_control.dim1_name + ' to plot')

		w_sumchan = widget_base (w_dim1, /row, space=30)

	;	schan = ['All', *plot_control.dim1_ids]
	;	nchan = n_elements(schan)-1
	;	sel = intarr(nchan)
	;	sel(*plot_control.dim1_use) = 1
	;	if min(sel) eq 1 then set=0 else set = *plot_control.dim1_use + 1

		nlist = n_elements(vals)+1
		w_index1 = plotman_defaults_wrapper( defaults, 'widget_list', w_sumchan,  $
							/multiple, $
							ysize=nlist < 8, $
							xsize= (max(strlen(vals)) + 2) < 70, $
							value=' ', $
							uvalue='chan', $
							uname='dim1_use')

		;widget_control, w_chan, set_list_select=set

;		w_opt_base2 = widget_base (w_sumchan, $
;							/column, $
;							/nonexclusive, $
;							/align_left)

		w_sumindex1 = plotman_defaults_wrapper (defaults, 'cw_bgroup', w_sumchan, $
							'Sum', $
							uvalue='sum', $
							/nonexclusive, space=0, ypad=0, $
							uname='dim1_sum')
		widget_control, w_sumindex1, sensitive= plot_control.dim1_enab_sum

	endif else begin

		w_index1 = 0L
		w_sumindex1 = 0L

	endelse
;endelse

ostate = { $
	tlb: tlb, $
	parent: parent, $
;	plot_type: plot_type, $
	ov_panel_descs: ov_panel_descs, $
	w_noverlay: w_noverlay, $
	w_overlay_panel: w_overlay_panel, $
	w_list_panels: w_list_panels, $
;	w_overlay_panel2: w_overlay_panel2, $
;	w_overlay_panel3: w_overlay_panel3, $
	w_squish: w_squish, $
	w_timerange: w_timerange, $
	w_xrange: w_xrange, $
	w_yrange: w_yrange, $
	w_zrange: 0L, $
	w_xlog: w_xlog, $
	w_ylog: w_ylog, $
	w_xexact: w_xexact, $
	w_yexact: w_yexact, $
	w_nsum: w_nsum, $
	w_hist: w_hist, $
	w_thick: w_thick, $
	w_fill_gaps: w_fill_gaps, $
	w_deriv: w_deriv, $
	w_integ: w_integ, $
	w_sym_base: w_sym_base, $
	w_sym: w_sym, $
	w_connect: w_connect, $
	w_symsize: w_symsize, $
	w_color: w_color, $
	w_charsize: w_charsize, $
	w_charthick: w_charthick, $
	w_legend_loc: w_legend_loc, $
	w_timestamp: w_timestamp, $
	w_user_label: w_user_label, $
	w_index1: w_index1, $
	w_sumindex1: w_sumindex1 }

end
