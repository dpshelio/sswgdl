;+
; Project     : SOHO-CDS
;
; Name        : MAP2GIF
;
; Purpose     : make series of GIF images from series of maps
;
; Category    : imaging
;
; Syntax      : map2gif,map,names
;
; Inputs      : MAP = array of map structures
;               NAMES = array of output GIF names [def = framei.gif]
;
; Keywords    : DRANGE = [dmin,dmax], min and max values to scale data
;               SIZE = [min,max], dimensions of MPEG movie (def= [512,512])
;               PREFIX = If NAMES isn't provided, then gif file names will be
;                       prefixnn.gif where nn is the image number
;               NOSCALE = If set, don't scale to min/max of all images (def=0)
;               STATUS = Returns 0/1 for failure/success
;
; History     : Written 11 Jan 2000, D. Zarro, SM&A/GSFC
;               Version 2, 13-Aug-2003, William Thompson
;                       Use SSW_WRITE_GIF instead of WRITE_GIF
;               10-Feb-2005, Kim Tolbert.  Corrected !p.colors->!p.color, added
;                       noscale and status keywords
;
; Contact     : dzarro@solar.stanford.edu
;-

pro map2gif,map,names,drange=drange,prefix=prefix,_extra=extra,$
                      size=gsize, noscale=noscale, status=status

status = 0

if not valid_map(map) then begin
 pr_syntax,'map2gif,map,names'
 return
endif

if not test_dir(curdir()) then return

;-- create output names

nmaps=n_elements(map)
if (datatype(names) eq 'STR') and (n_elements(names) eq nmaps) then fnames=names else begin
 ids=trim(str_format(sindgen(nmaps),'(i4.2)'))
 if datatype(prefix) eq 'STR' then gfix=prefix else gfix='frame'
 fnames=gfix+ids+'.gif'
endelse

if n_elements(drange) ne 2 then begin
 if keyword_set(noscale) then drange=[0.,0.] else begin
   dmin=min(map.data,max=dmax)
   drange=[dmin,dmax]
 endelse
endif

psave=!d.name
set_plot,'z',/copy
xsize=500 & ysize=500
ncolors=!d.table_size
csave=ncolors
if not exist(gsize) then zsize=[xsize,ysize] else $
  zsize=[gsize(0),gsize(n_elements(gsize)-1)]
device,/close,set_resolution=zsize,set_colors=ncolors
!p.color=ncolors-1

tvlct,rs,gs,bs,/get

for i=0,nmaps-1 do begin
 plot_map,map(i),drange=drange,_extra=extra
 dprint,'% writing fnames(i)..'
 temp=tvrd()
 device,/close
 ssw_write_gif,fnames(i),temp,rs,gs,bs
endfor

if exist(psave) then set_plot,psave
if exist(csave) then !p.color=csave

status=1
return & end


