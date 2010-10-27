;+
; Project     : HESSI
;
; Name        : MRD_HEAD
;
; Purpose     : Simplify reading FITS file headers
;
; Category    : FITS I/O
;
; Syntax      : IDL> mrd_head,file,header
;
; Inputs      : FILE = input file name
;
; Outputs     : HEADER = string header
;
; Keywords    : EXTENSION = binary extension [def=0]
;               ERR = error string
;
; Written     : Zarro (EIT/GSFC), 13 Aug 2001
;               10 Oct 2009, Zarro (ADNET) - added more error checks
;
; Contact     : dzarro@solar.stanford.edu
;-

pro mrd_head,file,header,extension=extension,err=err,verbose=verbose,$
                status=status,no_check_compress=no_check_compress,_extra=extra

err='' & header=''
status=-1

;-- catch any errors

verbose=keyword_set(verbose)

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 err=err_state()
 if verbose then message,err,/cont
 close_lun,lun
 return
endif

if is_blank(file) then begin
 err='Invalid input file name.'
 if verbose then message,err,/cont
 return
endif

if n_elements(file) gt 1 then begin
 err='Input file name must be scalar.'
 if verbose then message,err,/cont
 return
endif

chk=loc_file(file,count=count)
if count eq 0 then begin
 err='Could not locate - '+ file
 if verbose then message,err,/cont
 status=1
 return
endif

;-- check if need to manually decompress

if ~keyword_set(no_check_compress) then begin
 compressed=is_compressed(file,type)

 uncompress=~since_version('5.3') or $
            (type eq 'Z') or $
            (type eq 'zip')

 if compressed and uncompress then dfile=find_uncompressed(file,err=err) else dfile=file
 if is_string(err) then return
endif else dfile=file

rext=0
if exist(extension) then rext=extension[0]
err=''
lun = fxposit(dfile,rext,/readonly,silent=~verbose,_extra=extra,err=err)
if verbose then message,'Reading extension '+trim(rext),/cont
if (lun lt 0) or is_string(err) then begin
 err='Failed to read extension '+trim(rext)+' in '+file
 if verbose then message,err,/cont
 return
endif

fxhread,lun, header,status
close_lun,lun

if status ne 0 then begin
 err='Failed to read extension '+trim(rext)+' in '+file
 if verbose then message,err,/cont
endif
 

return
end
