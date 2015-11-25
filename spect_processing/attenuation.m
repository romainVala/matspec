function R=attenuation(T1,T2,TR,TE)

if ~exist('TE')
TE=68;
end
if ~exist('TR')
TR = 3000;
end


R = exp(-TE./T2).*(1-exp(-TR./T1));

