;+                                                                                              
; Project     : VSO                                                                             
;                                                                                               
; Name        : VSO_SEARCH()                                                                    
;                                                                                               
; Purpose     : Send a search request to VSO                                                    
;                                                                                               
; Explanation : Sends a query to VSO, to obtain metadata records corresponding                  
;               to the records that match the query parameters.                                 
;                                                                                               
; Category    : Utility, Class2, VSO                                                            
;                                                                                               
; Syntax      : IDL> a = vso_search('2005-JAN-01', instrument='eit')                            
;                                                                                               
; Examples    : IDL> a = vso_search(date='2004-01-01', provider='sdac')                         
;               IDL> a = vso_search(date='2002-1-4 - 2002-1-4T07:05', inst='mdi')               
;               IDL> a = vso_search(date='2004/1/4T07:40-2004/1/4T07:45', inst='trace')         
;               IDL> a = vso_search(date='2004-1-1', extent='CORONA', /FLAT)                    
;               IDL> a = vso_search(date='2001-1-1', physobs='los_magnetic_field')              
;               IDL> a = vso_search(date='2004/1/1', inst='eit', /DEBUG)                        
;               IDL> a = vso_search('2004/1/1','2004/12/31', wave='171 Angstrom', inst='eit')   
;               IDL> a = vso_search('2004/6/1','2004/6/15', wave='284-305 Angstrom', inst='eit')
;               IDL> a = vso_search('2005-JAN-1', inst='eit', /FLAT, /URL)                      
;                                                                                               
;               IDL> print_struct, a                                                            
;               IDL> print_struct, a.time       ; if not called w/ /FLATTEN                     
;               IDL> sock_copy, a.url           ; if called w/ /URLS                            
;               IDL> vso_get, a                 ; attempt to download products                  
;		                                                                                             
;                                                                                               
; History     : Ver 0.1, 27-Oct-2005, J A Hourcle.  split this out from vso__define             
;               Ver 1,   08-Nov-2005, J A Hourcle.  Released                                    
;                        12-Nov-2005, Zarro (L-3Com/GSFC)                                       
;                         - added TSTART/TEND for compatability with SSW usage.                 
;                         - added _REF_EXTRA to communicate useful keywords                     
;                           such as error messages.                                             
;               Ver 1.1, 01-Dec-2005, Hourcle.  Updated documentation                           
;               Ver 1.2, 02-Dec-2005, Zarro. Added call to VSO_GET_C
;               Ver 1.3, 18-May-2006, Zarro. Removed call to VSO_GET_C
;                           because it confused the compiler
;                                                                                               
; Contact     : oneiros@grace.nascom.nasa.gov                                                   
;               http://virtualsolar.org/                                                        
;                                                                                               
; Input:                                                                                        
;   (note -- you must either specify DATE, START_DATE or TSTART)                                
; Optional Input:                                                                               
; (positional query parameters))                                                                
;   TSTART     : string ; the start date                                                        
;   TEND       : string ; the end date                                                          
; (named query parameters)                                                                      
;   DATE       : string ; (start date) - (end date)                                             
;   START_DATE : string ; the start date                                                        
;   END_DATE   : string ; the end date                                                          
;   WAVE       : string ; (min) - (max) (unit)                                                  
;   MIN_WAVE   : string ; minimum spectral range                                                
;   MAX_WAVE   ; string ; maximum spectral range                                                
;   UNIT_WAVE  ; string ; spectral range units (Angstrom, GHz, keV)                             
;   EXTENT     ; string ; VSO 'extent type' ... (FULLDISK, CORONA, LIMB, etc)                   
;   PHYSOBS    ; string ; VSO 'physical observable;                                             
;   PROVIDER   ; string ; VSO ID for the data provider (SDAC, NSO, SHA, MSU, etc)               
;   SOURCE     ; string ; spacecraft or observatory (SOHO, YOHKOH, BBSO, etc)                   
;   INSTRUMENT ; string ; instrument ID (EIT, SXI-0, SXT, etc)                                  
; (placeholders for the future)                                                                 
;   DETECTOR   ; string ; detector ID (not supported by all providers; use inst also)           
;   FILTER     ; string ; filter name (same problems as detector)                               
;                                                                                               
; (other flags)                                                                                 
;   URLS       ; flag ; attempt to get URLs, also                                               
;   QUIET      ; flag ; don't print informational messages                                      
;   DEBUG      ; flag ; print xml soap messages                                                 
;   FLATTEN    ; flag ; return vsoFlat Record (no sub-structures)                               
;                                                                                               
; Outputs:                                                                                      
;   a null pointer -> no matches were found                                                     
;   (or)                                                                                        
;   struct[n] : (vsoRecord or vsoFlatRecord) the metadata from the results                      
;                                                                                               
; Limitations : if using /URLS, you may wish to examine output.getinfo for messages             
;                                                                                               
; note -- resolution of date parameters: order of precidence                                    
;   DATE (named parameter)                                                                      
;   TSTART/TEND (positional parameters)                                                         
;   START_DATE/END_DATE (named parameters)                                                      
; it is possible to mix TSTART/END_DATE, or DATE(only a start)/END_DATE                         
; but it is not recommended, and may not be supported in the future.                            
;                                                                                               
; if no end date is specified, the system will use the start of the                             
; next day                                                                                      
;                                                                                               
;-                                                                                              
                                                                                                
FUNCTION vso_search2, tstart,tend, instrument=instrument, urls=urls
  ; Instantiate wrapper objects to access the underlying Java objects
  ; which handle the client to server communication.
  sa = OBJ_NEW('IdlSearchAccessor')
  t = OBJ_NEW('IdlTime')
  
  ; Attach the time wrapper object to the IdlSearchAccessor
  sa->doSetTime, t
  
  ; Set start and end time for the search (interval)

  dstart=get_def_times(tstart,tend,/vms,dend=dend)
  t->doSetStartTime, sa->parseTime(dstart)
  t->doSetEndTime, sa->parseTime(dend)
  
  ; Perform the search. Rotation is necessary 
  ; because IDL interprets the returned array
  ; different from Java.
  results =  rotate(sa->doSearch(instrument), 4)
  
  ; Clean up
  OBJ_DESTROY, sa
  OBJ_DESTROY, t
  
  ; Construct a show_synop valid result set
  time = { vsoTime, start:'', _end:'' }
  wave = { vsoWave, min:0L, max:0L, type:'', unit:'' }
  extent   = { vsoExtent, type:'', width:0L, length:0L, x:0L, y:0L }
  structure =  { vsoRecord, time:time, extent:extent, wave:wave, detector:'', instrument:'', source:'', provider:'', info:'', physobs:'', fileid:'', size:0L, url:'', getinfo:'' }
  
  returnresults = REPLICATE(structure, N_ELEMENTS(results[0,*]))
  
  FOR i = 0L, N_ELEMENTS(results[0,*])-1 DO BEGIN
    if (results[8,i] eq '') THEN BEGIN
      RETURN, OBJ_NEW()
    ENDIF ELSE BEGIN
      returnresults[i].time.start = results[8,i]
      returnresults[i].time._end = results[9,i]

      returnresults[i].wave.max = float( results[11,i] )
      returnresults[i].wave.min = float( results[10,i] )
      returnresults[i].wave.type = results[13,i]
      returnresults[i].wave.unit = results[12,i]
      
      returnresults[i].extent.length = float( results[16,i] )
      returnresults[i].extent.type = results[14,i]
      returnresults[i].extent.width = float( results[15,i] )
      returnresults[i].extent.x = float( results[17,i] )
      returnresults[i].extent.y = float( results[18,i] )
      
      returnresults[i].detector = results[4,i]
      returnresults[i].instrument = results[3,i]
      returnresults[i].source = results[2,i]
      returnresults[i].provider = results[1,i]
      returnresults[i].info = results[7,i]
      returnresults[i].physobs = results[5,i]
      returnresults[i].fileid = results[0,i]
      returnresults[i].size = float( results[6,i] )
      returnresults[i].url = results[19,i]
    ENDELSE
  ENDFOR
  RETURN, returnresults
END                                                                                             
