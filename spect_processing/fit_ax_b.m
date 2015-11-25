function [a,b,xfit,yfit,fit_error] = fit_ax_b(x,y,doplot)

if ~exist('doplot') , doplot=0;end

%remove inf


var_x = repmat ( sum((x-mean(x)).^2)/size(y,2), size(y,1),1);
cv=sum( repmat(x-mean(x),size(y,1),1) .* (y-repmat(mean(y,2),1,size(y,2)) ),2 )/size(y,2);

a=cv./var_x;

b=mean(y,2)-a*mean(x);


if nargout>2
  [xfit,i] = sort(x);

  yfit = a.*xfit + b;
  
  fit_error = sqrt(sum((a*x+b - y).*(a*x+b - y))) ; 
end

if doplot
figure

plot(x,a.*x+b)
hold on
plot(x,y,'r+')

end

