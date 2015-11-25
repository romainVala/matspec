function y = double_exp(in,TE)

Ab=in(1);
T2b = in(2);
Acsf = in(3);
T2csf = in(4);

y = Ab * exp(-TE/T2b) + Acsf * exp(-TE/T2csf);