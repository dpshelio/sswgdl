;+
; Project     : SOHO-CDS
;
; Name        : COREG_MAP
;
; Purpose     : coregister input maps to a reference map
;
; Category    : imaging
;
; Syntax      : omap=coreg_map(imap,rmap)
;
; Inputs      : IMAP = input map(s) to coregister
;               RMAP = reference map against which to coregister
;
; Outputs     : OMAP = output map(s) coregistered to same 
;                      pixel dimension, spacing, & roll
;
; Keywords    : DROTATE = correct for differential solar rotation
;                         if IMAP and RMAP times are different
;
; History     : Written 20 Aug 2001, Zarro (EITI/GSFC)
;               17 September 2008, Zarro (ADNET)
;                - added _EXTRA
;
; Contact     : dzarro@solar.stanford.edu
;-

function coreg_map,imap,rmap,drotate=drotate,_ref_extra=extra

if ~valid_map(imap) or ~valid_map(rmap) then begin
 pr_syntax,'omap=coreg_map(imap,rmap,[drotate=drotate])'
 return,-1
endif

if n_elements(rmap) ne 1 then begin
 message,'reference map must be scalar',/cont
 return,-1
endif

return,drot_map(imap,ref_map=rmap,/keep_limb,no_drotate=~keyword_set(drotate),_extra=extra)

end
