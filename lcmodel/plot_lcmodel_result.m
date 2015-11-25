function varargout = plot_lcmodel_result(r,field_list,par)


if ~exist('par')
  par.scale_to_pool_mean = 0;
  par.same_fig =0;
  par.xshift = 0.2;
  par.markersize = 6;
  par.markerstring = 'o';
  par.dottest = 0;
  par.ylim='';
  par.ygrid=0;
  par.xgrid=0;
  par.save_dir='';
  par.ind_group='';
end

if nargin==0
  varargout{1}=par;
  return
end

if ~exist('field_list')
  field_list = fieldnames(r);
  field_list = find_metab_list(field_list);
end

if ~iscell(field_list)
  field_list = {field_list};
end

if iscell(r)
  
  rr = concat_conc(r{1},r{2},['m' num2str(2)] );
  for kc = 3:length(r)
    rr = concat_conc(rr,r{kc},['m' num2str(kc)] );
  end
  
  for nf=1:length(field_list)
    field_comp = field_list(nf);
    for kc = 2:length(r)
      field_comp = [field_comp,{[ 'm' num2str(kc) field_comp{1}]}];
    end
    
    par.same_fig =1;
    plot_lcmodel_result(rr,field_comp,par)
    
  end

  return
  
end

for npool = 1:length(r)

  for nf=1:length(field_list)

    y1 = getfield(r(npool),field_list{nf});
    y1(isnan(y1))=[];

    ALLmean{nf}(npool) =  mean(y1);
    ALLstd{nf}(npool) = std(y1);
    Allvalue{nf}{npool} = y1;
    
  end
end

if par.scale_to_pool_mean==1
  for nf=1:length(field_list)
    scale_mean(nf) = mean(ALLmean{nf});
  end

  for nf=1:length(field_list)
    ALLmean{nf} =  ALLmean{nf} ./ scale_mean(nf);
    ALLstd{nf}  =  ALLstd{nf}  ./ scale_mean(nf); 
    for npool = 1:length(r) 
      Allvalue{nf}{npool} =  Allvalue{nf}{npool} ./ scale_mean(nf);
    end
  end

elseif par.scale_to_pool_mean==2

  for nf=1:length(field_list)

    for npool = 1:length(r) 
      Allvalue{nf}{npool} =  Allvalue{nf}{npool} ./ mean(Allvalue{nf}{npool});
      
      ALLmean{nf}(npool) =  mean(Allvalue{nf}{npool});
      ALLstd{nf}(npool) = std(Allvalue{nf}{npool});

    end
  end

end



for npool = 1:length(r)

  
  nn=r(npool).pool;
  %pool name correction
  if findstr('control',nn)
    i=findstr('control',nn);    nn([i])= 'c';    nn([i+1:i+6])= '';
  end
  if findstr('patient',nn)
    i=findstr('patient',nn);    nn([i+1:i+6])= '';
  end
  
  i = findstr('_',nn);
  nn(i)='';
  
  name{npool} = nn;
    
end
  
if par.same_fig
  par.ymin=inf;par.ymax=-inf;
  
  for nf=1:length(field_list)
    for nbp=1:length(Allvalue{nf})
      par.ymin = min(par.ymin,min(Allvalue{nf}{nbp}));
      par.ymaw = max(par.ymax,max(Allvalue{nf}{nbp}));
    end
  end
  
end

for nf=1:length(field_list)
  par = myfig(ALLmean{nf},ALLstd{nf},name,field_list{nf},Allvalue{nf},par);

end

  
%*****************************************************************************

function par = myfig(y,e,name,titre,ALL,par)
 
all_color=[0 0 1;0 1 0;1 0 0;0 1 1];
 
if par.same_fig
  if isfield(par,'arg_give_me_a_new_one')
    figure(par.arg_give_me_a_new_one)
    par.nr_of_plot = par.nr_of_plot + 1;

  else
    par.arg_give_me_a_new_one=figure();
    par.nr_of_plot = 1;
  end
else
  figure
  par.nr_of_plot = 1;
end

if ~isempty(par.ylim)
  ylim(par.ylim)
end

curent_color = all_color(par.nr_of_plot,:);

hold on
xx = (1:length(y)) + (par.nr_of_plot-1)*par.xshift;
h = errorbar(xx,y,e);

set(h,'color',curent_color)

tt=titre; if findstr(tt,'_'), tt(findstr(tt,'_'))=' ';end
title(tt);
set(gcf,'Name',tt)

set(gca,'XTick',[1:length(y)],'XTickLabel',name)

%set(gcf,'Position',[985   335     1571   613])
set(gcf,'Position',[(10 + 10*par.nr_of_plot) (10-2*par.nr_of_plot) 1200 600])
%set(gca,'Position',[0.0324    0.0621    0.9566    0.8784])


xlim([0 length(y)+1]);
%grid on

for npool=1:length(ALL)
  xx=ones(length(ALL{npool}),1)*npool + (par.nr_of_plot-1)*par.xshift;
  h =  plot(xx,ALL{npool},par.markerstring);

  set(h,'color',curent_color,'markersize',par.markersize);

end

if (~isempty(par.ind_group))
  ind_red=5;
  for ii = 1:size(par.ind_group,1)
    y1 = ALL{par.ind_group(ii,1)};
    y2 = ALL{par.ind_group(ii,2)};
    if ii==2 , ind_red=4; end
    for k=1:length(y1)
      if k<=ind_red
	plot([par.ind_group(ii,1) par.ind_group(ii,2)],[y1(k) y2(k)],'r')
      else
	plot([par.ind_group(ii,1) par.ind_group(ii,2)],[y1(k) y2(k)],'g')
      end
    end
  end
  
end

if par.ygrid
  set(gca,'ygrid','on')
end
if par.xgrid
  set(gca,'xgrid','on')
end

if par.dottest
  for nc = 1:length(name)/2
    y1 = ALL{2*nc-1};
    y2 = ALL{2*nc};
      
    [h,p]=ttest2(y1,y2,0.1,'right','unequal');
      
    if ~h
      [h,p]=ttest2(y1,y2,0.1,'left','unequal');
    end
	
    if h

      xpos = 2*nc-1 + (par.nr_of_plot-1)*par.xshift;
      ylimm = get(gca,'Ylim');
      ypos = ylimm(1) + diff(ylimm)*0.05;
      ypos = ypos + (par.nr_of_plot-1)*diff(ylimm)*0.05 ;
      ypostext = ypos + diff(ylimm)*0.025;
      
      if p>0.05 
	h = plot([xpos xpos xpos+1 xpos+1],[ylimm(1),ypos,ypos,ylimm(1)],':');
      else
	h = plot([xpos xpos xpos+1 xpos+1],[ylimm(1),ypos,ypos,ylimm(1)]);
      end
      
      set(h,'color',curent_color);
      h = text(xpos,ypostext,sprintf('P=%0.4f',p));
      set(h,'color',curent_color);
    end
    
  end
  
end

if ~isempty(par.save_dir)
  
  set(gcf,'PaperPositionMode', 'auto') 

  print( gcf, '-djpeg100',titre)
end
  