;+
; Project     : HESSI
;
; Name        : SOCK_FIND
;
; Purpose     : socket version of FINDFILE
;
; Category    : utility system sockets
;
; Syntax      : IDL> files=sock_find(server,file,path=path)
;                   
; Inputs      : server = remote WWW server name
;               FILE = remote file name or pattern to search 
;
; Outputs     : Matched results
;
; Keywords    : COUNT = # of matches
;               PATH = remote path to search
;               ERR   = string error message
;
; Example     : IDL> a=sock_find('smmdac.nascom.nasa.gov','*.fts',$
;                                 path='/synop_data/bbso')
;
; History     : 27-Dec-2001,  D.M. Zarro (EITI/GSFC) - Written
;                3-Feb-2007, Zarro (ADNET/GSFC) - Modified
;                 - return full URL path
;                 - made no-cache the default
;               27-Feb-2009, Zarro (ADNET) 
;                 - restored caching for faster repeat searching of
;                   same directory
;                 - improved regular expression to handle wild card
;                   searches
;               17-Jan-2010, Zarro (ADNET)
;                 - modified to return "http://" in output
;               22-Oct-2010, Zarro (ADNET)
;                 - modified to extract multiple files listed per line
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function sock_find,server,file,path=path,count=count,err=err,$
                   _extra=extra,reset=reset


;--- start with error checking

err=''
count=0
sname='' 
sdir=''

if is_blank(server) then begin
 err='missing remote server name'
 message,err,/cont
 return,''
endif

;-- escape any metacharacters

if is_string(file) then begin
 sname=file_basename(file)
 sdir=file_dirname(file)
 if sdir eq '.' then sdir=''
 sname=str_replace(sname,'.','\.')
 sname=str_replace(sname,'*','[^ "]*')
endif 

if is_blank(sdir) then begin
 if is_string(path) then sdir=trim(path) else sdir='/'
endif

sdir=str_replace(sdir,'\','/')
slash=strpos(sdir,'/')
if slash ne 0 then sdir='/'+sdir
slash=strpos(sdir,'/',/reverse_search)
len=strlen(sdir)
if slash ne (len-1) then sdir=sdir+'/'


url=server+sdir
sock_list,url,hrefs,err=err
if is_string(err) or is_blank(hrefs) then return,''

if is_string(sname) then ireg='[^\?\/ "]*'+trim(sname)+'[^ "]*' else ireg='[^<> "]+'
regex='href *= *"?('+ireg+') *"?.*>'

;-- concatanate into single string and then split on anchor boundaries
;   [must do this so that multiple files per line get separated]

temp=strsplit(strjoin(hrefs),'< *A +',/extract,/regex,/fold)
match=stregex(temp,regex,/subex,/extra,/fold)
chk=where(match[1,*] ne '',count)
if count eq 0 then return,''
hrefs=reform(match[1,chk])
hrefs=str_replace(hrefs,sdir,'')
if ~stregex(url,'http:',/bool) then url='http://'+url

return,url+hrefs

end


