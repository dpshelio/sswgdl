;+
; Project     : HESSI
;
; Name        : CALLISTO__DEFINE
;
; Purpose     : Define a site object for Callisto radio observations
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('callisto')
;
; History     : Written 4 Jan 2010, Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-
;-----------------------------------------------------------------------------
;-- init 

function callisto::init,_ref_extra=extra

if ~self->ethz::init(_extra=extra) then return,0

self.site->setprop,rhost='ftp://www.astro.phys.ethz.ch',ext='fit',org='day',$
                 topdir='/pub/hedc/fs/data8/rag/callisto/observations',/full,$
                 delim='/',ftype='BLEN'

return,1
end

;------------------------------------------------------------------------------
pro callisto__define                 

self={callisto,inherits ethz}

return & end

