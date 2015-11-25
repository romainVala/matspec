function T2 = find_T2(f)

for k=1:length(f)
  te(k) = f(k).TE/1000;
  
  y1(:,k) = f(k).integral_real;
  y2(:,k) = f(k).integral_real_all;  
  y3(:,k) = f(k).integral_fid_abs;
  
end

[a,b] =  fit_ax_b(te,log(y1));
T2(1,:) = -1./a;

[a,b] =  fit_ax_b(te,log(y2));
T2(2,:) = -1./a;

[a,b] =  fit_ax_b(te,log(y3));
T2(3,:) = -1./a;
