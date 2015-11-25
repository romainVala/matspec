function [T1 S0] = find_T1(f)

for k=1:length(f)
  tr(k) = f(k).TR/1000;
  
  y1(k) = f(k).integral_real;
  y2(k) = f(k).integral_real_all;  
  y3(k) = f(k).integral_abs;
  
end

[v,i] = max(tr);


v0(1) = y1(i);   % S0 start point
v0(2) = 1000;    % T1 start point of the fit

vE=nlinfit(tr,y1,@T1_decay,v0);
 
T1(1) = vE(2);
S0(1) = vE(1);
 

v0(1) = y2(i);   % S0 start point
v0(2) = 1000;    % T1 start point of the fit

vE=nlinfit(tr,y2,@T1_decay,v0);
 
T1(2) = vE(2);
S0(2) = vE(1);
 

v0(1) = y3(i);   % S0 start point
v0(2) = 1000;    % T1 start point of the fit

vE=nlinfit(tr,y3,@T1_decay,v0);
 
T1(3) = vE(2);
S0(3) = vE(1);
 