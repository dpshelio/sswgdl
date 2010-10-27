;+
; Name: plotman::multi_file_output
; Purpose: Plotman method for handling writing fits, save, or plot files for multiple panels.
;	User is prompted for base name of output files, then panel number is appended to each
;	file to make it unique.
;
; Written: Kim Tolbert, 20-Jun-2002
; Modifications:
; 21-Nov-2008, Kim. Call create_plot_file method instead of plotman_create_files_event routine
;
;-


pro plotman::multi_file_output, panels_selected, type

action = type
case type of
	'writesav': ext = '.sav'
	'writefits': ext='.fits'
	'PS': begin
		action = 'plotfile'
		id = (self->get(/widgets)).psid
		ext='.ps'
		end
	'PNG': begin
		action = 'plotfile'
		id = (self->get(/widgets)).pngid
		ext='.png'
		end
	'TIFF': begin
		action = 'plotfile'
		id = (self->get(/widgets)).tiffid
		ext='.tiff'
		end
	'JPEG': begin
		action = 'plotfile'
		id = (self->get(/widgets)).jpegid
		ext='.jpeg'
		end
	'printplot': begin
		action='plotfile'
		id=(self->get(/widgets)).printid
		ext='.ps'
		end
	else: ext=''
end

use_filename = type eq 'printplot' ? 0 : 1

q = where (panels_selected eq 1, count)
if count gt 0 then begin
	current_panel_number = self -> get(/current_panel_number)
	panels = self -> get(/panels)
	out = ''
	if use_filename then begin
		filter = '*' + ext
		def_file = 'idl' + ext
		xack, ['  Select base name for output files', $
			'', $
			'  Panel number will be appended to base name', $
			'  to make a unique file name for each panel.'], $
			title='Select base name', /suppress, space=2
		filename = dialog_pickfile (filter=filter, $
			file=def_file, $
			title = 'Select base name for output files',  $
			group=group)
		if filename eq '' then begin
			err_msg = 'No output file selected.'
			message, err_msg, /cont
			return
		endif
		break_file, filename, disk, dir, ff, ext
		base_name = disk+dir+ff
	endif
	for ii = 0, count-1 do begin
		p = panels -> get_item(q[ii])
		if ptr_valid(p) then begin
			self -> focus_panel, *p, q[ii]
			if use_filename then filename = base_name + '_' + trim(q[ii],'(i3.3)') + ext
			case action of
				'writesav': self -> export, /idlsave, /quiet, $
					filename=filename, msg=msg
				'writefits': self -> export, /fits, /quiet, $
					filename=filename, msg=msg
				'plotfile': self->create_plot_file, type=type, filename=filename, /quiet, msg=msg
			endcase
		endif else msg = 'Invalid panel'
		out = [out, 'Panel ' + trim(q[ii]) + ':  ' + msg]
	endfor
	self->focus_panel, dummy, current_panel_number
endif else out = 'No panels selected.'

a = dialog_message(out, /info)

end
