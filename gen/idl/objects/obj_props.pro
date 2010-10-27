;+
; Project     : HESSI
;
; Name        : OBJ_PROPS
;
; Purpose     : find property names in an object
;
; Category    : utility objects
;
; Syntax      : IDL>out=obj_props(class)
;
; Inputs      : CLASS = class name or object variable name 
;
; Outputs     : OUT = string array of property names
;
; Keywords    : ERR = error string
;
; History     : Written 20 May 1999, D. Zarro, SM&A/GSFC
;
; Contact     : dzarro@solar.stanford.edu
;-

function obj_props,obj,err=err,_extra=extra

obj_dissect,obj,props=props,err=err,_extra=extra
if err eq '' then return,props else return,''

end
