;+
; Project     : STEREO
;
; Name        : EUVI__DEFINE
;
; Purpose     : stub that inherits from SECCHI class
;
; Category    : Objects
;
; History     : Written 7 April 2009, D. Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro euvi::read,file,_ref_extra=extra

self->secchi::read,file,_extra=extra,/euvi

return & end

;-----------------------------------------------------------

function euvi::search,tstart,tend,_ref_extra=extra

return,self->secchi::search(tstart,tend,/euvi,_extra=extra)

end

;----------------------------------------------------
pro euvi__define,void                 

void={euvi, inherits secchi}

return & end
