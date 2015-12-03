% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - plotFid
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Plots the summed fid
% ARGUMENTS: mbsSpectrum
% RETURNS: none
% MODIFICATIONS:
% ****************************************************************************** 
function plotFid(sp)

% Plots the summed FID with lines indicating +/- sigma
sp = average(sp);

plot(sp.time * 1000, imag(sp.fid),'r',...
    sp.time * 1000, real(sp.fid),'b');

% The noise calcs are way wrong
% [snr noiserms maxsig] = getSnrTd(sp);
% 
% plot(sp.time * 1000, sp.time.*0 + noiserms,':k',...
%     sp.time * 1000, sp.time.*0 - noiserms,':k', ...
%     sp.time * 1000, imag(sp.fid),'r',...
%     sp.time * 1000, real(sp.fid),'b');
xlabel('Time (ms)');

