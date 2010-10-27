;+
; Project     : RHESSI
;
; Name        : FERMI_GBM__DEFINE
;
; Purpose     : Define a FERMI GBM data object.  
;
; Category    : Synoptic Objects
;
; Syntax      : IDL> c=obj_new('fermi_gbm')
;
; History     : Written 12-Feb-2010, Kim Tolbert, modified from soxs__define
;
; Contact     : dzarro@standford.edu
;-
;----------------------------------------------------------------
;
function fermi_gbm::init,_ref_extra=extra

if ~self->synop_spex::init() then return,0
rhost='fermi.gsfc.nasa.gov'
self->setprop,rhost=rhost,ext='pha|fit',org='day',/round,$
                 topdir='/FTP/fermi/data/gbm/daily',/full, delim='/', suffix='current'
return,1

end
;-----------------------------------------------------------------

;-- search method 

function fermi_gbm::search,tstart,tend,count=count,type=type,_ref_extra=extra

type=''
files=self->site::search(tstart,tend,_extra=extra,count=count)
if count gt 0 then type=replicate('hxr/lightcurves',count) else files=''
if count eq 0 then message,'No files found.',/cont

return,files
end

;----------------------------------------------------------------

pro fermi_gbm__define                 
void={fermi_gbm, inherits synop_spex}
return & end

