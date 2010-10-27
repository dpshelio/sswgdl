;+
; Project     : VSO
;
; Name        : SYNOP_INST__DEFINE
;
; Purpose     : Wrapper object to hold instrument-specific data
;               for SHOW_SYNOP object
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('synop_db')
;
; History     : Written 1-Jan-09 2009, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

;-----------------------------------------------------------------------------

function synop_inst::list_sites,abbr

names=[ 'Big Bear Solar Observatory (BBSO) | bbso',$
        'Callisto Radio Observations | callisto',$
        'FERMI GBM | fermi_gbm', $
        'Hinode/EIS | eis',$
        'Hinode/XRT | xrt2',$
        'Kanzelhohe Solar Observatory | kanz',$
        'Meudon Observatory | meudon',$
        'Nancay Radio Observatory | nancay',$
        'Nobeyama Radioheliograph | nobeyama',$
        'Phoenix ETH Zurich | ethz',$
        'SDO/EVE | eve',$
        'SOHO/EIT (level 0) | eit',$
        'SOHO/EIT (prepped) | eit2',$
        'SOHO/MDI (Continuum) | mdi_c',$
        'SOHO/MDI (Magnetogram) | mdi',$
        'Solar X-ray Spectrometer (SOXS) | soxs',$
        'STEREO/SECCHI-COR1 | cor1',$
        'STEREO/SECCHI-COR2 | cor2',$
        'STEREO/SECCHI-EUVI | euvi',$
        'TRACE (level 0) | trace',$
        'TRACE (prepped) | trace2']

c=stregex(names,'(.+)\|(.+)',/ext,/sub)
sites=trim(reform(c[1,*]))
abbr=trim(reform(c[2,*]))

return,sites
end

;-------------------------------------------------------------------------------
function synop_inst::get_class,file,verbose=verbose

if is_blank(file) then return,'fits'

acro=['^(EVL|EVS)','\.les','^glg','^(prepped_)?eis','^mdi','^cont','^fdmg','^(prepped_)?xrt','^kanz','^eit','^(prepped_)?efr',$
      '^(prepped_)?efz','^trac','^(prepped_)?tri',$
      '^mg1','^bbso','^kpno','^rstn','^phnx','^hxr','^(prepped_)?[^ ]+(euA\.|euB\.)',$
      '^ovsa','^osra','\.xrs|\.hsi)','^(ifa|ifb|ifz|ifs)','^(na|nb)','^mh','^BLEN']

class=['eve','soxs','fermi_gbm','eis','mdi','mdi','mdi','xrt2','kanz','eit','eit','eit',$
       'trace','trace',$
       'spirit','bbso','kpno','rstn','ethz','hxrs','euvi',$
       'ovsa_ltc','osra','synop_spex','nobeyama','nancay','meudon','callisto']

fclass=''
bfile=file_break(file)
for i=0,n_elements(acro)-1 do begin
 if stregex(bfile,acro[i],/bool,/fold) then begin
  fclass=class[i]
  message,'guessing '+strupcase(fclass),/cont
  break
endif
endfor

;-- check if class is defined

if is_blank(fclass) then fclass=fits_class(file)
if is_blank(fclass) then fclass='fits'

return,fclass
end

;-------------------------------------------------------------------------
;-- check if file is candidate for prepping

function synop_inst::do_prep,file,read_again=read_again

read_again=0b
if is_blank(file) then return,0b
bfile=file_basename(file)
if stregex(bfile,'^prepped',/fold,/bool) then return,0b
chk=stregex(bfile,'(^eis|^efz|^efr|^tri|^xrt|eua\.|eub\.)',/bool,/fold)
read_again=stregex(bfile,'^tri',/bool,/fold)
return,chk
end

;------------------------------------------------------------------------------

pro synop_inst__define,void                 

void={synop_inst,null_synop_inst:''}

return & end
