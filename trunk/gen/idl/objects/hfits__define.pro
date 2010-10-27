;+
; Project     : HESSI
;
; Name        : HFITS__DEFINE
;
; Purpose     : Define a HFITS class that reads remote FITS files via HTTP
;
; Explanation : 
;               
;               f='~zarro/synop/mdi_mag_fd_20001126_0136.fits ; file to read
;               a=obj_new('hfits')                ; create a FITS HTTP object
;               a->open,'orpheus.nascom.nasa.gov' ; open a URL socket 
;               a->hread,f,header                 ; read header
;               print,header                      ; print header
;               a->readfits,file,data             ; read into data array
;               a->close                          ; close socket
;
;               This works too:
;
; a->read,'orpheus.nascom.nasa.gov/~zarro/synop/mdi_mag_fd_20001126_0136.fits'
;
; Category    : objects sockets fits
;               
; Syntax      : IDL> a=obj_new('hfits')
;
; History     : Written 11 Oct 2001, D. Zarro (EITI/GSFC)
;               Modified 10 Oct 2005, Zarro (L-3Com/GSFC) 
;                 - added _ref_extra
;               Modified 11 Nov 2006, Zarro (ADNET/GSFC)
;                 - fixed bug parsing URL's without http prefix
;               Modified 30 Sept 2009 Zarro (ADNET/GSFC)
;                 - added capability to read multiple extensions
;
; Contact     : dzarro@solar.stanford.edu
;-

;-- init HTTP socket

function hfits::init,_ref_extra=extra

chk=self->fits::init(_extra=extra)
if ~chk then return,chk
dprint,'% HFITS::INIT'

return,self->http::init(_extra=extra)

end

;--------------------------------------------------------------------------

pro hfits::cleanup

self->http::cleanup
self->fits::cleanup

return & end

;---------------------------------------------------------------------------
;--- read FITS header from remote URL

pro hfits::hread,url,header,count=count,_ref_extra=extra

count=0 & header=''
self->readfits_url,url,data,header=header,_extra=extra,/nodata

if is_blank(header) then return
count=n_elements(header)
if (n_params() ne 2) then hprint,header

return & end


;---------------------------------------------------------------------------
;--- read FITS data from remote URL

pro hfits::readfits_url,url,data,header=header,index=index,err=err,$
                    nodata=nodata,_ref_extra=extra
err=''
header=''
delvarx,data

;-- send a GET request

self->open,url,file=file,err=err
if is_string(err) then return
self->make,file,request,_extra=extra
self->send,request,err=err
if is_string(err) then begin
 message,err,/cont & self->close & return
endif

;-- examine the response header

rheader=self->strip_response(_extra=extra)
code=self->get_status(rheader,_extra=extra)
if code ne 200 then begin
 err='File not found.' & message,err,/cont & self->close
 return
endif

nodata=keyword_set(nodata)

if nodata then self->read_header,header,err=err,_extra=extra else $
 self->read_data,data,header=header,err=err,_extra=extra

self->close

if is_string(header) and arg_present(index) then index=fitshead2struct(header)

return & end

;---------------------------------------------------------------------------
;-- read FITS header from server

pro hfits::read_header,header,err=err,_ref_extra=extra,extension=extension

err=''
header=''

status=0 & mstatus=0
if ~is_number(extension) then extension=0
if extension gt 0 then mstatus=fxmove(self.unit,extension)
if mstatus eq 0 then mrd_hread,self.unit,header,status

if is_blank(header) or (status ne 0) then begin
 err='No response from server.'
 message,err,/cont
endif

return & end

;---------------------------------------------------------------------------
;-- read FITS data from server 

pro hfits::read_data,data,header=header,extension=extension,err=err,_ref_extra=extra,$
           verbose=verbose

forward_function mrdfits

err=''
status=0
if ~is_number(extension) then extension=0
verbose=keyword_set(verbose)
if verbose then t1=systime(/seconds)
data=mrdfits(self.unit,extension,header,status=status,_extra=extra,/fscale)
if verbose then t2=systime(/seconds)
if status ne 0 then begin
 err='Error reading file.'
 message,err,/cont
 return
endif

if verbose then begin
 tdiff=anytim2tai(t2)-anytim2tai(t1)
 message,'Data read in '+trim(tdiff)+' seconds',/cont
endif
return & end

;--------------------------------------------------------------------------
;-- FITS reader

pro hfits::readfits,file,data,_ref_extra=extra,err=err

err=''

if is_blank(file) then begin
 err='Blank URL filename entered.'
 message,err,/cont
 return
endif

if n_elements(file) ne 1 then begin
 err='Cannot remotely read multiple files.'
 message,err,/cont
 return
endif

if stregex(file,'ftp://',/bool) then begin
 err='Cannot socket read from FTP server.'
 message,err,/cont
 return
endif

if is_compressed(file) then begin
 err='Cannot socket read compressed file.'
 message,err,/cont
 return
endif

nodata=n_params() eq 1
self->url_parse,file,server,hfile
url_entered=is_string(server) and is_string(hfile)
if url_entered then begin
 self->readfits_url,file,data,_extra=extra,err=err,nodata=nodata
endif else begin
 self->fits::readfits,file,data,_extra=extra,err=err,nodata=nodata
endelse

return & end

;---------------------------------------------------------------------
;-- return HTTP server & path

function hfits::get_server,server,path=path,network=network,_extra=extra

server='' & path='' & network=0b
message,'GET_SERVER method not included',/cont

return,'' & end

;----------------------------------------------------------------------------
;-- HTTP search of remote archive 

pro hfits::find,files,tstart,tend,sizes=sizes,pattern=pattern,$
              count=count,_extra=extra,back=back,err=err,url_path=url_path,$
              verbose=verbose,times=times,round_day=round_day

files='' & count=0 & sizes='' & times=-1 & err=''

verbose=keyword_set(verbose)

if valid_time(tstart) then dstart=anytim2utc(tstart) else begin
 get_utc,dstart
 dstart.time=0
endelse

if valid_time(tend) then dend=anytim2utc(tend) else begin
 dend=dstart
 dend.mjd=dend.mjd+1
endelse

;-- allow backward time search

if is_number(back) then begin
 if back gt 0 then begin
  dend=dstart
  dstart.mjd=dstart.mjd-back
 endif
endif

;-- round out search to include whole day

if keyword_set(round_day) then begin
 dstart.time=0
 dend.time=0
 dend.mjd=dend.mjd+1
 if dend.mjd le dstart.mjd then dend.mjd=dstart.mjd+1
endif
 
;-- determine server and search directories

server=self->get_server(path=path,network=network,err=err,/verb)
if ~network then return

if verbose then begin
 message,'Searching '+anytim2utc(dstart,/vms)+' to '+anytim2utc(dend,/vms),/cont
endif

direc=get_fid(dstart,dend,/full,delim='/',_extra=extra)

np=n_elements(direc)
if np gt 1 then begin
 if valid_time(dend) then begin
  if dend.time eq 0 then direc=direc[0:np-2] 
 endif else direc=direc[0:np-2]
endif
np=n_elements(direc)
if np eq 1 then direc=direc[0]

url_path=server+path+'/'+direc+'/'
self->extract_href,url_path,files,sizes=sizes,times=times,_extra=extra,count=count

;-- filter out pattern

self->filter_pattern,files,pattern,sizes=sizes,times=times,count=count

;-- filter out time

self->filter_times,files,dstart,dend,sizes=sizes,times=times,count=count

if count eq 0 then message,'No files found for specified time(s)',/cont else begin
 if keyword_set(verbose) then message,'Found '+trim(count)+' files',/cont
endelse

return & end

;------------------------------------------------------------------------------
;-- filter on file time

pro hfits::filter_times,files,tstart,tend,times=times,sizes=sizes,count=count

count=n_elements(files)
if (size(files,/tname) ne 'STRING') or (count eq 0) then return

have_times=exist(times)
if have_times then have_times=valid_time(times[0]) and (n_elements(times) eq count)
if ~have_times then times=parse_time(files,/tai)

vt1=valid_time(tstart)
vt2=valid_time(tend)
if ~vt1 and ~vt2 then return

if vt1 then dprint,'% DSTART ',anytim2utc(tstart,/vms)
if vt2 then dprint,'% DEND ',anytim2utc(tend,/vms)

;-- find in time range

if vt1 and vt2 then begin
 ok=where( (times ge anytim2tai(tstart)) and (times le anytim2tai(tend)),count)
 if count gt 0 then begin
  if count eq 1 then ok=ok[0]
  files=temporary(files[ok])
  if exist(sizes) then sizes=temporary(sizes[ok])
  times=temporary(times[ok])
 endif else delvarx,files,sizes,times
 return
endif

;-- find nearest to input time

if vt1 then tref=tstart else tref=tend
diff=abs(times-anytim2tai(tref)) 
chk=where(diff eq min(diff),count)
chk=chk[0]
times=times[chk]
files=files[chk]
if exist(sizes) then sizes=sizes[chk]

return & end

;-----------------------------------------------------------------------------
;-- filter on file pattern

pro hfits::filter_pattern,files,pattern,times=times,sizes=sizes,count=count

count=n_elements(files)
if is_blank(pattern) or (size(files,/tname) ne 'STRING') or (count eq 0) then return
chk=stregex(files,pattern,/bool,/fold)
ok=where(chk,count)
if count gt 0 then begin
 if count eq 1 then ok=ok[0]
 files=temporary(files[ok])
 if exist(sizes) then sizes=temporary(sizes[ok])
 if exist(times) then times=temporary(times[ok])
endif else delvarx,files,sizes,times

return & end

;----------------------------------------------------------------------------

pro hfits__define                 

struct={hfits, inherits http, inherits fits}

return & end

