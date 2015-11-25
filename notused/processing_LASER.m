% matlab software to read in and process siemens spectroscopy data acquired using LASER sequence 
% written by Malgorzata Marjanska with help from Julien Valette and Eddie Auerbach
% september 17, 2007
% other small programs used: spec_read, spec_read_all, parse_siemens_shadow (c_str.m, parse_mrprot.m), add_array_scans (cout_nu.m, cout_phase.m),
% add_array_scans_bis, createrawfile_mm_3T_CENIR.m 
% final data is saved either as .mat (matlab format) or .RAW (LCModel format)

% flag_toolbox = 'y' - add_array_scans is used and toolbox with lsqnonlin to perform frequency and phase correction
%		'n' - add_array_scans_bis is used, and frequency and phase corrections are based on NAA peak
% red - original data, blue - data after correction

function y=processing_LASER(file_name,flag_toolbox)

% reading in data and parameters

[fid, spec_info]=spec_read_all(file_name); 			% reading in the data
[imghdr,serhdr,mrprot]=parse_siemens_shadow(spec_info(1)); 	% getting information from Siemens file
ppm_center = 4.7; 						% receiver (4.7 ppm)
magfield = mrprot.sProtConsistencyInfo.flNominalB0;		% magnetic field (2.8936 T)
cenfreq = mrprot.sTXSPEC.asNucleusInfo(1).lFrequency/1000000;	% center frequency of acquisition in Hz
SW_h=1e9/(serhdr.ReadoutOS * mrprot.sRXSPEC.alDwellTime(1));	% spectral width in Hz
SW_p=SW_h/cenfreq;						% spectral width in ppm
np=mrprot.sSpecPara.lVectorSize;				% number of points
dw=1/(SW_h);							% dwell time								
rp=0;								% zero order phase correction - LCModel
lp=0;								% first order phase correction - LCModel

fid2 = transpose(fid);

% performing frequency and phase corrections
if flag_toolbox=='n'
	sum= add_array_scans_bis(fid2,SW_h,SW_p,ppm_center);
else
	sum=add_array_scans(fid2,SW_h,SW_p,ppm_center);
end

% saving corrected spectra in .mat, .RAW formats

%eval(['save ' file_name ' sum']);				% creates .mat file
%sum=transpose(sum);
%sum=[real(sum) imag(sum)];
%createrawfile_mm_3T_CENIR('./',file_name,sum,cenfreq,np,dw,rp,lp); % creates .RAW and .PLOTIN files - LCModel

