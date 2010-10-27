;+
; Project     : HESSI
;
; Name        : FIFO__DEFINE
;
; Purpose     : Define a FIFO object
;
; Category    : Objects
;
; Explanation : A first in first out FIFO object to store anything
;
; Syntax      : IDL> new=obj_new('fifo')
;              
; Inputs    :   INIT_SIZE = initial size of cache buffer [def=10]. 
;
; Methods     : ->SET,ID,VALUE                    ; store value
;               VALUE = any data type
;               ID = unique string identifier for INPUT
;
;               ->GET,ID,VALUE                   ; retrieve value   
;               (N.B. if ID is a number (e.g. N) it is treated as an
;               index and the value at position N is returned
;             
;               ->EMPTY   ;-- empty fifo
;               ->SHOW    ;-- show fifo contents
;
; Keywords    : STATUS = 1 or 0 is success or failure
;
; History     : 6-DEC-1999,  D.M. Zarro.  Written
;               1-November-2009, Zarro (ADNET) - added boost memory method
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

;---------------------------------------------------------------------------
;-- constructor

function fifo::init,init_size,_extra=extra

self.add_size=10
self.init_size=10
if is_number(init_size) then self.init_size=init_size
self->create

return,1
end

;----------------------------------------------------------------------------

function fifo::get_count

if ~ptr_exist(self.pointer) then return,0
pointer=self.pointer
ids=(*pointer).ids
chk=where(ids ne '',count)
return,count

end

;----------------------------------------------------------------------------

pro fifo::create

if ptr_exist(self.pointer) then begin
 message,'Already created',/cont
 return
endif

init_size=self.init_size
self.pointer=ptr_new(/all)
struct={ids:strarr(init_size),ptrs:ptrarr(init_size,/all)}
*self.pointer=struct

return & end

;-------------------------------------------------------------------------
;-- boost cache memory size

pro fifo::boost

if ~ptr_exist(self.pointer) then return
struct=*self.pointer
add_size=self.add_size
new_struct={ids:[struct.ids,strarr(add_size)],$
            ptrs:[struct.ptrs,ptrarr(add_size,/all)]}
*self.pointer=new_struct
return & end

;---------------------------------------------------------------------------
;-- destructor

pro fifo::cleanup

dprint,'% FIFO::CLEANUP'

heap_free,self.pointer

return & end

;----------------------------------------------------------------------------
;-- empty FIFO by freeing data from pointers

pro fifo::empty

heap_free,self.pointer
self->create

return & end
                        
;---------------------------------------------------------------------------

pro fifo::show

pointer=self.pointer
if ~ptr_exist(pointer) then begin
 message,'Empty buffer',/cont
 return
endif

struct=*pointer
iprint,struct.ids
print,'--------------------'
iprint,struct.ptrs
               
return & end

;---------------------------------------------------------------------------

pro fifo::set,id,value,status=status,no_copy=no_copy,verbose=verbose

status=0b
if ~exist(id) or ~exist(value) then return
if trim(id) eq '' then return
verbose=keyword_set(verbose)
dprint,'% FIFO saving in cache - '+trim(id)
if ~ptr_exist(self.pointer) then self->create
pointer=self.pointer
struct=*pointer
ids=struct.ids
chk=where(trim(id) eq ids,icount)
ipos=chk[0]
replacing=icount gt 0
if replacing and verbose then message,'Overwriting - '+trim(id),/cont

;-- free underlying memory if replacing, or increase memory if hitting ceiling
;-- just return if replacing identical objects 

if replacing then begin
 ptr=struct.ptrs[ipos]
 if is_object(value) and is_object(*ptr) then begin
  if value eq *ptr then return
 endif
 if ptr_exist(ptr) then heap_free,*ptr
endif else begin
 chk=where(ids eq '' ,bcount)
 if bcount eq 0 then begin
  if verbose then message,'Increasing memory size',/cont
  self->boost
  pointer=self.pointer
  struct=*pointer
  ids=struct.ids
  chk=where(ids eq '' ,bcount)
 endif
 ipos=chk[0]
 ptr=struct.ptrs[ipos]
endelse

struct.ids[ipos]=trim(id)
if keyword_set(no_copy) and ~is_object(value) then $
 *ptr=temporary(value) else *ptr=value
struct.ptrs[ipos]=ptr
*pointer=struct

status=1b
return & end

;-------------------------------------------------------------------------

pro fifo::delete,id,_ref_extra=extra

if ~exist(id) then return
if ~ptr_exist(self.pointer) then return
struct=*self.pointer

np=n_elements(id)
for i=0,np-1 do begin
 pos=self->get_pos(trim(id[i]),_extra=extra)
 if pos ge 0 then begin
  dprint,'% FIFO freeing cache - '+trim(id[i])
  if (struct.ids)[pos] ne '' then heap_free,*((struct.ptrs)[pos])
  struct.ids[pos]=''
 endif
endfor

*self.pointer=struct

return & end

;-----------------------------------------------------------------------------

function fifo::get,id,_ref_extra=extra

self->get,id,value,_extra=extra

return,value & end

;----------------------------------------------------------------------------

function fifo::get_pos,id,verbose=verbose

pos=-1
verbose=keyword_set(verbose)
if ~is_number(id) and ~is_string(id) then return,pos

pointer=self.pointer
if ~ptr_exist(pointer) then begin
 message,'Empty buffer',/cont
 return,pos
endif

struct=*pointer
np=n_elements(struct.ids)

if (is_string(id)) then begin
 chk=where(trim(id) eq struct.ids,count)
 if count gt 0 then pos=chk[0] else if verbose then message,'No element match found for '+id,/cont
endif else begin
 if (id gt -1) and (id lt np) then pos=id else begin
  if verbose then message,'Out of range index',/cont
 endelse
endelse   

return,pos
end
  
;---------------------------------------------------------------------------

pro fifo::get,id,value,status=status,no_copy=no_copy,verbose=verbose,pointer=pointer

value='' & status=0b
            
pos=self->get_pos(trim(id),verbose=verbose)
if pos lt 0 then return
struct=*self.pointer
if keyword_set(verbose) then message,'Restoring - '+trim(id),/cont

ptr=(struct.ptrs)[pos]
if keyword_set(pointer) then begin
 status=1b
 value=ptr
 return
endif

if ~ptr_valid(ptr) then begin
 message,'Invalid pointer',/cont & help,ptr 
 return
endif

if ~exist(*ptr) then begin
 message,'Empty pointer',/cont & help,ptr 
 return
endif

if keyword_set(no_copy) and ~is_object(*ptr) then $
 value=temporary(*ptr) else value=*ptr

status=1b

return & end

;---------------------------------------------------------------------------
;-- define fifo structure

pro fifo__define

fifo_struct={fifo,add_size:0,init_size:0,pointer:ptr_new()}

return & end
