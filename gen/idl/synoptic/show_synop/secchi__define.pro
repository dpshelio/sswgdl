;+
; Project     : STEREO
;
; Name        : SECCHI__DEFINE
;
; Purpose     : Define a SECCHI data/map object
;
; Category    : Objects
;
; Syntax      : IDL> a=obj_new('secchi')
;
; Examples    : IDL> a->read,'20070501_000400_n4euA.fts' ;-- read FITS file
;               IDL> a->plot                             ;-- plot image
;               IDL> map=a->getmap()                     ;-- access map
;               IDL> data=a->getdata()                   ;-- access data
;                       
;               Searching via VSO:                                     
;               IDL> files=a->search('1-may-07','02:00 1-may-07')
;               IDL> print,files[0]
;               http://stereo-ssc.nascom.nasa.gov/data/ins_data/secchi/L0/a/img/euvi/20070501/20070501_000400_n4euA.fts
;               IDL> a->read,files[0],/verbose
;
; History     : Written 13 May 2007, D. Zarro (ADNET)
;               Modified 31-Oct-2007 William Thompson (ADNET)
;                - modified for COR1/COR2
;               Modified 26 March 2009 - Zarro (ADNET)
;                - renamed index2map method to mk_map
;               13-Oct-2009, Zarro (ADNET)
;                - renamed mk_map to mk_secchi_map
;               25-May-2010, Zarro (ADNET)
;                - fixed bug causing roll_center to be offset relative
;                  to Sun center.
;               1-July-2010, Zarro (ADNET)
;                - fixed another bug with the roll_center offset. It
;                  never ends.
;
; Contact     : dzarro@solar.stanford.edu
;-

function secchi::init,_ref_extra=extra

if ~self->fits::init(_extra=extra) then return,0

;-- setup environment

self->setenv,_extra=extra

return,1 & end

;------------------------------------------------------------------------
;-- setup SECCHI environment variables

pro secchi::setenv,_extra=extra

if is_string(chklog('SECCHI_CAL')) then return
file_env=local_name('$SSW/stereo/secchi/setup/setup.secchi_env')
file_setenv,file_env,_extra=extra
return & end

;-----------------------------------------------------------------------------
;-- check for SECCHI branch in !path

function secchi::have_path,err=err,verbose=verbose

common have_path,registered

err=''
if ~have_proc('sccreadfits') then begin
 epath=local_name('$SSW/stereo/secchi/idl')
 if is_dir(epath) then ssw_path,/secchi,/quiet
 if ~have_proc('sccreadfits') then begin
  err='STEREO/SECCHI branch of SSW not installed.'
  if keyword_set(verbose) then message,err,/cont
  return,0b
 endif
endif

;-- register DLM to read SPICE files

if ~exist(registered) then begin
 if have_proc('register_stereo_spice_dlm') then begin
  register_stereo_spice_dlm
  registered=1b
 endif
endif

return,1b

end

;---------------------------------------------------------------------

function secchi::have_cal,err=err,verbose=verbose

;-- ensure that calibration directories are properly defined

err=''
if ~is_dir('$SSW_SECCHI/calibration') then begin
 err='$SSW_SECCHI/calibration directory not found.'
 if keyword_set(verbose) then message,err,/cont
 return,0b
endif

SSW_SECCHI=local_name('$SSW/stereo/secchi')
mklog,'SSW_SECCHI',SSW_SECCHI
SECCHI_CAL=local_name('$SSW_SECCHI/calibration')
mklog,'SECCHI_CAL',SECCHI_CAL

return,1b & end

;--------------------------------------------------------------------------
;-- FITS reader

pro secchi::read,file,data,_ref_extra=extra,err=err

forward_function discri_pobj
err=''

;-- download files if not present

self->getfile,file,local_file=cfile,err=err,_extra=extra
if is_blank(cfile) or is_string(err) then return

self->empty
have_cal=self->have_cal(err=err1)
have_path=self->have_path(err=err2)

j=0
nfiles=n_elements(cfile) 
for i=0,nfiles-1 do begin
 valid=self->is_valid(cfile[i],level=level,_extra=extra)

 if ~valid then continue

 if have_cal and have_path and (level eq 0) then begin
  secchi_prep,cfile[i],index,data,_extra=extra
 endif else begin
  if (level eq 0) then begin
   if ~have_cal then xack,err1,/suppress
   if ~have_path then xack,err2,/suppress
   message,'Skipping prepping.',/cont
  endif
  self->readfits,cfile[i],data,_extra=extra,index=index
 endelse

 ;-- insert data into maps
 
 index=rep_tag_value(index,file_basename(cfile[i]),'filename')
 self->mk_secchi_map,j,index,data,err=err,_extra=extra

 if is_string(err) then begin
  message,err,/cont
  continue
 endif
 j=j+1
endfor

count=self->get(/count)
if count gt 0 then begin
 for i=0,count-1 do begin
  id=self->get(/id)
  if stregex(id,'EUVI',/bool) then self->set,i,/log_scale,grid=30,/limb
  self->colors,i
 endfor
endif else message,'No maps created.' ,/cont

return & end

;---------------------------------------------------------------------
;-- store INDEX and DATA into MAP objects

pro secchi::mk_secchi_map,i,index,data,err=err,_extra=extra,$
           roll_correct=roll_correct,earth_view=earth_view

err=''
if ~is_number(i) then i=0

;-- check inputs

if ~is_struct(index) or (n_elements(index) ne 1) then begin
 err='Input index is not a valid structure.'
 return
endif

ndim=size(data,/n_dim)
if (ndim ne 2) then begin
 err='Input image is not a 2-D array.'
 return
endif

;-- add STEREO-specific properties

id=index.OBSRVTRY+' '+index.INSTRUME+' '+index.DETECTOR+' '+trim(index.WAVELNTH)
nx=index.naxis1 & ny=index.naxis2
dx=index.cdelt1 & dy=index.cdelt2
dur=index.exptime
time=anytim2utc(index.date_obs,/vms)
xc=comp_fits_cen(index.crpix1,dx,nx,index.crval1)
yc=comp_fits_cen(index.crpix2,dy,ny,index.crval2)
xc_roll=0. & yc_roll=0.
if have_tag(index,'crotacn1') then xc_roll=index.crotacn1
if have_tag(index,'crotacn2') then yc_roll=index.crotacn2
map=make_map(data,time=time,dx=dx,dy=dy,id=id,/no_copy,$
      roll_angle=index.crota,roll_center=[xc_roll,yc_roll],xc=xc,yc=yc,dur=dur,$
       l0=index.hgln_obs,b0=index.hglt_obs,rsun=index.rsun,$
       err=err)

if is_string(err) then return

earth_view=keyword_set(earth_view)
roll_correct=keyword_set(roll_correct)
if earth_view then self->earth_view,index,map else $
 if roll_correct then self->roll_correct,index,map

self->set,i,map=map,/no_copy
self->set,i,index=index

return & end

;-----------------------------------------------------------------------
pro secchi::roll_correct,index,map

if ~valid_map(map) or ~is_struct(index) then return
if (nint(index.crota) mod 360.) eq 0 then begin
 message,'Map already roll-corrected.',/cont
 return
endif

;-- roll correct

message,'Correcting for spacecraft roll...',/cont

map=rot_map(map,roll=0.)
index.crota=0.
self->update_pc,index,map

return & end

;-------------------------------------------------------------------------
pro secchi::earth_view,index,map

if ~valid_map(map) or ~is_struct(index) then return

message,'Correcting to Earth-view...',/cont
map=map2earth(map,/remap,_extra=extra)
index.hglt_obs=map.b0
index.hgln_obs=map.l0
index.rsun=map.rsun
index.crota=0.
self->update_pc,index,map

return & end

;--------------------------------------------------------------------------
pro secchi::update_pc,index,map

index.pc1_1=1 & index.pc1_2=0 & index.pc2_1=0 & index.pc2_2=1
nx=index.naxis1 & ny=index.naxis2
index.crpix1=comp_fits_crpix(map.xc,map.dx,nx,index.crval1)                                            
index.crpix2=comp_fits_crpix(map.yc,map.dy,ny,index.crval2)

return & end

;--------------------------------------------------------------------------
;-- VSO search function

function secchi::search,tstart,tend,_ref_extra=extra,$
                 euvi=euvi,cor1=cor1,cor2=cor2,det=det,type=type

case 1 of
 keyword_set(euvi): det='euvi'
 keyword_set(cor1): det='cor1'
 keyword_set(cor2): det='cor2'
 else: do_nothing=''
endcase

f=vso_files(tstart,tend,inst='secchi',_extra=extra,det=det,wmin=wmin,window=3600.)
if arg_present(type) and exist(wmin) then type=strmid(wmin,0,3)+' A'
return,f

end

;------------------------------------------------------------------------------
;-- save SECCHI color table

pro secchi::colors,k

if ~have_proc('secchi_colors') then return
index=self->get(k,/index)
dsave=!d.name
set_plot,'z'
tvlct,r0,g0,b0,/get
secchi_colors,index.detector,index.wavelnth,red,green,blue
tvlct,r0,g0,b0
set_plot,dsave
self->set,k,red=red,green=green,blue=blue,/has_colors

return & end

;------------------------------------------------------------------------------
;-- check if valid SECCHI file

function secchi::is_valid,file,err=err,detector=detector,verbose=verbose,$
                  level=level,_extra=extra,euvi=euvi,cor1=cor1,cor2=cor2

level=0
detector='' & instrument=''
mrd_head,file,header,err=err
if is_string(err) then return,0b

s=fitshead2struct(header)
if have_tag(s,'dete',/start,index) then detector=strup(s.(index))
if have_tag(s,'inst',/start,index) then instrument=strup(s.(index))

if have_tag(s,'history') then begin
 chk=where(stregex(s.history,'Applied Flat Field',/bool),count)
 level=count gt 0
endif

verbose=keyword_set(verbose)

if keyword_set(euvi) and detector ne 'EUVI' then begin
 if verbose then message,'Input file is not EUVI',/cont & return,0b
endif

if keyword_set(cor1) and detector ne 'COR1' then begin
 if verbose then message,'Input file is not COR1',/cont & return,0b
endif

if keyword_set(cor2) and detector ne 'COR2' then begin
 if verbose then message,'Input file not COR2',/cont & return,0b
endif

return,instrument eq 'SECCHI'
end

;------------------------------------------------------------------------
;-- SECCHI data structure

pro secchi__define,void                 

void={secchi, inherits fits, inherits prep}

return & end
