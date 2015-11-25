d=get_subdir_regex('/nasDicom/dicom_raw/STABILITE_SPECTRO/2010_08_04_TEST_STABILITE_E6','VS_SE_WATER_LONG_TR10');
d(1)=[];

f=explore_spectro_data(char(d));

par.ref_metab='water'
fc=processing_spec(f,par)


Xfre=[];xtime=[]
%for k=1:14 %length(fc)
for k=1:length(fc)
    ff = fc(k).freq_cor;
    %ff=(ff-ff(1))./fc(k).spectrum.cenfreq;
    ff=(ff)./fc(k).spectrum.cenfreq;
    Xfre=[Xfre ff];

    if k==1
      nsca(k) = size(fc(k).fid,2);
    else
      nsca(k) = nsca(k-1) + size(fc(k).fid,2);
    end
    
    nbs=size(fc(k).fid,2);

    v=datevec(f(k).acqtime);
    thedate = datestr(f(k).acqtime,29);
    
    tt=v(4)*3600+v(5)*60+v(6);    
    TR = f(k).TR/1000000;
    
    vv = (0:TR:((nbs-1)*TR))+tt ;
    [h,m,s,ms] = get_time(vv);
    
    for kk=1:nbs   
      vstr(kk) =  datenum(sprintf('%s %d:%d:%d',thedate,h(kk),m(kk),s(kk)),'yyyy-mm-dd HH:MM:SS') ;
    end
    
    xtime = [xtime,vstr];
    xtimefirst(k)= vstr(1);
    clear vstr
end

figure
 plot(xtime,Xfre,'.')
 datetick
 
 yl=get(gca,'YLim')
hold on
for k=1:length(nsca)
  plot([nsca(k),nsca(k)],yl,'k')
end
 plot(Xfre)
 yl=get(gca,'YLim')

 
  