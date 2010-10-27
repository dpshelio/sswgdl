function read_ps,img_file,r,g,b,gif=gif,jpeg=jpeg,outdir=outdir, $
   	enlarge=enlarge,pagenum=pagenum,rot=rot
;+
;NAME:
;	READ_PS
;PURPOSE:
;	To convert ps files into gif images.  It uses ImageMagick's convert 
;	program to convert it and then rotates it if the image is Landscape.
;SAMPLE CALLING SEQUENCE:
;	img = read_ps(infil, r, g, b)
;	img = read_ps('idl.ps', enlarge=1.5)
;	img = read_ps('idl.ps', gif='out.gif')
;INPUT:
;	infil	- The Postscript input file name
;OUTPUT:
;	returns the 2-D image
;	r	- the red color table vector
;	g	- the green color table vector
;	b	- the blue color table vector
;OPTIONAL KEYWORD INPUT:
;	gif	- If set, then write out a GIF file
;	outdir	- If set, and /GIF or /JPEG, then write the output
;		  file to this directory
;	enlarge - Blow up the image to make it larger
;	pagenum	- If the Postscript has multiple pages in the file, this
;		  allows the selection of which page.
;NOTES
;	Currently the jpeg option does not work
;METHOD:
;	The ImageMagick executable "convert" must be in one
;	of the "exe" directories searched by SSW_BIN.PRO
;
;	Writes to the /tmp directory 
;HISTORY
;	Written by Dan Goldberg 7-Aug-96
;	 6-Nov-96 (MDM) - Added documentation information
;			- Renamed from READ_PS to READ_PS2
;	29-Apr-97 (MDM) - Renamed from READ_PS2 to READ_PS
;			  (READ_PS was renamed to READ_PS_GS)
;			- Modified to use SSW_BIN to find
;			  the executable (instead of 
;			  $MDI_EXE_DIR)
;			- Corrected the logic to only write
;			  output files if requested
;	25-Jul-97 (MDM) - Added ROT option
;-
new_image = 0b
;
if (n_elements(img_file) eq 0) then begin
    message, 'img = read_ps(image_filename, pagenum=num_page)', /info
    return, 0b
endif

temp=findfile(img_file, count=count)
if (count eq 0 ) then begin
    print, 'File "', img_file, '" not found -- exiting...'
    return, 0b
endif
if keyword_set(pagenum) then num_page=pagenum
;
;
exe_cmd = ssw_bin('convert', found=found)
if (not found) then begin
    print, 'READ_PS: Cannot find executable: convert.  Returning...'
    return, 0b
end
;
if keyword_set(enlarge) then begin
   enlarge_factor=strtrim(fix(enlarge*100),2)
   enlarge_str=enlarge_factor+"%x"+enlarge_factor+"%"
endif
;
for i=0,n_elements(temp)-1 do begin
   break_file,temp(i),log,path,file,extension,version

   if (keyword_set(gif)) then begin
     if (data_type(gif) eq 7) then outfile=gif else outfile = file(i) + '.gif'
   end
   file_ext='.gif'
   temp_file='/tmp/idl.gif'
   if (keyword_set(jpeg)) then begin
     if (data_type(jpeg) eq 7) then outfile=jpeg else outfile = file(i) + '.jpeg'
     file_ext='.jpeg'
     temp_file='/tmp/idl.jpeg'
   end
   ;
   if (n_elements(num_page) eq 0) then begin
	if (keyword_set(enlarge)) then out_comm=[exe_cmd,"-geometry",enlarge_str,temp(i),temp_file] $
				  else out_comm=[exe_cmd,temp(i),temp_file]
	spawn,out_comm,/noshell
	if (keyword_set(jpeg)) then read_jpeg, temp_file, new_image $
	   		       else read_gif, temp_file, new_image, r, g, b
   endif else begin
	if (keyword_set(enlarge)) then out_comm=[exe_cmd,"-geometry",enlarge_str,"+adjoin",temp(i),temp_file] $
				  else out_comm=[exe_cmd,"+adjoin",temp(i),temp_file]
	spawn,out_comm,/noshell
	if (keyword_set(jpeg)) then read_jpeg,temp_file+'.'+strtrim(string((num_page-1)),2), new_image $
			       else read_gif,temp_file+'.'+strtrim(string((num_page-1)),2), new_image, r, g, b
   endelse
   file_delete, temp_file

   ;---- Optionally rotate landscape images
   spawn, ['grep', 'Landscape', temp(i)], results, /noshell
   if (results(0) ne "") then new_image=rotate(new_image,1) 

   if (keyword_set(rot)) then new_image=rotate(new_image,rot)

   ;---- Optionally write out GIF/JPEG
   if (keyword_set(outfile)) then begin
       if (n_elements(outdir) ne 0) then file_name=concat_dir(outdir, outfile) $
				    else file_name=concat_dir(path,   outfile)
       if (keyword_set(jpeg)) then write_jpeg, file_name, new_image $		; what about r,g,b
  			      else write_gif,  file_name, new_image, r,g,b
   end
endfor

return,new_image
end
                                       
