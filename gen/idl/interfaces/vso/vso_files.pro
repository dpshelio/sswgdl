;+
; Project     : VSO
;
; Name        : VSO_FILES
;
; Purpose     : Wrapper around VSO_SEARCH that returns URL file names
;
; Category    : utility system sockets
;
; Example     : IDL> urls=vso_files('1-may-07','2-May-07',inst='trace')
;
; Inputs      : TSTART, TEND = start, end times to search
;
; Outputs     : URLS = url's of search results
;
; Keywords    : TIMES = times (TAI) of returned files
;               SIZES = sizes (bytes) of returned files
;               COUNT = # of returned files
;               WMIN  = minimum wavelength (if available)
;
; History     : Written 3-Jan-2008, D.M. Zarro (ADNET/GSFC)
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function vso_files,tstart,tend,times=times,sizes=sizes,count=count,$
                    _ref_extra=extra,window=window,wmin=wmin,fids=fids

urls='' & count=0 & nearest=0b & fileid=''

if is_blank(extra) then begin
 pr_syntax,'files=vso_files(tstart [,tend],inst=inst)'
 return,''
endif

if valid_time(tstart) and ~valid_time(tend) then begin
 if is_number(window) then win=window/2. else win=12*3600.
 dstart=anytim2tai(tstart)-win
 dend=dstart+2*win
 dstart=anytim2utc(dstart,/vms)
 dend=anytim2utc(dend,/vms)
 nearest=1b
endif else dstart=get_def_times(tstart,tend,dend=dend,_extra=extra,/vms)

;-- search VSO

records=vso_search(dstart,dend,_extra=extra,/url,protocol='1.0')

if ~have_tag(records,'url') then begin
 times=-1.0d & sizes='' &  return,''
endif

;-- sort results and find records nearest start time

fids=records.fileid
fids=get_uniq(fids,sorder)
records=records[sorder]
urls=records.url

have_sizes=have_tag(records,'size')
have_wave=have_tag(records,'wave')


if nearest then begin
 count=1
 times=anytim2tai(records.time.start)
 diff=abs(times-anytim2tai(tstart))
 ok=where(diff eq min(diff))
 urls=records[ok].url
 if have_sizes then sizes=trim(records[ok].size)
 if have_wave then wmin=trim(records[ok].wave.min)
 if n_elements(wmin) eq 1 then wmin=wmin[0]
 return,urls 
endif

;-- find records within start/end times

count=n_elements(urls)

if arg_present(sizes) and have_sizes then begin
 sizes=strtrim(records.size,2)
 chk=where(long(sizes) eq 0l,dcount)
 if dcount gt 0 then sizes[chk]=''
endif

if arg_present(wmin) and have_wave then wmin=strtrim(records.wave.min,2)
if arg_present(times) then times=anytim2tai(records.time.start)
if n_elements(wmin) eq 1 then wmin=wmin[0]

return,urls

end
