function [f_METAB_inf,f_METAB_sup,f_METAB_ref] = get_peak_bound(type)
%[f_METAB_inf,f_METAB_sup,f_METAB_ref] = get_peak_bound(par)
% it will return the search bound around a reference in ppm for a peak name given by
% par.ref_metab. possible values ar 'NAA' 'CRE' 'CRE_2' 'CRE_SMALL' ...
% alternatively you can diretly specify the bound and the reference by choosing :
%   par.ref_metab  = 'USER';
%   par.METAB_inf=2.9;
%   par.METAB_sup = 3.1;
%   par.METAB_ref = 3.02;
    
if isstruct(type)
  par=type;
  type = par.ref_metab;
  
end


switch type
  
  case 'USER'
    f_METAB_inf = par.METAB_inf;
    f_METAB_sup = par.METAB_sup;
    f_METAB_ref = par.METAB_ref
    
  case 'CRE'

    f_METAB_inf=2.8; % lower bound for the Cre peak, in ppm
    f_METAB_sup=3.32; % upper bound for the Cre peak, in ppm
    f_METAB_ref=3.02;

  case 'CRE_SMALL'

    f_METAB_inf=2.9; % lower bound for the Cre peak, in ppm
    f_METAB_sup=3.10; % upper bound for the Cre peak, in ppm
    f_METAB_ref=3.02;

  case 'CRE_SMALL2'

    f_METAB_inf=2.9; % lower bound for the Cre peak, in ppm
    f_METAB_sup=3.15; % upper bound for the Cre peak, in ppm
    f_METAB_ref=3.02;
  
  case 'CRE_SMALL3'

    f_METAB_inf=2.9; % lower bound for the Cre peak, in ppm
    f_METAB_sup=3.05; % upper bound for the Cre peak, in ppm
    f_METAB_ref=3.02;
  
  case 'CRE_2'

    f_METAB_inf=3.6; % lower bound for the Cre peak, in ppm
    f_METAB_sup=4.2 % upper bound for the Cre peak, in ppm
    f_METAB_ref=3.93;

 case 'CRE_22'

    f_METAB_inf=3.8; % lower bound for the Cre peak, in ppm
    f_METAB_sup=4.1; % upper bound for the Cre peak, in ppm
    f_METAB_ref=3.9;

  case 'H2O'
    
    f_METAB_inf=4; 
    f_METAB_sup=5.4; 
    f_METAB_ref=4.7;

  case 'NAA'
    
    f_METAB_inf=1.65; %1.25
    f_METAB_sup=2.25 ;%35;%2.3
    f_METAB_ref=2.01;

case 'NAA2'
    f_METAB_inf=1.15;
    f_METAB_sup=2.55;
    f_METAB_ref=2.01;


  case 'FORMATE'
    
    f_METAB_inf=8.4;
    f_METAB_sup=8.5;
    f_METAB_ref=8.44;
  
  case 'MM'
    
    f_METAB_inf=0.8;
    f_METAB_sup=1.1;
    f_METAB_ref=0.95;
    
    
  case 'zero'

    f_METAB_inf=-0.05;
    f_METAB_sup=0.05;
    f_METAB_inf=-0.4;
    f_METAB_sup=0.3;
    f_METAB_ref=0;
   
  case 'water'
    f_METAB_inf=4; % lower bound for the Cre peak, in ppm
    f_METAB_sup=8; % upper bound for the Cre peak, in ppm
    f_METAB_ref=4.67;

end
%f_inf3=2.5; % lower bound for zero-phasing the SUM, in ppm
%f_sup3=4; % upper bound for zero-phasing the SUM, in ppm

