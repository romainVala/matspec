function y = single_exp(in,TE)

Ab=in(1);
T2b = in(2);

y = Ab * exp(-TE/T2b) ;