;+
; Project     : SDO
;
; Name        : HMI__DEFINE
;
; Purpose     : Class definition for SDO/HMI
;
; Category    : Objects
;
; History     : Written 15 June 2010, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function hmi::search,tstart,tend,_ref_extra=extra

return,vso_files(tstart,tend,/hmi,_extra=extra)
end

;------------------------------------------------------
pro hmi__define,void                 

void={hmi, inherits map}

return & end
