

;c_statistic.pro

function c_statistic,f_obs,f_mod,            $
                     F_MOD_MIN=f_mod_min,    $
                     CHISQ=chisq,            $
                     NN=NN,        			 $
                     EXPECTATION=expectation
;+
;
; PURPOSE:
;      To provide a goodness-of-fit statistic valid for very low countrates
;      e.g., counts/bin < 10  (Webster Cash, AP.J., 1979)
;
; INPUTS:
;      f_obs = array of integer counts
;      f_mod = same size array of positive model counts (likely
;      non-integer)
;
; Keywords:
;
;	   F_MOD_MIN: If f_mod is not positive everywhere, one can set a minimum
;      allowed value using the f_mod_min keyword.
;      CHISQ; if set, the chi-squared statistic for Poisson
;      distributed f_obs will be returned.
;
;      EXPECTATION: if set to an existing variable, the expected
;      C-statistic will be returned in it.
;      NN: This will return the number of valid pts where f_mod gt 0
;
; NOTES:
;      If f_mod and f_obs form the best possible match, cash_statistic
;      will have a local minimum (which may be <1 or > 1).  This is
;      not true for chi-squared when counts/bin < 10.
;      If counts/bin >> 10, cash_statistic = Chisquared
;	   F_mod eq 0 rejected if f_mod_min not set gt 0
;	   F_mod lt 0 causes warning if f_mod_min not set ge 0, only f_mod gt 0 used
;
; HISTORY:
;      EJS April 19, 2000
;      W. Cash Ap.J., 1979
;      EJS May 1, 2000 -- FLOATED f_mod to prevent f_obs/f_mod
;                         becoming zero if f_obs and f_mod both INTEGER.
;      EJS Jun 6, 2000 -- Added option to get expectation of C-statistic
;      Kim, Mar 4, 2005 -- Uploaded to SSW
;	   6-oct-2010, richard.schwartz@nasa.gov, added some protections to the inputs so
;		they'll remain unchanged.  combined some terms on the computation
;		of the Cash (c) statistic, Only printing warning for negative f_mod
;-

x_mod =float(f_mod) ;Use x_mod internally because it's bad to modify inputs
if keyword_set(f_mod_min) then   x_mod=x_mod>(f_mod_min)

if (where(x_mod lt 0))[0] ne -1 then $
 message,/continue, 'f_mod must be gt 0!, some values lt 0. Evaluating only for positive f_mod!!!!'
z = x_mod *0.0
x_obs = f_obs
wnz = where( x_mod gt 0, nn) ;number of valid elements, expected cts le 0 don't count
if nn ne n_elements(x_mod) then begin
	x_obs = x_obs[wnz]
	x_mod = x_mod[wnz]
	endif
if keyword_set(chisq) then begin
 z_chi2=(x_obs-x_mod)^2/x_mod
 statistic=avg(z_chi2)
 nn = n_elements(x_obs)
endif else begin
;Revised from the EJS coding for enhanced efficiency
;Old coding follows
; z_cash=(2./NN)*f_mod
; w=where(f_obs NE 0)
;
; z_cash(w)=(2./NN)*(f_obs(w)*alog(f_obs(w)/f_mod(w))+f_mod(w)-f_obs(w))
; statistic=total(z_cash)
;RAS coding is used now:
 statistic = total(x_mod - x_obs)
 w=where(x_obs NE 0 )
 x_obs = x_obs[w]
 statistic= (2./NN)*(statistic + total( x_obs*alog(x_obs/x_mod[w])))
 endelse

if n_elements(expectation) GT 0 then expectation=c_expected(x_mod)

return,statistic

end

