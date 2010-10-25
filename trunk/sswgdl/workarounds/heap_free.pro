pro heap_free, a, _extra=_extra

heap_gc, _extra=_ref_extra
return
tname=size(/tname, a)
if tname eq 'OBJREF' then obj_destroy, a, _ref_extra=_ref_extra $

else if tname eq 'POINTER' then $

ptr_free, a

end
