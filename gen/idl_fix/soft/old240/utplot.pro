;.........................................................................
;+
; NAME:
;	UTPLOT
; PURPOSE:
;	Plot X vs Y with Universal time labels on bottom X axis.  X axis
;	range can be as small as 5 msec or as large as 20 years.
; CALLING SEQUENCE:
;	UTPLOT,X,Y
;	UTPLOT, roadmap, y
;	utplot, x, y, '1-sep-91'
;	utplot, x, y, '1-sep-91', timerange=['1-sep-91', '2-sep-92']
;	utplot, x, y, '1-sep-91', timerange=[index(0), index(i)], xstyle=1
; INPUTS:
;	X -	X array to plot in seconds relative to base time.
;		(MDM) Structures allowed
;	Y -	Y array to plot.
;	xst -	Optional. The reference time to use for converting a structure
;		into a seconds array (OR) the time for the first value if 
;		passing a floating array.
;	timerange - Optional. This can be a two element time range to be 
;		plotted.  It can be a string representation or structure.
;
;	LBL - 	2 element vector selecting substring from publication format
;	   	of ASCII time (YY/MM/DD, HH:MM:SS.XXX).  For example, 
;	   	LBL=[11,18] would select the HH:MM:SS part of the string.
;       SAV -	If set, UTPLOT labels, tick positions, etc. in !X... system
;		variables will remain set so that they can be used by 
;		subsequent plots (normally !x... structure is saved in 
;		temporary location before plot and restored after plot).  
;		To clear !x... structure, call CLEAR_UTPLOT.
;	TICK_UNIT - Time between Major tick marks is forced to TICK_UNIT
;		    Has no effect for axis longer than 62 days.
;	MINORS	  - Number of minor tick marks is forced to MINORS
;	NOLABEL	If set then UTLABEL isn't printed on plot
;	XTITLE - text string for x-axis label - If the string contains
;		 4 asterisks ('****'), the UT time will be substituted
;		 for that substring	
; OPTIONAL OUTPUT PARAMETERS:
;	None.
; COMMON BLOCKS:
;	COMMON UTCOMMON, UTBASE, UTSTART, UTEND = base, start, and 
;	end time for X axis in double precision variables containing
;	seconds since 79/1/1, 00:00.
;       COMMON UTSTART_TIME, PRINT_START_TIME = 0/1: don't/do print
;       start time label on plot
; SIDE EFFECTS:
;	X vs Y plot is produced on current graphics device.  The normal 
;	X-axis is replaced by an axis with ticks and labels showing the 
;	universal time.  The start time of the plot is displayed in the 
;	upper right inside corner of the plot if SET_UTLABEL,0 hasn't been
;	called.
; RESTRICTIONS:
;	Cannot be used for times before 79/1/1 or after 99/1/1.
;	Range of X axis can be anywhere between 5 msec and 20 years.
; PROCEDURE:
;	If start or end time hasn't been set, autoscale X axis. 
;	If either has been set (via routines SETUTSTART	and SETUTEND, 
;	or directly), only data between times selected will be displayed; 
;	i.e. X min = UTSTART - UTBASE; X max = UTEND - UTBASE.  
;	Calls SET_UTPLOT using keyword LABELPAR to customize X 
;	axis labels and tickmarks.  Otherwise it uses all normal plotting 
;	procedures and 	the !X and !Y system variables.
;	Note:   Format of time written in labels differs slightly from format
;	used to pass times to routines.  Input format contains only one colon
;	between minutes and seconds (makes the meaning of a partial string 
;	precise) while labels include an extra colon between hours and minutes 
;	(more acceptable for publication).
; MODIFICATION HISTORY:
;	Written by Kim Tolbert, 4/88.
;	Mod. by Richard Schwartz to Version 2 91/02/17
;       Mod. by Richard Schwartz for compatibility with OPLOT. 3/26/91
;	Mod. by RAS, keywords TICK_UNIT and MINORS added 91/05/02
;	MOD. BY RAS TO ACCEPT ALL PLOT KEYWORDS, 91/10/03
;	Mod. by MDM to only save utstart setting if it is already defined
;	Mod by MDM to work with YOHKOH data (structure data types)
;	Mod by MDM to expand the COMMON block so that OUTPLOT will work
;	Mod by MDM 21-Apr-92 to not set !quiet
;	Mod by SLF 26-Apr-92 to reinstate the xtitle option
;	Mod by MDM 28-Aug-92 to add keyword YEAR to print the year on the
;		  tick label
;	Mod by MDM  9-Apr-93 to added TIMERANGE option
;	Mod by MDM 12-Apr-93 to removed ZMARGIN since older IDL versions had
;		  trouble with 9-Apr addition of TIMERANGE parameter
;-
PRO UTPLOT, X0, Y0, XST0, LABELPAR=LBL ,SAVE=SAV,TICK_UNIT=TICK_UNIT,$
	MINORS=MINORS , NOLABEL=NOLABEL, $
	timerange=timerange, $					;MDM added 9-Apr-93

	$	;include all keywords available to PLOT
	background=background, channel=channel, charsize=charsize, $
	charthick=charthick, clip=clip, color=color, data=data, device=device, $
	font=font, linestyle=linestyle, noclip=noclip, nodata=nodata, $
	noerase=noerase, normal=normal, nsum=nsum, polar=polar, $
	position=position, psym=psym, subtitle=subtitle, symsize=symsize, $
	t3d=t3d, thick=thick, ticklen=ticklen, title=title, $
	year=year, $						;MDM added 26-Aug-92

	xrange=xrange, xcharsize=xcharsize, xmargin=xmargin, xminor=xminor, $
	xstyle=xstyle, xticklen=xticklen, xticks=xticks, $
	xtitle=xtitle, $

	ycharsize=ycharsize, ymargin=ymargin, yminor=yminor, yrange=yrange, $
	ystyle=ystyle, yticklen=yticklen, ytickname=ytickname, yticks=yticks, $
	ytickv=ytickv, ytitle=ytitle, ytype=ytype, $
	ynozero=ynozero, $					;MDM added 16-Nov-91

	zcharsize=zcharsize, zminor=zminor, zrange=zrange, $	;MDM removed 12-Apr-93 zmargin=zmargin, 
	zstyle=zstyle, zticklen=zticklen, ztickname=ztickname, zticks=zticks, $
	ztickv=ztickv, ztitle=ztitle			;MDM removed 26-Aug-92, ztype=ztype

;.........................................................................
;
quiet_save = !quiet
!quiet=1
on_error,2
;
COMMON UTSTART_TIME,PRINT_START_TIME
COMMON UTCOMMON, UTBASE, UTSTART, UTEND, xst
;
;--------------------- MDM added
siz = size(x0)
typ = siz( siz(0)+1 )
y = y0
if (n_elements(xst0) ne 0) then begin
    ex2int, anytim2ex(xst0), xst_msod, xst_ds79
    xst = [xst_msod, xst_ds79]
end else begin
    ;If pass just a vector, then xst better be passed also or there will be problems
    ex2int, anytim2ex(x0(0)), xst_msod, xst_ds79
    xst = [xst_msod, xst_ds79]
end
;
if (typ eq 8) then x = int2secarr(x0, xst) else x = x0
;
utstring = anytim2utplot(xst)
;
;.........................................................................
xsave = !x

if (keyword_set(timerange)) then begin		;MDM added 9-Apr-93
    !x.range(0) = int2secarr(timerange(0), xst)
    !x.range(1) = int2secarr(timerange(1), xst)
    xrange = !x.range
end

	checkvar, xrange, !x.range ; if a range is passed use it, otherwise pass x
	if (xrange(0) eq 0.) and (xrange(1) eq 0.) then xrange = x
	checkvar,xstyle,!x.style
	checkvar,minors,xminor,!x.minor ;minors or xminor or !x.minor 

;

;.........................................................................
;SET THE X AXIS VARIABLES RELEVANT FOR UTPLOT AXIS
;.........................................................................
if (n_elements(utstart) ne 0) then begin	;MDM Save only if already defined
    utstart_old = utstart
    utend_old   = utend
end
SET_UTPLOT,xrange=xrange,labelpar=lbl,utbase=utstring,error_range=error_range,$
	err_format=err_format,tick_unit=tick_unit,minors=xminor,xstyle=xstyle, year=year
;IN CASE UTSTART AND UTEND WERE CHANGED DURING THE CALL TO SET_UTPLOT
if (n_elements(utstart_old) ne 0) then begin	;MDM Restore only if already defined
    utstart = utstart_old
    utend   = utend_old
end
utplot_s = !x ;save new x labels
if error_range or err_format then goto,return1

;

;.........................................................................
	psave = !p
        !p.background=fcheck(background,!p.background)
	!p.channel=fcheck(channel,!p.channel)
	!p.charsize=fcheck(charsize,!p.charsize)
	!p.charthick=fcheck(charthick,!p.charthick)
	!p.clip=fcheck(clip,!p.clip)
	!p.color=fcheck(color,!p.color)
	!p.font=fcheck(font,!p.font)
	!p.linestyle=fcheck(linestyle,!p.linestyle)
	!p.noclip=fcheck(noclip,!p.noclip)
	!p.noerase=fcheck(noerase,!p.noerase)
	!p.nsum=fcheck(nsum,!p.nsum)
	!p.position=fcheck(position,!p.position)
	!p.psym=fcheck(psym,!p.psym)
	!p.subtitle=fcheck(subtitle,!p.subtitle)
	!p.t3d=fcheck(t3d,!p.t3d)
	!p.thick=fcheck(thick,!p.thick)
	!p.ticklen=fcheck(ticklen,!p.ticklen)
	!p.title=fcheck(title, !p.title)

	!x.charsize=fcheck(xcharsize, !x.charsize)
	!x.margin=fcheck(xmargin, !x.margin)
	!x.ticklen=fcheck(xticklen, !x.ticklen)
	!x.title=fcheck(xtitle,!x.title)
	!x.style=fcheck(xstyle,!x.style)		;MDM added

	ysave = !y
	!y.charsize=fcheck(ycharsize, !y.charsize)
	!y.margin=fcheck(ymargin, !y.margin)
	!y.minor=fcheck(yminor, !y.minor)
	!y.range=fcheck(yrange, !y.range)
	!y.style=fcheck(ystyle, !y.style)
	!y.ticklen=fcheck(yticklen,!y.ticklen)
	!y.tickname=fcheck(ytickname,!y.tickname)
	!y.ticks=fcheck(yticks, !y.ticks)
	!y.tickv=fcheck(ytickv, !y.tickv)
	!y.title=fcheck(ytitle,!y.title)
	!y.type=fcheck(ytype, 0) ;clear ytype

	zsave = !z
	!z.charsize=fcheck(zcharsize, !z.charsize)
	!z.margin=fcheck(zmargin, !z.margin)
	!z.minor=fcheck(zminor, !z.minor)
	!z.range=fcheck(zrange, !z.range)
	!z.style=fcheck(zstyle, !z.style)
	!z.ticklen=fcheck(zticklen,!z.ticklen)
	!z.tickname=fcheck(ztickname,!z.tickname) 
	!z.ticks=fcheck(zticks, !z.ticks)
	!z.tickv=fcheck(ztickv, !z.tickv)
	!z.title=fcheck(ztitle,!z.title)
	!z.type=fcheck(ztype, !z.type) 

	   start_time=GETUTBASE(0) + !x.crange(0)
	   LABW = ATIME(start_time,/PUB)
	   TLABW =  strmid(LABW,0,18)	   
	   LABEL = 'Start Time (' + TLABW   + ')'	        ;MDM remove the msec part of the label
;	!x.title=fcheck(label, !x.title)			;MDM added
        if keyword_set(xtitle) then $
           xtitle=str_replace(xtitle,'****',' ' + tlabw + ' ')	;slf,24-jul-92
	!x.title=fcheck(xtitle, label)				;slf,24-jul-92
plot,x,y, data=fcheck(data), device=fcheck(device), $
	nodata=fcheck(nodata), $
	normal=fcheck(normal), $
	ynozero=fcheck(ynozero), $
	polar=fcheck(polar), $
	symsize=fcheck(symsize,1.0), ytype=!y.type

AFTERXLABELS:
;
; Write label with start time in top right inside corner of plot
CHECKVAR,PRINT_START_TIME,1
IF (PRINT_START_TIME EQ 1) AND (NOT KEYWORD_SET(NOLABEL)) THEN BEGIN
	   start_time=GETUTBASE(0) + !x.crange(0)
	   LABW = ATIME(start_time,/PUB)
	   LABEL = 'Plot Start: ' + LABW   
;; MDM removed	   UTLABEL,LABEL
ENDIF
;
return1:

;save new system variables needed for overplotting
xcrange = !x.crange
xs      = !x.s
xwindow = !x.window
xregion = !x.region

ycrange = !y.crange
ys      = !y.s
ywindow = !y.window
yregion = !y.region
ytype   = !y.type

zcrange = !z.crange
zs      = !z.s
zwindow = !z.window
zregion = !z.region
ztype   = !z.type

pmulti  = !p.multi
pclip   = !p.clip
;restore original system variables

!x=xsave
!p=psave
!y=ysave
!z=zsave

;replace system variables needed for overplotting
!x.crange = xcrange
!x.s      = xs
!x.window = xwindow
!x.region = xregion

!y.crange = ycrange
!y.s      = ys
!y.window = ywindow
!y.region = yregion
!y.type   = ytype

!z.crange = zcrange
!z.s      = zs
!z.window = zwindow
!z.region = zregion
!z.type   = ztype

!p.multi  = pmulti
!p.clip   = pclip
if keyword_set(sav) then begin
	!x.tickv = utplot_s.tickv
	!x.tickname = utplot_s.tickname
	!x.minor = utplot_s.minor
	!x.ticks = utplot_s.ticks
endif

!quiet = quiet_save
return
end

