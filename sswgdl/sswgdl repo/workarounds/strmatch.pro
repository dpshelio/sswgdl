function strmatch, string, searchstring, $
	 fold_case=fold_case

match = bytarr(n_elements(string))
help, string, searchstring
print, string, searchstring
;help, /trace
ones  = wc_where( string, searchstring, case_ignore=fold_case, nmatch)
if nmatch ge 1 then match[ones] = 1b

return, match
end
