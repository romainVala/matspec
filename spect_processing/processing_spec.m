function [spec_cor] = processing_spec(fid_struct,par)
% fid_struct_cor = processing_spec(fid_struct,par)
% fid_struct is the matlab fid structure (output of explore_spectro_data.m,
% reading the raw dicom files)
% fid_struct_cor is the output containing the corrected fid
%
%       par = processing_spec will return the default parameter values used
%       for frequency and phase correction. Different values manage parameters for correction.
%
% par.method : 'max' or 'correlation'  
%   'max' : the maximum amplitude of each spectrum will be adjusted to the
%           reference. the phase at this maximum will be set to zero.
%    'correlation': the frequency and phase of each spectrum will be
%           adjust so that the correlation with the first spectrum is optimal.
%   Defaul is 'max'.
%
% par.do_freq_cor : if 0, frequency correction will not be performed.
%   Default value is 1.
%
% par.do_phase_cor : if 0, phase correction will not be performed.
%   Default value is 1.
%
% par.mean_line_broadening : This is the linebroadening
%   applied to the fid before frequency correction is performed. Note that the
%   correction is then applied to the original fid (whithout linebroadening).
%   Note that in addition to this linebroadening, a zero filling of order
%   10 is applied. 
%   Default value is 5.
%
% par.correct_to_ref_metab : Only applies to the 'correlation' method. After
%   the frequency correction of each spectrum, a global frequency
%   correction on the mean spectrum with the max method is performed. If 0,
%   this global correction is not performed. 
%   Default value is 1.
%
% par.ref_metab : the name of the reference peak (and the search bound to
%   find the maximum) see help get_peak_bound.  Used by the max method and the correlation 
%   method if par.correct_to_ref_metab is 1. 
%   Default is 'NAA'.
% 
% par.correct_freq_mod : 'real' or 'abs'
%   It only applies to the 'max' method. Allows one to choose to perform corrections 
%   in absolute value or real mode of the spectrum. 
%   Default is 'real'.
%
% par.figure : creates plots of spectra. If 0, no plot will be created. 
%   Default is 1.
%
% par.stop_if_warning : applies to the 'max' method only. If set to 1, it will
%   produce a matlab error when the min or the max of the search bound is 
%   reached. If 0, it will only give a warning message (and a plot). 
%   When this happens, this means that the algorithm did
%   not find a real maximum of the peak => need to adjust the search
%   bound or to increase the linebroadening or if the spectra are still too
%   noisy sum them localy with the sum_fid_local.
%   Default value is 0.

% Romain (2013) 

if ~exist('par'), par='';end

if ~isfield(par,'method'), par.method = 'max';end % max or correlation
if ~isfield(par,'do_freq_cor'), par.do_freq_cor=1;     end
if ~isfield(par,'do_phase_cor'), par.do_phase_cor=1;     end

if ~isfield(par,'mean_line_broadening'),par.mean_line_broadening=5; end
if ~isfield(par,'correct_to_ref_metab'),par.correct_to_ref_metab =1; end

if ~isfield(par,'ref_metab'),   par.ref_metab = 'NAA'; end
if ~isfield(par,'correct_freq_mod'),   par.correct_freq_mod='real'; end % or 'abs'

%if ~isfield(par,'')

if ~isfield(par,'figure'), par.figure=1;     end

if ~isfield(par,'stop_if_warning'), par.stop_if_warning = 0; end


if nargin==0
    spec_cor=par;
    return
end


spec_cor = fid_struct;

for nb_spec = 1:length(fid_struct)
    
    ppm_center = fid_struct(nb_spec).spectrum.ppm_center;	% receiver (4.7 ppm)
    %magfield   = fid_struct(nb_spec).spectrum.magfield;	% magnetic field (2.8936 T)
    %cenfreq    = fid_struct(nb_spec).spectrum.cenfreq;	% center frequency of acquisition in Hz
    SW_h       = fid_struct(nb_spec).spectrum.SW_h;	% spectral width in Hz
    SW_p       = fid_struct(nb_spec).spectrum.SW_p;	% spectral width in ppm
    %np         = fid_struct(nb_spec).spectrum.np;		% number of points
    %dw         = fid_struct(nb_spec).spectrum.dw;		% dwell time
    %zero_filling = np;
    
    fid = fid_struct(nb_spec).fid;
    
    fid2 = permute(fid,[2 1]);
    
    % performing frequency and phase correction
    
    switch par.method
        case 'toolbox'
            [sum2 fid_cor] = add_array_scans(fid2,SW_h,SW_p,ppm_center);
        
        spec_cor(nb_spec).fid = permute(fid_cor,[2 1]) ;
        
        case 'correlation'
        [fid_cor phase_cor freq_cor ] = correct_freq_and_phase_by_correlation(fid,par,fid_struct(nb_spec));
        spec_cor(nb_spec).fid = fid_cor;

      
        case 'max'
        
        %[sum2 fid_cor phase_cor freq_cor ] = add_array_scans_bis_Cre(fid2,SW_h,SW_p,ppm_center,par,fid_struct(nb_spec));
        [fid_cor phase_cor freq_cor ] = correct_freq_and_phase_by_max(fid2,par,fid_struct(nb_spec));
        freq_cor(end-2:end)='';
        spec_cor(nb_spec).fid = permute(fid_cor,[2 1]) ;
    end
    
    
    if exist('phase_cor','var')
        spec_cor(nb_spec).phase_cor = phase_cor'; end
    if exist('freq_cor','var')
        spec_cor(nb_spec).freq_cor =  freq_cor';end
    
    
    
end



