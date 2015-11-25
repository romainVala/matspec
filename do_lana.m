
clear all

load('/servernas/images2/romain/data/spectro/PROTO_SPECTRO_DYST/ALL_average.mat')


%m=explore_spectro_data;
%m.spectrum.ppm_center=4.695;
%mc=processing_MEGA(m);     

%mref=explore_spectro_data;

%clear all
%load('/home/romain/dvpt/spectro/fit_Lana/g_20080118_ExpS9_.mat')
%clear y_no y_yes

global ywat Q_NO Q_YES sw sfrq  %met_noc met_yesc wat_refc timeD y_yes y_no
global db_off db_on met_list mm_no mm_yes mm_spec_info
global MM_on T2_fact


load gabadb
    
for nbg = 1:length(fall)
  
  for nbs = 1:length(fall(nbg).group)
    
    fid = fall(nbg).group(nbs).fid;
    specinfo = fall(nbg).group(nbs).spectrum;

%    ns = size(fid,2)/2;
%    Q_NO  = sum(fid(:,1:ns),2)'; 
%    Q_YES = sum(fid(:,(ns+1):end),2)';

    Q_NO  = (fid(:,1))' .* 128; 
    Q_YES = (fid(:,2))' .* 128;

    ywat = fall(nbg).group(nbs).water_ref.fid';

    sfrq = specinfo.cenfreq;
    sw =  specinfo.SW_h;

    MM_on=0;

    T2_fact =1;

    % --- Executes on button press in pushbutton_RefDec.
    g_total2;
 
    fit_water 
    fit_gaba
    fit_NAA
    fit_MM

    T2_fact =1.2;
 
    MM_on=1;
    fit_gaba
    
    save_fit
    
    close all
    
  end
end
