;+
; Project     : SDO
;
; Name        : AIA__DEFINE
;
; Purpose     : Class definition for SDO/AIA
;
; Category    : Objects
;
; History     : Written 15 June 2010, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

function aia::search,tstart,tend,_ref_extra=extra

return,vso_files(tstart,tend,/aia,_extra=extra)
end

;------------------------------------------------------
pro aia__define,void                 

void={aia, inherits map}

return & end
