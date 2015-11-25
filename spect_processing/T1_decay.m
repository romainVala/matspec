function [y]=T1_decay(v,x)
S0=v(1);
T1=v(2);

y=S0*(1-exp(-x/T1));

