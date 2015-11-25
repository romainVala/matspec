function plot_lcmodel_result(r,field_name)

if ~exist('field_name')
  field_name={'gaba_cor','naa_cor','glu_cor'};
  %field_name2={'SDgaba','SDnaa','SDglu'};
end


%w1_r = r(1).water_real.*29000000000;
%w2_r = r(2).water_real.*29000000000;
legend_str = {r(1).pool,r(2).pool};

for k=1:length(field_name)
  y1 = getfield(r(1),field_name{k});
  y2 = getfield(r(2),field_name{k});

%  sd1 = getfield(r(1),field_name2{k});
%  sd2 = getfield(r(2),field_name2{k});

  title_str = [field_name{k}];
%  title_str2 =[field_name2{k}];
  
%  plot2(y1,y2,sd1,sd2,legend_str,title_str,title_str2)

  x1 = r(1).fwhite;
  x2 = r(2).fwhite;
  x1 = r(1).fgray;
  x2 = r(2).fgray;
  
  [a1,b1,xx1,yy1]= fit_ax_b(x1,y1);
  [a2,b2,xx2,yy2]= fit_ax_b(x2,y2);
  
  figure;hold on
  
  plot(xx1,yy1)
  plot(xx2,yy2,'r')

  title([title_str])
  lh = legend(legend_str);

  plot(x1,y1,'x')
  plot(xx2,y2,'xr')

end


% y1 = r(1).gaba ./ r(1).water_real.*29000000000;
      % y1 = r(1).gaba ./ r(1).water_abs.*290000000000;
% y2 = r(2).gaba ./ r(2).water_real.*29000000000;
      % y2 = r(2).gaba ./ r(2).water_abs.*290000000000;
% legend_str = {r(1).pool,r(2).pool};
% title_str = 'gaba/water';

% sd1 = r(1).water_width;
% sd2 = r(2).water_width;
% title_str2 = 'water_width';
% plot2(y1,y2,sd1,sd2,legend_str,title_str,title_str2)

% if isfield(r(1),'water_content') 
%   sd1 = r(1).water_content;
%   sd2 = r(2).water_content;
%   title_str2 = 'water_content';
% 
%   plot2(y1,y2,sd1,sd2,legend_str,title_str,title_str2)
%end
 
% y1 = r(1).gaba ./ r(1).naa;
% y2 = r(2).gaba ./ r(2).naa;
% legend_str = {r(1).pool,r(2).pool};
% title_str = 'gaba/naa';

 %sd1 = r(1).SDgaba;
 %sd2 = r(2).SDgaba;
 %title_str2 = 'SDgaba';
 %plot2(y1,y2,sd1,sd2,legend_str,title_str,title_str2)


function plot2(y1,y2,sd1,sd2,legend_str,title_str,title_str2)

  figure
  sh1 =  subplot(2,1,1);
  hold on
  
  coll = {'g','r','--','-.'};

  plot(y1,coll{1})
  plot(y2,coll{2})
  plot(y1,[coll{1},'x'])
  plot(y2,[coll{2},'x'])
  
  xl=get(gca,'xlim');
  aa1=mean(y1);
  aa2=mean(y2);
  plot(xl,[aa1 aa1],coll{1})
  plot(xl,[aa2 aa2],coll{2})

  lh = legend(legend_str);

  [h p ]=ttest2(y1,y2,0.95,'both','unequal');

  title([title_str,'  P=',num2str(p)])

  sh2 = subplot(2,1,2);
  hold on
  
  plot(sd1,coll{1})
  plot(sd2,coll{2})
  plot(sd1,[coll{1},'x'])
  plot(sd2,[coll{2},'x'])
  
  set(sh1,'position',[0.07    0.4    0.90    0.55])
  set(sh2,'position',[0.07    0.05    0.90    0.25])
  set(lh,'position', [0.7786    0.8733    0.1921    0.1222])
  title(title_str2)

