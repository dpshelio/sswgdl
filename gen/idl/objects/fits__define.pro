;+
; Project     : HESSI
;
; Name        : FITS__DEFINE
;
; Purpose     : Define a FITS map object
;
; Category    : imaging maps objects
;               
; Syntax      : This procedure is invoked when a new FITS object is
;               created via:
;
;               IDL> new=obj_new('fits')
;
; History     : Written 19 May 1998, D. Zarro, SM&A/GSFC
;               10 Oct 2009, Zarro (ADNET) 
;                - added capability to read multiple FITS file
;                  extensions
;                - retired mreadfits method 
;               29 Nov 2009, Zarro (ADNET)
;                - added more stringent check for missing input file
;                - rename ::GET method to ::GETFILE
;               12 Sept 2010, Zarro (ADNET)
;                - added called to valid_fits to check
;                  that a valid FITS files is entered
;
; Contact     : dzarro@solar.stanford.edu
;-

;---------------------------------------------------------------------------
;-- FITS reader

pro fits::read,file,data,index=index,err=err,_ref_extra=extra,$
               extension=extension,nodata=nodata,$
               record=record
err=''

nfiles=n_elements(file)
if is_blank(file) or (nfiles eq 0) then begin
 err='Missing input FITS filename.'
 message,err,/cont
 return
endif
file=strtrim(file,2)

;-- avoid making duplicate copies of data if it is not an argument

no_copy=n_params() eq 1
nodata=keyword_set(nodata)
if ~is_number(record) then record=-1

;-- if extension not specified, read all

do_all=1b
if exist(extension) then begin
 if is_number(extension[0]) then begin
  chk=where(extension ge 0,count)
  if count gt 0 then extension=extension[chk] else extension=0
  extension=get_uniq(extension)
  n_ext=n_elements(extension)
  do_all=0b
 endif
endif

;-- empty linkedlist

self->empty
k=-1
for i=0,nfiles-1 do begin
 terr='' & k=-1 & m=-1

 if ~valid_fits(file[i],err=terr) then begin
  message,terr,/cont
  continue
 endif

 if do_all then begin
  n_ext=get_fits_extn(file[i])
  if n_ext eq 0 then begin
   message,'Skipping '+file[i],/cont
   continue
  endif else extension=indgen(n_ext)
  if n_ext gt 1 then message,'Reading '+trim(n_ext)+' extensions.',/cont
 endif

 repeat begin
  k=k+1 
  rext=extension[k]
  self->readfits,file[i],data,index=index,_extra=extra,err=terr,$
                          extension=rext,nodata=nodata
  ndim=size(data,/n_dim)
  if ~nodata and (is_string(terr) or (ndim le 1) or (ndim gt 3)) then begin
   if is_blank(terr) then terr='FITS data not simple image.'
   message,terr,/cont
   continue
  endif
  tindex=merge_struct(tindex,index)
  if nodata then continue
  nindex=n_elements(index) & flag=0b
  for j=0,nindex-1 do begin
   m=m+1
   if nindex gt 1 then begin
    if (record lt nindex) and (record gt -1) then begin
     j=record & flag=1b
    endif
    self->mk_map,index[j],data[*,*,j],m,no_copy=no_copy,err=merr,$
               filename=file[i],_extra=extra,/angles
    if flag then break
   endif else begin
    self->mk_map,index[j],data,m,no_copy=no_copy,err=merr,$
               filename=file[i],_extra=extra,/angles
   endelse
  endfor
 endrep until ((k+1) ge n_ext)
endfor
err=terr

if is_struct(tindex) then index=temporary(tindex)

return & end

;--------------------------------------------------------------------------
;-- wrapper around MRDFITS that makes HEADER and EXTENSION into keywords

pro fits::mrdfits,file,data,header=header,extension=extension,$
                    verbose=verbose,_ref_extra=extra

forward_function mrdfits
if ~exist(extension) then extension=0
if keyword_set(verbose) then begin
 message,'Reading file - '+file,/cont
 message,'Reading extensions - '+trim(arr2str(extension)),/cont
endif
data=mrdfits(file,extension,header,_extra=extra,/fscale)

return & end

;-------------------------------------------------------------------------
;-- READFITS method

pro fits::readfits,file,data,header=header,index=index,_ref_extra=extra,err=err,$
                      status=status,nodata=nodata

err=''
status=-1
delvarx,index,data

;-- manually decompress if MRDFITS can't do it

compressed=is_compressed(file,type)
have_mrdfits=have_proc('mrdfits')
dfile=strtrim(file[0],2)

uncompress=~have_mrdfits or $
           (type eq 'Z') or $
           ~since_version('5.3') or $
           (type eq 'zip')

if compressed and uncompress then begin
 dfile=find_uncompressed(file,err=err)
 if err ne '' then begin
  message,err,/cont
  return
 endif
endif

;-- just read header

if keyword_set(nodata) then begin
 mrd_head,dfile,header,status=status,/no_check_compress
 if status eq 0 then index=fitshead2struct(header)
 return
endif

;-- call MRDFITS

if have_mrdfits then begin
 self->mrdfits,dfile,data,header=header,status=status,_extra=extra
 if status eq 0 then begin
;  if is_struct(data) then data=data.(0)
  index=fitshead2struct(header)
  sz=size(data)
  if sz[0] eq 3 then index=replicate(index,sz[3])
 endif else begin
  err='Error reading file.'
  message,err,/cont
 endelse
 return
endif else mreadfits,dfile,index,data,header=header,_extra=extra

return & end

;------------------------------------------------------------------------
;-- download remote URL files to local directory

pro fits::getfile,file,out_dir=out_dir,_ref_extra=extra,err=err,local_file=local_file

local_file=''
if is_blank(file) then begin
 err='No file name entered.'
 message,err,/cont
 return
endif

file=strtrim(file,2)
nf=n_elements(file)
local_file=strarr(nf)
url=stregex(file,'(http[s]?|ftp):\/\/',/fold,/bool)

;-- create temp directory for download

if url[0] then begin
 if is_blank(out_dir) then out_dir=curdir()
 if ~write_dir(out_dir,/quiet) then begin
  out_dir=concat_dir(get_temp_dir(),'fits')
  mk_dir,out_dir
 endif
endif

for i=0,nf-1 do begin
 if is_url(file[i]) then begin
  sock_copy,file[i],out_dir=out_dir,_extra=extra,local_file=copy_file
  local_file[i]=copy_file
 endif else begin
  if file_test(file[i]) then local_file[i]=file[i]
 endelse
endfor

chk=where(local_file ne '',count)
if count eq 0 then begin
 err='File not found.'
 message,err,/cont
endif else local_file=local_file[chk]

return & end

;--------------------------------------------------------------------------                  
;-- define FITS object

pro fits__define                 

fits_struct={fits, inherits map}

return & end
