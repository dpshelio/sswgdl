function ssw_time2paths,time0,time1, parentx, parent=parent, file_pat=file_pat, $ 
      daily=daily, monthly=monthly, weekly=weekly, exist=exist, $
      count=count,year2_digit=year2_digit , flat=flat, $
      hourly=hourly, delimit=delimit, recursing=recursing
;
;+
;   Name: ssw_time2paths
;
;   Purpose: return implied path list for time range; optionally w/file search
;
;   Input Parameters:
;      time0, time1 - desired time range
;      parentx - optional positional synonym for keywor PARENT  (see that)
;
;   Output Parameters:
;     function returns directory list 
;       -OR- full file path  if FILE_PAT supplied 
;
;   Keyword Parameters:
;     parent - path to top of tree (may be NFS path or URL for example)
;     file_pat - optional file pattern for file search 
;     daily - set if organization is <parent>/yyyy/mm/dd/
;     monthly - set if organization is <parent>/yyyy/mm/
;     weekly  - set if organization is <parent>/weekid (per anytim2weekinfo.pro)
;     exist - if set, check for existence and return only those   
;             (could be much slower; default returns "idealized" list)
;     count - number of elements returned by this function
;     flat - switch - if set,paths are flattened
;            e.g. <parent>/yyyymmdd instead of <parent>/yyyy/mm/dd/
;     delimit - optional delimiter <parent>/yyyy<delimit><mm>[<delimit>dd]
;
;   Calling Example:
;      paths=ssw_time2paths('1-jan-1999','31-jan-1999',parent='/top',/daily)
;      paths=ssw_time2paths('1-jan-1999','31-jan-1999','/top',/daily) ; same
;      help,paths & more,[paths(0:3),last_nelem(paths,3)]
;
;   History:
;      22-Aug-2005 - S.L.Freeland - common client/service utility
;       2-nov-2005 - S.L.Freeland - add /QUIET to timegrid call
;      24-apr-2006 - S.L.Freeland - truncate times to /DATE_ONLY to force
;                    pickup of last element 
;       4-dec-2006 - S.L.Freeland - add /FLAT keyword&function (STEREO for ex)
;      27-oct-2009 - S.L.Freeland - handle "incomplete" months
;
;-
count=0
recursing=keyword_set(recursing)

if n_params() lt 2 then begin 
   box_message,'Need start and stop times.., returning'
   return,''
endif
case 1 of 
   keyword_set(parent):
   data_chk(parentx,/string): parent=parentx
   else: parent=curdir()
endcase
y2=keyword_set(year2_digit) ; if yy/ not yyyy/
exist=keyword_set(exist)
monthly=keyword_set(monthly)
weekly=keyword_set(weekly) 
daily=1-(monthly or weekly) ; default=daily
days=daily + keyword_set(weekly)
if monthly then delvarx,days ; assure only one keyword set...
hourly=keyword_set(hourly)

case 1 of 
   hourly: begin 
      pgrid=timegrid(time0,time1,hours=1, out='ecs')
      pgrid=str_replace(pgrid,':','')
      dd=ssw_strsplit(pgrid,' ',/head, tail=hh)
      pgrid=dd+'/'+'H'+strmid(strtrim(hh,2),0,2) + '00' 
   endcase
   else: begin 
      pgrid=timegrid(anytim(time0,/date_only),anytim(time1,/date_only),$
         days=days, /quiet, month=monthly,out='ecs',/date_only)
         if keyword_set(weekly) then pgrid=anytim2weekinfo(pgrid,/first) else $
            pgrid=strmid(temporary(pgrid),0,5-(y2*2)+(5-monthly*3))
      if monthly and not recursing then begin ; handle "incomplete" months 
         pgrid=[pgrid,ssw_time2paths(time1,time1,flat=flat,parent=' ',/monthly,/recursing)]
         pgrid=pgrid(uniq(pgrid))
      endif 
      if keyword_set(delimit) then $
         pgrid=str_replace(pgrid,'/',delimit(0))
   endcase
endcase
pgrid=pgrid(uniq(pgrid))
if keyword_set(flat) then $
   pgrid=strcompress(str_replace(pgrid,'/',' '),/remove) ; flatten
urls=total(strpos(parent,'://') ne -1) gt 0 ; urls?  

case 1 of 
   recursing: retval=pgrid
   urls: retval=parent+'/'+pgrid 
   else: retval=concat_dir(parent,pgrid)
endcase

if keyword_set(file_pat) then retval=file_list(retval,file_pat) else begin 
   if exist then begin
      sse=where(file_exist(retval),count)
      if count gt 0 then retval=retval(sse) else retval=''
   endif
endelse 
retval=retval(uniq(retval)) 
count=total(retval ne '')

return,retval
end

