;+
; Project     : HESSI                                                                             
;                                                                                                 
; Name        : MAP__DEFINE                                                                       
;                                                                                                 
; Purpose     : Define a MAP object                                                               
;                                                                                                 
; Category    : imaging objects                                                                   
;                                                                                                 
; Syntax      : IDL> new=obj_new('map')                                                           
;                                                                                                 
; History     : Written 22 Nov 1999, D. Zarro, SM&A/GSFC                                          
;             : Modified 18 Sept 2001, D. Zarro (EITI/GSFC) - improved                            
;               memory management                                                                 
;               Modified 5 Oct 2002, Zarro (LAC/GSFC) - added object                              
;               to store plot properties                                                          
;               Modified 2 Oct 2003, Zarro (GSI/GSFC) - added correction                          
;               for 180 degree rolled images                                                      
;               Modified 7 Feb 2004, Zarro (L-3Com/GSFC) - fixed bug with                         
;               plotting grid/limb                                                                
;               Modified 17 Mar 2004, Zarro (L-3Com/GSFC) - added FOV keyword                     
;               Modified 9 May 2006, Zarro (L-3Com/GSFC) 
;                - added COLOR support                    
;               Modified 23 November 2007, Zarro (ADNET) 
;                - preserve current value of DECOMP
;               Modified 20 August 2008, Zarro (ADNET)
;                - added TRANS_MAP call 
;               Modified 13 May 2008, Zarro (ADNET)
;                - switched to using mwrfits to support multiple image maps
;                Modified 12 Jun 2009, Kim Tolbert
;                - added plotman method
;                Modified 27-Aug-2009, Kim TOlbert
;                - init status to 0 in plot, in case returns with
;                  error (but not in catch)
;                Modified 13-Oct-2009, Zarro (ADNET)
;                - added capability to send multiple images to plotman
;                29-Oct-2009, Zarro (ADNET)
;                - made plot property into a structure instead of object to
;                  avoid memory leaks when updating.
;                1-November-2009, Zarro (ADNET)
;                - replaced LINKED_LIST object with FIFO object which
;                  has better memory management.
;                20-Jan-2010, Zarro (ADNET)
;                - added /no_restore
;                8-April-2010, Zarro (ADNET)
;                - added HISTORY methods
;                11-Jun-2010, Kim
;                - if plotman called with /colors, get colors and set them into plotman obj
;
;                                                                                                 
; Contact     : dzarro@solar.stanford.edu                                                         
;-                                                                                                
                                                                                                  
;-------------------------------------------------------------------------                        
                                                                                                  
function map::init,_extra=extra                                                                   
                                                                                                  
dprint,'% MAP::INIT'                                                                              
self.plot_type='image'                                                                            
self.omap=obj_new('fifo')        ;-- store map structures                                  
self.oindex=obj_new('fifo')      ;-- store data index structures                           
self.oprop=obj_new('fifo')       ;-- store plot property structures
                                                                                                  
return,1                                                                                          
                                                                                                  
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------                          
;--destroy map object                                                                             
                                                                                                  
pro map::cleanup                                                                                  
                                                                                                  
dprint,'% MAP::CLEANUP'                                                                           
self->free_var                                                                                    
return                                                                                            
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------                          
;--empty map object                                                                               
                                                                                                  
pro map::empty                                                                                    
                                                                                                  
if ~obj_valid(self.omap) then return                                                           
self.omap->empty                                                                           
self.oindex->empty                                                                          
self.oprop->empty
                                                                                                  
return & end                                                                                      
                                                                                                  
;-----------------------------------------------------------------------                          
;-- copy map object (function)                                                                    
                                                                                                  
function map::clone,k,_ref_extra=extra                                                            
                                                                                                  
self->clone,cobj,k,_extra=extra                                                                   
                                                                                                  
return,cobj                                                                                       
                                                                                                  
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------                          
;-- copy map object (procedure)                                                                   
                                                                                                  
pro map::clone,cobj,k,err=err,_ref_extra=extra,all=all                                                
                                                                                                  
err=''                                                                                            
                                                                                                  
if keyword_set(all) then begin                                                                    
 obj_copy,self,cobj                                                                               
 return                                                                                           
endif                                                                                             
                                                                                                  
if ~self->has_data(k,_extra=extra,err=err) then begin                                                       
 message,err,/cont                                                                                
 cobj=-1                                                                                          
 return                                                                                           
endif                                                                                             
                                                                                                  
map=self->get(k,/map)                                                                
index=self->get(k,/index)                                                            
props=self->get(k,/props)
                                                                                            
class=obj_class(self)                                                                             
if obj_valid(cobj) then obj_destroy,cobj                                                          
cobj=obj_new(class)          
dprint,'% MAP::CLONE...'

cobj->set,map=map,index=index,props=props,_extra=extra,/no_copy                                            

return                                                                                            
                                                                                                  
end                                                                                               
                                                                                                  
;-------------------------------------------------------------------                              
;-- set map object properties                                                                     
                                                                                                  
pro map::set,k,map=map,index=index,_ref_extra=extra,$                                         
          props=props

if ~is_number(k) then k=0
   
;-- update map object properties 

if valid_map(map) then self.omap->set,k,map,_extra=extra
if is_struct(props) then self.oprop->set,k,props,_extra=extra
if is_struct(index) then self.oindex->set,k,index,_extra=extra
if ~is_string(extra) then return
self->set_plot_prop,k,_extra=extra
self->set_map_prop,k,_extra=extra
                                                         
return                                                                                            
end                                                                                               
                                                                                                  
;--------------------------------------------------------------------------                       
;-- explicitly set map properties                                                                 
                                                                                                  
pro map::set_map_prop,k,data=data,_extra=extra

;-- if inserting data then create and replace whole map

sz=size(data)
if sz[0] eq 2 then smap=make_map(data,_extra=extra) else begin
 if is_struct(extra) then begin                                                                    
  smap=self->get(k,/map,/no_copy,err=err)                                                          
  if valid_map(smap) then begin
   extra=fix_extra(extra,tag_names(smap))                                                          
   struct_assign,extra,smap,/nozero                                                                
  endif
 endif
endelse

if valid_map(smap) then self.omap->set,k,smap,_extra=extra,/no_copy
                                                         
                                                                                                  
return & end                                                                                      
                                                                                                  
;-------------------------------------------------------------------------                        
;-- update index with map information                                                             
                                                                                                  
pro map::update_index,k,err=err                                                                   
                                                                                                  
err=''                                                                                            
if ~self->has_data(k,err=err) then begin                 
 message,err,/cont                                                                                
 return                                                                                           
endif                                                                                             
                                                                                                  
index=self->get(k,/index)                                                              

if ~is_struct(index) then message,'Generating index...',/cont

if err ne '' then return                                                                          
                                                                                                  
;-- make sure CRPIX/CRVAL and XCEN/YCEN are self-consistent                                       
                                                                                                  
nx=self->get(k,/nx)                                                                               
ny=self->get(k,/ny)                                                                               
dx=self->get(k,/dx)                                                                               
dy=self->get(k,/dy)                                                                               
xc=self->get(k,/xc)                                                                               
yc=self->get(k,/yc)                                                                               
roll=self->get(k,/roll_angle)                                                                     
rollc=self->get(k,/roll_center)                                                                   
         
index=rep_tag_value(index,2,'naxis')                                                             
index=rep_tag_value(index,nx,'naxis1')                                                             
index=rep_tag_value(index,ny,'naxis2')                                                             
                                                                        
index=rep_tag_value(index,0,'crval1')                                                             
index=rep_tag_value(index,0,'crval2')                                                             
                                                                                                  
index=rep_tag_value(index,dx,'cdelt1')                                                            
index=rep_tag_value(index,dy,'cdelt2')                                                            
                                                                                                  
crpix1=comp_fits_crpix(xc,dx,nx,0.)                                                               
crpix2=comp_fits_crpix(yc,dy,ny,0.)                                                               
                                                                                                  
index=rep_tag_value(index,crpix1,'crpix1')                                                        
index=rep_tag_value(index,crpix2,'crpix2')                                                        
                                                                                                  
index=rep_tag_value(index,xc,'xcen')                                                              
index=rep_tag_value(index,yc,'ycen')                                                              
                                                                                                  
index=rep_tag_value(index,roll,'crota')

index=rep_tag_value(index,rollc[0],'crotacn1')                                                    
index=rep_tag_value(index,rollc[1],'crotacn2')                                                    

self->set,k,index=index
                                                                                                  
return & end                                                                                      
                    
;--------------------------------------------------------------------------                       
                                                                                                  
pro map::write,file,k,err=err,out_dir=out_dir,compress=compress,$
             verbose=verbose,_extra=extra                         
                                                                                                  
;-- validate output file name and directory                                                       
                                                                                                  
err=''                                                                                            
if is_blank(file) then begin                                                                      
 err='Invalid file name entered.'                                                                  
 message,err,/cont                                                                                
 return                                                                                           
endif                                                                                             

count=self->get(/count)
if count eq 0 then return
break_file,file,dsk,dir,name,ext                                                                  
odir=trim(dsk+dir)                                                                                
if is_blank(odir) then odir=curdir()                                                              
if exist(out_dir) then odir=out_dir                                                               
if ~write_dir(odir,err=err,/verbose) then return                                                        
oname=trim(name+ext)                                                                              
ofile=concat_dir(odir,oname)                                                                      
         
wrote_file=0b
if is_number(k) then count=1 else k=0
for i=0,count-1 do begin
 if count eq 1 then j=k else j=i
 if ~self->has_index(j) or ~self->has_data(j) then continue
 map=self->get(j,/map)                                                                     
 if ~valid_map(map) then continue
 index=self->get(j,/index)                                                                         
 index=rep_tag_value(index,oname,'filename')
 if have_tag(index,'bscale') then bscale=index.bscale else bscale=0.
 if bscale eq 0. then index=rep_tag_value(index,1.,'bscale')
 index=rep_tag_value(index,1,'naxis3')
 index=rep_tag_value(index,map.roll_angle,'crota')
 rcenter=map.roll_center
 index=rep_tag_value(index,rcenter[0],'crotacn1')
 index=rep_tag_value(index,rcenter[1],'crotacn2')
 header=struct2fitshead(index,/allow_crota)
 mwrfits,map.data,ofile[0],header,create=(i eq 0),/silent
; message,'Writing file - '+ofile[0],/cont
 wrote_file=1b
endfor
      
if wrote_file then begin
 if keyword_set(verbose) then message,'Wrote FITS file - '+ofile,/cont                  
 chmod,ofile,/g_write,/g_read,/verbose                                                                      
 if keyword_set(compress) then espawn,'gzip -f '+ofile,/noshell,_extra=extra
endif else message,'FITS file not written.',/cont
                                                                                                  
return & end
                                                                                      
;----------------------------------------------------------------------------                     
;-- get data method                                                                               
                                                                                                  
function map::getdata,k                                                                           
return, self-> get(k,/data)                                                                       
end                                                                                               

;----------------------------------------------------------------------------                     
;-- get map method                                                                               
                                                                                                  
function map::getmap,k                                                                           
return, self-> get(k,/map)                                                                       
end                                                                                               
                                                                                                  

;----------------------------------------------------------------------------
;-- set map method

pro map::setmap,k,map,_extra=extra

self->set,k,map=map,_extra=extra

return & end
                                                                                    
;-------------------------------------------------------------------                              
;-- get map object properties                                                                     
                                                                                                  
function map::get,k,map=map,type=type,_extra=extra,$              
              plot_type=plot_type,filename=filename,err=err,header=header,$                       
              index=index,count=count,$                                   
              props=props,all_props=all_props                                                                 


err=''                                                                                            
error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 goto,bail
endif
    
if ~is_number(k) then k=0                                                                          
                                                                                                  
;-- map properties                                                                                
                                                                                                  
if keyword_set(map) then begin                                                                    
 count=self.omap->get_count()                          
 if count gt 0 then return,self.omap->get(k,_extra=extra) else return,''
endif
                                                                                                  
;-- top level properties                                                                          
                                                                                                  
if keyword_set(type) then return,self.plot_type                                                   
if keyword_set(plot_type) then return,self.plot_type                                              
                                                                                                  
if keyword_set(index) or keyword_set(header) then begin                                           
 if ~self->has_index(k,err=err) then return,''                                                 
 index=self.oindex->get(k)
 if ~is_struct(index) then return,''                                                                      
 if keyword_set(header) then return,struct2fitshead(index) else return,index                      
endif                                                                                             
                                                                                                  
if keyword_set(count) then return,self.omap->get_count()                                          

;if ~self->has_data(k,err=err) then return,''                                                   
                                                                                                  
;-- index properties                                                                              
                                                                                                  
if keyword_set(filename) then begin                                                               
 if ~self->has_index(k,err=err) then return,''                                                 
 return,(self.oindex->get(k)).filename                                              
endif       

if keyword_set(props) or keyword_set(all_props) then return,self.oprop->get(k)                                

if is_struct(extra) then begin
 map_prop=self->get_map_prop(k,_extra=extra,err=err)                                              
 if err eq '' then return,map_prop                                                                
 plot_prop=self->get_plot_prop(k,_extra=extra,err=err)
 if err eq '' then return,plot_prop                                                               
endif                                                                                             
        
;-- if we get here then property is not supported                                                 
   
bail:         
err='No matching property found.'
                                                                                                  
return,''                                                                                         
end                                                                                               
            
;--------------------------------------------------------------------------                       
;-- get properties of plot map structure                                                               
                                                                                                  
function map::get_plot_prop,k,_extra=extra,err=err

err=''
if ~is_number(k) then k=0                                                                          
if ~is_struct(extra) then return,''
props=self.oprop->get(k) 
if ~is_struct(props) then return,''

plot_map_struct,tprops
extra=fix_extra(extra,tprops)

etags=tag_names(extra)
ptags=tag_names(props)
match,ptags,etags,i,j,count=count

if count eq 0 then return,''
return,props.(i[0])
end
                                                                                    
;--------------------------------------------------------------------------                       
;-- set properties of plot map structure                                                               
                                                                                                  
pro map::set_plot_prop,k,_extra=extra

if ~is_struct(extra) then return
if ~is_number(k) then k=0

;-- create plot map structure if not present

plot_map_struct,tprops
props=self.oprop->get(k) 
if ~is_struct(props) then props=tprops

;-- update matching tags

extra=fix_extra(extra,tprops)
etags=tag_names(extra)
ptags=tag_names(props)
match,ptags,etags,i,j,count=count
if count eq 0 then return
nstruct=n_elements(etags)
for i=0,nstruct-1 do begin
 chk=where(etags[i] eq ptags,count)
 if count gt 0 then props=rep_tag_value(props,extra.(i),etags[i],/no_check)
endfor 
 
;-- update object

self.oprop->set,k,props

end
                                                                                    
;--------------------------------------------------------------------------                       
;-- get properties of map structure                                                               
                                                                                                  
function map::get_map_prop,k,xc=xc,yc=yc,dx=dx,dy=dy,nx=nx,ny=ny,$                                
              roll_angle=roll_angle,roll_center=roll_center,$                                     
              xyoffset=xyoffset,xrange=xrange,yrange=yrange,drange=drange,$                       
              time=time,data=data,id=id,xunits=xunits,yunits=yunits,dur=dur,$                     
              xp=xp,yp=yp,pixel_size=pixel_size,$                                       
              err=err,_extra=extra                                                                
                                           
err=''   
emess='No matching property found.'                                                                                         
ptr=self.omap->get(k,/pointer)                                                                
if ~ptr_exist(ptr) then begin
 err=emess
 return,''
endif                                                                       
                                                                                                  
;-- basic properties                                                                              
                                                                                                  
if keyword_set(xc) then return,(*ptr).xc                                                          
if keyword_set(yc) then return,(*ptr).yc                                                          
if keyword_set(dx) then return,(*ptr).dx                                                          
if keyword_set(dy) then return,(*ptr).dy                                                          
if keyword_set(roll_angle) then return,(*ptr).roll_angle                                          
if keyword_set(roll_center) then return,(*ptr).roll_center                                        
if keyword_set(data) then return,(*ptr).data                                                      
                                                                                                  
;-- optional properties                                                                           
                                                                                                  
if keyword_set(xunits) then return,(*ptr).xunits                                                  
if keyword_set(yunits) then return,(*ptr).yunits                                                  
if keyword_set(dur) then return,(*ptr).dur                                                        
if keyword_set(id) then return,(*ptr).id                                                          
                                                                                                  
;-- derived properties                                                                            
                                                                                                  
if keyword_set(time) then begin                                                                   
 if have_tag(*ptr,'rtime') then return,anytim2utc((*ptr).rtime,/vms) else $                       
  return,anytim2utc((*ptr).time,/vms)                                                             
endif                                                                                             
                                                                                                  
if keyword_set(xyoffset) then return,[(*ptr).xc,(*ptr).yc]                                        
if keyword_set(pixel_size) then return,[(*ptr).dx,(*ptr).dy]                                      
if keyword_set(xp) then return,self->xp(k)                                                        
if keyword_set(yp) then return,self->yp(k)                                                        
if keyword_set(xrange) then return,self->xrange(k)                                                
if keyword_set(yrange) then return,self->yrange(k)                                                
if keyword_set(drange) then return,self->drange(k)                                                
if keyword_set(nx) then return,(size((*ptr).data))[1]                                             
if keyword_set(ny) then return,(size((*ptr).data))[2]                                             

err=emess
            
return,'' & end                                                                                   
                                                                                                  
;--------------------------------------------------------------------------                       
;-- create map structure                                                                      
                                                                                                  
pro map::mk_map,index,data,k,_ref_extra=extra,filename=filename

index2map,index,data,map,_extra=extra
if ~valid_map(map) then return
                                                                                                  
if ~have_tag(index,'filename') then index=add_tag(index,'','filename')                         
if is_string(filename) then index.filename=file_basename(filename)

self->set,k,map=map,index=index,_extra=extra,/no_copy                                          
                                                                                                  
return & end                                                                                      
                                                                                                  
;-----------------------------------------------------------------------                          
                                                                                                  
function map::xrange,k                                                                            
                                                                                                  
xc=self->get(k,/xc)                                                                               
nx=self->get(k,/nx)                                                                               
dx=self->get(k,/dx)                                                                               
                                                                                                  
xmin=min(xc-dx*(nx-1.)/2.)                                                                        
xmax=max(xc+dx*(nx-1.)/2.)                                                                        
return,[xmin,xmax]                                                                                
                                                                                                  
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------------                    
                                                                                                  
function map::yrange,k                                                                            
                                                                                                  
yc=self->get(k,/yc)                                                                               
ny=self->get(k,/ny)                                                                               
dy=self->get(k,/dy)                                                                               
                                                                                                  
ymin=min(yc-dy*(ny-1.)/2.)                                                                        
ymax=max(yc+dy*(ny-1.)/2.)                                                                        
return,[ymin,ymax]                                                                                
                                                                                                  
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------------                    
                                                                                                  
function map::drange,k                                                                            
                                                                                                  
if ~self->has_data(k,err=err) then return,[0,0]                                                
                                                                                                  
item=self.omap->get(k,/pointer)                                                               
dmin=min( (*item).data,max=dmax)                                                                  
return,[dmin,dmax]                                                                                
                                                                                                  
end                                                                                               
                                                                                                  
;-------------------------------------------------------------------------------                  
                                                                                                  
function map::xp,k,oned=oned                                                                      
                                                                                                  
xc=self->get(k,/xc)                                                                               
nx=self->get(k,/nx)                                                                               
ny=self->get(k,/ny)                                                                               
dx=self->get(k,/dx)                                                                               
                                                                                                  
if keyword_set(oned) then ny=1                                                                    
                                                                                                  
return,mk_map_xp(xc,dx,nx,ny)                                                                     
                                                                                                  
end                                                                                               
                                                                                                  
;-----------------------------------------------------------------------------------              
                                                                                                  
function map::yp,k,oned=oned                                                                      
                                                                                                  
yc=self->get(k,/yc)                                                                               
dy=self->get(k,/dy)                                                                               
nx=self->get(k,/nx)                                                                               
ny=self->get(k,/ny)                                                                               
                                                                                                  
if keyword_set(oned) then nx=1                                                                    
                                                                                                  
return,mk_map_yp(yc,dy,nx,ny)                                                                     
                                                                                                  
end                                                                                               
                                                                                                  
;----------------------------------------------------------------------------                     
;-- plot map object                                                                               
                                                                                                  
pro map::plot,k,_extra=extra,fov=fov,surface=surface,shade_surf=shade_surf,$
              err_msg=err_msg,status=status,roll=roll,colors=colors,$
              no_restore=no_restore

;-- check if rolling map. 
;-- if rolling, then we have to preserve a copy of the original.
;-- if /no_restore is set and an operation such as translation or
;   rotation is applied, then the map will not be restored to its initial state

restore=~keyword_set(no_restore)
rolling=0b
roll_passed=is_number(roll)
if roll_passed then rolling=(roll mod 360.) ne 0.       

status=0
error=0
catch,error

if error ne 0 then begin
 status=0
 err_msg=!err_string
 message,err_msg,/cont
 catch,/cancel
 goto,cleanup
endif

if ~self->has_data(k,_extra=extra,/verbose) then return                
props=self->get(k,/props)                                                                              
map=self->get(k,/map,no_copy=~rolling,_extra=extra)                                                        
if ~valid_map(map) then return
      
;-- override plot properties with command-line keywords
                
if is_struct(extra) then begin
 plot_map_struct,template
 extra=fix_extra(extra,template)
endif  

if is_struct(props) then extra=join_struct(extra,props)                                                                    

;-- load map color table                                                                                       

if keyword_set(colors) and self->get(k,/has_colors) then begin
 device2,get_decomposed=decomp
 tvlct,r0,g0,b0,/get                                                                              
 self->load_ct,k                                                                                 
 device2,decomp=0
endif
                                                                                                  
if exist(fov) then fmap=fov                                                                       
if valid_omap(fov) then fmap=fov->get(/map,/no_copy)                                              

;-- apply coordinate transformation (shifting, rescaling) and then
;   roll

trans_map,map,_extra=extra
if rolling then map=rot_map(map,roll)

if keyword_set(surface) or keyword_set(shade_surf) then $
 surface_map,map,shade_surf=shade_surf,_extra=extra,err=err_msg else $
 plot_map,map,_extra=extra,no_roll_correct=rolling,fov=fmap,err_msg=err_msg,status=status                           

cleanup:

;-- set things back the way they were

if valid_map(map) then begin
 if restore then begin
  trans_map,map,_extra=extra,/reverse
  if ~rolling then self->set,k,map=map,/no_copy                                                             
 endif else self->set,k,map=map,/no_copy                                                             
endif 

if exist(decomp) then device2,decomp=decomp
if valid_omap(fov) and valid_map(fmap) then fov->set,map=fmap,/no_copy                                       
                                                                                                  
;-- reset original colors                                                                                  
                                                                                                  
if exist(r0) then tvlct,r0,g0,b0                                                        
                                                                                                  
return & end                                                                                      
                  
;---------------------------------------------------------------------------                     
                  
pro map::plotman, k, plotman_obj=plotman_obj, colors=colors, _extra=extra

count=self->get(/count)
if count eq 0 then begin
 message,'No maps available',/cont
 return
endif

;-- check input index. If not entered plot all available maps.

do_all=0b
if is_number(k) then begin
 if (k lt 0) or (k gt count) then begin
  message,'Invalid map index',/cont
  return
 endif
endif else do_all=1b

;-- invoke plotman object

valid_plotman = is_class(plotman_obj,'plotman', /quiet) ? plotman_obj->valid() : 0
if valid_plotman then error=0 else plotman_obj = obj_new('plotman', error=error)
if error then begin
 message,'Error creating PLOTMAN widget.', /continue
 return
endif

if do_all then val=indgen(count) else val=k
for i=0,n_elements(val)-1 do begin
 kval=val[i]
 desc = file_basename(self->get(kval,/filename))+' '+self->get(kval,/id) + ' ' + self->get(kval,/time)
 desc=strcompress(desc)
 if (count eq 1) then kobj=self else kobj=self->clone(kval) 
 noclone=(count gt 1)
 if keyword_set(colors) and self->get(kval,/has_colors) then begin                                                                           
   self->load_ct,k
   tvlct, red,green,blue, /get                                                                              
 endif
 plotman_obj -> new_panel, input=kobj, plot_type='image',/nodup,noclone=noclone,desc =desc,$
   red=red, green=green, blue=blue, _extra=extra
endfor

return & end
                                                                                       
;----------------------------------------------------------------------------                     
;-- save current color table into map         
                                                                                         
pro map::save_ct,k                                                                              
                                                                                                  
tvlct,red,green,blue,/get                                                                         
self->set,k,red=red,green=green,blue=blue,/has_colors
                                                                                                  
return & end                                      
                                                                                                  
;-------------------------------------------------------------------------                        
;-- load map color table
                                                                                                  
pro map::load_ct,k                                                                     

if self->get(k,/has_colors) then begin
 red=self->get(k,/red) 
 green=self->get(k,/green)
 blue=self->get(k,/blue)
 tvlct,red,green,blue
endif
            
return                                                                                            
                                                                                                  
end                                                                                               
                                                                                                  
;--------------------------------------------------------------------------                       
;-- extract sub-region (function)                                                                 
                                                                                                  
function map::extract,k,_ref_extra=extra                                                          
                                                                                                  
self->clone,cobj,k,_extra=extra                                                                   
cobj->extract,_extra=extra                                                                        
return,cobj                                                                                       
end                                                                                               
                                                                                                  
;--------------------------------------------------------------------------                       
;-- extract sub-region (procedure)                                                                
                                                                                                  
pro map::extract,k,_extra=extra,err=err                                                           
                                                                                                  
err=''                                                                                            
if ~self->has_data(k,err=err) then begin                                                       
 message,err,/cont                                                                                
 return                                                                                           
endif                                                                                             
                                                                                                  
map=self->get(k,/map,/no_copy)                                                                    
                                                                                                  
sub_map,map,smap,_extra=extra                                                                     
self->set,k,map=smap,/no_copy                                                            
self->update_index,k                                                                              
return & end                                                                                      
                                                                                                  
;----------------------------------------------------------------------------                     
;-- rotate map object (function)                                                                  
                                                                                                  
function map::rotate,angle,k,_ref_extra=extra                                                     
                                                                                                  
self->clone,cobj,k,_extra=extra                                                                   
cobj->rotate,angle,_extra=extra                                                                   
return,cobj                                                                                       
                                                                                                  
end                                                                                               
                                                                                                  
                                                                                                  
;----------------------------------------------------------------------------                     
;-- drotate map object (function)                                                                 
                                                                                                  
function map::drotate,duration,k,_ref_extra=extra                                                 
                                                                                                  
self->clone,cobj,k,_extra=extra                                                                   
cobj->drotate,duration,_extra=extra                                                               
return,cobj                                                                                       
                                                                                                  
end                                                                                               
                                                                                                  
;----------------------------------------------------------------------------                     
;-- rotate map object (procedure)                                                                 
                                                                                                  
pro map::rotate,angle,k,_extra=extra,err=err,all=all                                              
                                                                                                  
err=''                                                                                            
                                                                                                  
count=self->get(/count)                                                                           
if is_number(k) then m=k else m=0                                                                 
all=keyword_set(all)                                                                              
istart=m & iend=m                                                                                 
if all then begin                                                                                 
 istart=0 & iend=count-1                                                                          
endif                                                                                             
                                                                                                  
for i=istart,iend do begin                                                                        
                                                                                                  
 if ~self->has_data(m,err=err) then begin                                                      
  message,err,/cont                                                                               
  continue                                                                                        
 endif                                                                                            
                                                                                                  
 map=self->get(m,/map,/no_copy)                                                                   
                                                                                                  
 rmap=rot_map(map,angle,_extra=extra,err=err,/full_size)                                          
 if err ne '' then begin                                                                          
  self->set,m,map=map,/no_copy                                                           
  continue                                                                                        
 endif                                                                                            
                                                                                                  
 self->set,m,map=rmap,/no_copy
                        
 self->update_index,m                                                                             
                                                                                                  
endfor                                                                                            
                                                                                                  
status=1b                                                                                         
return & end                                                                                      
                                                                                                  
                                                                                                  
;----------------------------------------------------------------------------                     
;-- solar rotate map object                                                                       
                                                                                                  
pro map::drotate,duration,k,_extra=extra,err=err,all=all                                          
                                                                                                  
err=''                                                                                            
if (1-is_number(k)) then k=0                                                                      
do_all=keyword_set(all)                                                                           
count=self->get(/count)                                                                           
lind=indgen(count)                                                                                
                                                                                                  
;-- check if doing all or one                                                                     
                                                                                                  
if do_all then begin                                                                              
 chk=lind & dcount=count                                                                          
endif else begin                                                                                  
 chk=where(k eq lind,dcount)                                                                      
 if dcount eq 0 then begin                                                                        
  lind=0 & dcount=1                                                                               
 endif                                                                                            
endelse                                                                                           
                                                                                                  
for i=0,dcount-1 do begin                                                                         
 err=''                                                                                           
 j=lind[i]                                                                                        
 if ~self->has_data(j,err=err) then begin                                                      
  message,err,/cont                                                                               
  continue                                                                                        
 endif                                                                                            
                                                                                                  
 map=self->get(j,/map,/no_copy)                                                                   
                                                                                                  
 rmap=drot_map(map,duration,_extra=extra,err=err)                                                 
 if err ne '' then begin                                                                          
  self->set,j,map=map,/no_copy
  continue                                                                                        
 endif                                                                                            
                                                                                                  
 self->set,j,map=rmap,/no_copy
 self->update_index,j                                                                             
endfor                                                                                            
                                                                                                  
return & end                                                                                      
              
;---------------------------------------------------------------------------                      
;-- check if map is contained in object                                                           
                                                                                                  
function map::has_data,k,err=err,verbose=verbose                                                                  
                                                                                                  
err=''                                                                                            
if ~is_number(k) then k=0                                                                      
ptr=self.omap->get(k,/pointer)                                                                        
have_map=ptr_exist(ptr)                                                                           
if ~have_map then err='No map currently saved ('+trim(k)+')'                               
if keyword_set(verbose) and is_string(err) then message,err,/cont            
                                                                                      
return,have_map                                                                                   
end                                                                                               
                                                                                                  
;---------------------------------------------------------------------------                      
;-- check if index is contained in object                                                         
                                                                                                  
function map::has_index,k,err=err                                                                 
                                                                                                  
err=''                                                                                            
if ~is_number(k) then k=0                                                                      
self.oindex->get,k,index                                                             
have_index=is_struct(index)                                                                         
if ~have_index then err='No index currently saved ('+trim(k)+')'                               
return,have_index                                                                                 
                                                                                                  
end                                                                                               
                 
;-------------------------------------------------------------------------

pro map::show,k

if self->has_data(k) then begin
 message,strtrim(self->get(k,/id),2)+' -> '+strtrim(self->get(k,/time),2),/cont
endif

return & end

;--------------------------------------------------------------------------
;-- check text in index history tag

function map::has_history,k,text

kindex=0
if is_number(k) then kindex=k
if is_string(text) then ktext=text
if is_string(k) then begin
 ktext=k & kindex=0
endif 
index=self->get(kindex,/index)
history=get_history(index)
chk=where(stregex(history,ktext,/bool),count)
return,count gt 0
end

;--------------------------------------------------------------------------
;-- update text in index history tag

pro map::update_history,k,text

kindex=0
if is_number(k) then kindex=k
if is_string(text) then ktext=text
if is_string(k) then begin
 ktext=k & kindex=0
endif 
index=self->get(kindex,/index)
update_history,index,ktext
self->set,kindex,index=index
return
end

;-------------------------------------------------------------------------
;-- correct roll_center to be Sun center

pro map::fix_roll_center
if ~self->has_data() then return
roll_angle=self->get(/roll_angle)
if (nint(roll_angle) mod 360) eq 0 then return
roll_center=self->get(/roll_center)
if ~valid_range(roll_center) then return
map=self->get(/map,/no_copy)
roll_center=map.roll_center
roll_xy,roll_center[0],roll_center[1],roll_angle,p,q
map.xc=map.xc-p
map.yc=map.yc-q
map.roll_center=[0,0]
self->set,map=map,/no_copy
return & end


;---------------------------------------------------------------------------                      
pro map__define                                                                                   
                                                                                                  
map={map, $                                                                                       
     plot_type:'',$                                                                               
     omap:obj_new(),$                                                                             
     oindex:obj_new(),$                                                                           
     oprop:obj_new(), inherits free_var}                                                                            
                                                                                                  
return                                                                                            
end                                                                                               

