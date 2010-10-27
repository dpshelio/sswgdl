function read_ps_gs, img_file, r, g, b
;+
; NAME:
;   read_ps
; PURPOSE:
;   Read the PostScript file 'img_file' into IDL using GhostScript
;
; CALLING SEQUENCE:
;   img = read_ps_gs(image_filename, r, g, b)
;
; INPUTS:
;   image_filename  - Postscript filename
;
; OPTIONAL INPUT KEYWORDS:
;   None.  Someone who has time to understand keyword inheritance could
;   have fun with the COLORS keyword in COLOR_QUAN at the end of this.
;
; NOTES:
;   This program spaws ghostscript to convert the .ps file to a raw
;   Portable pixmap (ppmraw) format.  Most implementations of gs seem
;   to have this compiled in.  The resulting .ppm file is stored in 
;   /tmp.  This is in turn read via READ_PPM as a true-color image. 
;   This is then converted to whatever you call the RGB format we
;   typically use in IDL.
;
;   Lots more potential here.  Could verify this is a ps file.  If
;   gs doesn't have the appropriate drivers, this will crash 
;   unceremoniously.
;
; REQUIREMENTS:
;   IDL 4.0.1 or better so READ_PPM exists
;   Alladin GhostScript 3.53 or better (to write 'good' ppm files?)
;
; CAVEAT EMPTOR:
;   You get the color table you get.  It may or may not be a useful 
;   one.  In fact the odds are seriously against you. 
;
; HISTORY:
;    26-Mar-96 - (BNH) - Written
;    10-Apr-96 - (BNH) - Check for IDL V4.0.1 or better and GhostScript
;			 V3.53 or better
;                      - Added 'Requirements'
;    29-Apr-97 - (MDM) - Renamed from READ_PS to READ_PS_GS
;-

spawn, '/usr/local/bin/gs -v', gs_version
gs_version = (str_sep(gs_version(0), ' '))(2)

if (!version.release lt '4.0.1') then begin
   message, /info, 'IDL version too old.  You need at least V4.0.1.'
   return, -1
endif

if (gs_version lt '3.53') then begin
   message, /info, "GhostScript won't work, need Alladin 3.53 or better."
   return, -1
endif

if (n_elements(img_file) eq 0) then begin
    message, 'img = READ_PS(image_filename, r, g, b)'
    return, -1
endif

temp=findfile(img_file, count=count)
if (count eq 0 ) then begin
    print, 'File "', img_file, '" not found -- exiting...'
    return, -1
endif
;
; Note I had to slap on the 'quit.ps' at the end to get gs
; to finish.  This seems barbaric.
;
spawn, '/usr/local/bin/gs -sDEVICE=ppmraw -q -dNOPAUSE '+  $
       '-sOUTPUTFILE=/tmp/idl.ppm ' + img_file + ' quit.ps'

read_ppm, '/tmp/idl.ppm', ppm_image

;
;  COLOR_QUAN:  turns a true-color image into whatever it is
;  we want.  The '1' argument generates the appropriate interleaving.
;
return, color_quan(ppm_image, 1, r, g, b, colors=255)

end

