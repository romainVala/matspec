function [bound,ibound] = get_ppm_bound_for(metab,SW_p,nb_pts,ppm_center)
%bound(1) lower bound for metab peack in ppm
%bound(2) reference ppm  for metab peack in ppm 
%bound(3) uper bound for metab peack in ppm
%ibound value of bound transform in frequency

switch metab
  case 'CRE'
    bound(1) = 2.9;
    bound(2) = 3.1;
    bound(3) = 3.02;
  case 'NAA'
    bound(1) = 1.8;
    bound(2) = 2.2;
    bound(3) = 2.01;
end    
    

ibound(1) = round(- (bound(3)-ppm_center)*nb_pts/SW_p + nb_pts/2 ) + 1;
ibound(2) = round(- (bound(2)-ppm_center)*nb_pts/SW_p + nb_pts/2 ) ;
ibound(3) = round(- (bound(1)-ppm_center)*nb_pts/SW_p + nb_pts/2 ) ;
