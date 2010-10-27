pro plot_goes, input1, input2,  bcolor=bcolor, color=color , $
	fem=fem, fillnight=fillnight, saa=saa, fillsaa=fillsaa, $
	gdata=gxr_rec, low=low, high=high, title=title, gcolor=gcolor, $
	nodeftitle=nodeftitle, charsize=charsize, no6=no6, no7=no7, $
	xstyle=xstyle, xmargin=xmargin, ymargin=ymargin, ystyle=ystyle, $
	ytitle=ytitle, thick=thick, charthick=charthick, xtitle=xtitle, $
	three=three
;+
;   Name: goes_plot
;
;   Purpose: plot goes x-ray data (Yohkoh structure) 
;
;   Input Parameters:
;      input1 - user start time or goes xray data record structure array
;      input2 - user stop time
;
;   Optional Keyword Paramters:
;      fem - if set, overplot Yohko ephemeris grid (call fem_grid)
;      fillnight - (pass to fem_grid) - polyfill Yohkoh nights
;      fillsaa   - (pass to fem_grid) - polyfill Yohkoh saas
;      saa       - (pass to fem_grid) - show saa events overlay grid
;      low 	 - if set, only plot low energy
;      high      - if set, only plot high energy
;      title     - user title (appended to default title predicate)
;      nodeftitle- if set, dont append default title predicate
;	color    - color of lines
;
;   Calling Sequence:
;      plot_goes,'5-sep-92'		; start time + 24 hours
;      plot_goes,'5-sep-92',/three	; same, but use 3 second data
;      plot_goes,'5-sep-92',6		; start time +  6 hours
;      plot_goes,'5-sep-92','7-sep-92'  ; start time / stop time
;      plot_goes,gxtstr			; input goes records from rd_gxt
;      plot_goes,'5-sep',/fem		; overplot Yohkoh ephemeris grid
;      plot_goes,'5-sep',/fillnight	; ditto, but fill in Yohkoh nights 
;      plot_goes,'1-jun','30-jul',/low  ; only plot low energy
;      
;
;   History: slf 22-sep-1992
;	     slf 11-oct-1992 - added low and high keywords, add documentation
;	     slf 26-oct-1992 - added nodeftitle keyword
;            slf 15-mar-1993 - return on no data
;	     mdm 24-Mar-1993 - corrected error due to integer overflow
;	     slf 19-Jul-1993 - implemented LO and HI keyword function
;	     slf 29-jul-1993 - added max_value keyword (pass to utplot)
;	     slf  4-sep-1993 - add charsize, no6, no7 keywords
;	     slf 22-Nov-1993 - added lots of plot keyowords
;	     jrl  1-dec-1993 - added thick, charthick, xtitle keywords
;	     slf  5-dec-1993 - set default xstyle = 1
;	     slf, 7-dec-1993 - a) added three (second) keyword and functions
;			       c) gave up on any and all hopes for clean logic
;	     slf, 11-dec-1993 - removed max form current rev so this could
;				run under old versions of idl (w/new features)
;-
qtemp=!quiet
if n_elements(input2) eq 0 then input2=24	

sinput1=size(input1)
sinput2=size(input2)
if sinput1(1) eq 0 then $
   input1=gt_day(addtime(syst2ex(),delta=-24*60),/str)

three=keyword_set(three)
repeats= three * (1-keyword_set(no6) and 1-keyword_set(no7)) + 1

if sinput1(2) ne 8 then begin	
   if sinput2(1) eq 2 then begin		; duration in hours
      start=anytim2ex(input1)
      input2=fmt_tim(addtime(start,delta=input2*60.))		;MDM patch 24-Mar-93 (changed 60 to 60.)
   endif

   if three then begin
      message,/info,'Using 3 second data...'
      case 1 of 		; messy due to maintaining existing logic
         keyword_set(no6): rd_gxd,input1,input2, gxr_rec, /goes7
         keyword_set(no7): rd_gxd,input1,input2, gxr_rec,/goes6
         else: rd_gxd,input1,input2, gxr_rec,  /goes7
      endcase
      yrange=[1.e-9, 1.e-3]
      proc='utplot_io'
   endif else begin
      rd_gxt,input1, input2, gxr_rec 
      yrange=[101,679]
      proc='utplot'
   endelse

endif else gxr_rec=input1   

if n_elements(gxr_rec) lt 2 then begin	; return on no data
   types=['',' three second ']
   message,/info,'No ' + types(three) + 'GOES data available for specified time'
   return
endif

gapsize=10						;dont plot gaps
labels=['G7 Low','G6 Low','G7 High','G6 High']
delim=['',': ']
mtitle='GOES X-Rays' 
if keyword_set(no6) then mtitle='GOES 7 X-Rays'
if keyword_set(no7) then mtitle='GOES 6 X-Rays'
if keyword_set(nodeftitle) then mtitle=''
if not keyword_set(title) then title=''
mtitle=mtitle + delim(keyword_set(mtitle)) + title
linestyle=[0,1,0,1]
psym=[-3,3,-3,3]
symsize=[.7,1,.7,1]
usersym,[-1,1],[0,0]


offset=2					 	; first data field
yticks=6
ytickname=['1E-9','A  ','B  ','C  ','M  ','X  ','1E-3']
yminor=1
ymax=679

; set up the axis labels and plot scaling
if n_elements(xstyle) eq 0 then xstyle=1

; slf 7-dec-1993 - add three second option - use log plot if 3 sec
yrtemp=!y.crange
!y.crange=yrange
call_procedure,proc,gxr_rec,indgen(n_elements(gxr_rec)) < ymax ,/nodata, $
    yminor=yminor, yticks=yticks, yticklen=.001, ytickname=ytickname, $	; JRL set yticklen = .001
    title=mtitle,  yrange=yrange, charsize=charsize, charthick=charthick, $
    xstyle=xstyle, ystyle=1, xmargin=xmargin, ymargin=ymargin, ytitle=ytitle, $
    xtitle=xtitle

!quiet=0		;utplot stuff clobbers this!
; determine which channels to plot
tags=tag_names(gxr_rec)
lochan=where(strpos(tags,'LO') ne -1)
hichan=where(strpos(tags,'HI') ne -1)
g6chan=where(strpos(tags,'G6') ne -1)
g7chan=where(strpos(tags,'G7') ne -1)

case 1 of
   keyword_set(low) and 1-keyword_set(high):  wchan=lochan
   keyword_set(high) and 1-keyword_set(low):  wchan=hichan
   keyword_set(no6) and (1-three): wchan=g7chan
   keyword_set(no7) and (1-three): wchan=g6chan
   else: wchan=[lochan, hichan]
endcase

if n_elements(wchan) eq 2 or repeats eq 2 then psym=[-3,-3]

case 1 of 
   n_elements(color) eq 0: color=intarr(4)+255
   n_elements(color) lt n_elements(wchan): $
	color=replicate(color(0),n_elements(wchan))
   else:color=color(0:n_elements(wchan)-1)
endcase

if !d.name eq 'PS' then color = 255 - color 


for rep=0, repeats-1 do begin			; loop added for 3 second

; now plot the valid points
for i=0, n_elements(wchan)-1 do begin		; for each desired channel
   valid=where(gxr_rec.(wchan(i))+1)		; initial val=-1
;
; ------------------- uplot_gap.pro subroutine?? -------------------------
   dvalid=deriv_arr(valid)			; identify gaps
   rgst=0 & rgsp=n_elements(valid)-1		; at least one interval!
   gapsp = where(dvalid gt gapsize, count)	; discontinuity > gapsize
   if count gt 0 then begin			; at least one gap
      gapst=gapsp+1
      rgst=[rgst,gapst] & rgsp = [gapsp,rgsp]	; define subranges
   endif

   for j=0,n_elements(rgst)-1 do begin		; plot each interval
      if rgst(j) ne rgsp(j) then $		; kludge for now
         outplot,gxr_rec( valid (rgst(j):rgsp(j))), $
            gxr_rec(valid(rgst(j):rgsp(j))).(wchan(i)), color=color(i), $
            psym=psym(i), symsize=symsize(i), thick=thick
   endfor
;------------------------------------------------------------------------
endfor

!quiet=0		;utplot stuff clobbers this!
;  more 3 second logic stuff
   if repeats eq 2 and rep eq 0 then begin
      psym=[3,3]
      message,/info,'reading goes 6
      rd_gxd,input1,input2, gxr_rec,  /goes6
   endif

endfor
;
; overplot Yohkoh ephemeris grid on request
!y.crange=yrange
fem = keyword_set(fem) or keyword_set(fillnight) or $
   keyword_set(fillsaa) or keyword_set(saa)
if fem then $
   fem_grid,fillnight=fillnight, fillsaa=fillsaa, saa=saa
;------------------------------------------------------
; 
; draw grid indicating goes level
if not keyword_set(gcolor) then gcolor=bytarr(6)+255
if !d.name eq 'PS' then gcolor=255-gcolor
goes_grid, color=gcolor ; , color=bindgen(6)*50+50
;
;------------------------------------------------------
;
!quiet=qtemp
return
end
