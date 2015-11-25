function p = tcdf(x,v)
%TCDF   Student's T cumulative distribution function (cdf).
%   P = TCDF(X,V) computes the cdf for Student's T distribution
%   with V degrees of freedom, at the values in X.
%
%   The size of P is the common size of X and V. A scalar input
%   functions as a constant matrix of the same size as the other input.
%
%   See also TINV, TPDF, TRND, TSTAT, CDF.

%   References:
%      [1] M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.7.
%      [2] L. Devroye, "Non-Uniform Random Variate Generation",
%      Springer-Verlag, 1986
%      [3] E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, 1970, Section 10.3, pages 144-146.

%   Copyright 1993-2007 The MathWorks, Inc.
%   $Revision: 2.12.4.6 $  $Date: 2007/05/23 19:16:13 $

normcutoff = 1e7;
if nargin < 2,
    error('stats:tcdf:TooFewInputs','Requires two input arguments.');
end

[errorcode x v] = distchck(2,x,v);

if errorcode > 0
    error('stats:tcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P.
if isa(x,'single') || isa(v,'single')
    p = NaN(size(x),'single');
else
    p = NaN(size(x));
end

nans = (isnan(x) | ~(0<v)); %  v==NaN ==> (0<v)==false

% First compute F(-|x|).
%
% Cauchy distribution.  See Devroye pages 29 and 450.
cauchy = (v == 1);
p(cauchy) = .5 + atan(x(cauchy))/pi;

% Normal Approximation.
normal = (v > normcutoff);
if any(normal(:))
   p(normal) = normcdf(x(normal));
end

% See Abramowitz and Stegun, formulas 26.5.27 and 26.7.1
gen = ~(cauchy | normal | nans);
if any(gen(:))
    gen = find(gen);
    t = (v(gen) < x(gen).^2);
    if any(t)
        % For small v, form v/(v+x^2) to maintain precision
        tg = gen(t);
        p(tg) = betainc(v(tg) ./ (v(tg) + x(tg).^2), v(tg)/2, 0.5)/2;
        xpos = (x(tg)>0);
        if any(xpos)
            p(tg(xpos)) = 1-p(tg(xpos));
        end
    end
    
    t = (v(gen) >= x(gen).^2);
    if any(t)
        % For large v, form x^2/(v+x^2) to maintain precision
        tg = gen(t);
        p(tg) = 0.5 + sign(x(tg)) .* ...
                betainc(x(tg).^2 ./ (v(tg) + x(tg).^2), 0.5, v(tg)/2)/2;
    end
end
% Make the result exact for the median.
p(x == 0 & ~nans) = 0.5;
