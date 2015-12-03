% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - corrSeqPhase
% AUTHOR: pjb
% CREATED: 7/8/2003
% DESCRIPTION: This is kindof a hack. The laser_breast_1 sequence produces
% a zero-order phase which varies with TE due to a timing error and the use
% of inappropriate rcvron() statements. Plus, eddy currents create a
% phi(TE) which is reasonably repeatable from one acquisition to the next.
% So, I've acquired spectra from water phantoms and measured phi(TE). After
% averaging many together, I have a reference phi(TE) which can be used to
% correct this known problem.
% This is not a good way to correct phase - individual phasing is
% preferable - but if there's not enough SNR this is the only way. Its much
% better than using no phase correction, becuase phi varies pi over
% 45-200ms. 
% I padded the ref spectrum, so for TE<45ms, it uses phi(45), and for
% TE>400ms it uses phi(400).
%
% Note I haven't done this for LB3 yet. There's not phi(TE) due to sequence
% problems, but the eddy-current produced phi(TE) might be worth
% correcting.
% ARGUMENTS: mbsSpectrum 
% RETURNS: mbsSpectrum, phase corrected if possible
% MODIFICATIONS:
% ****************************************************************************** 

function [sp, phi_corr] = corrSeqPhase(sp)


seqfil = get(sp, 'seqfil');
if (strcmp(seqfil, 'laser_breast_1') == 1)
    
    te = get(sp,'te');
    
    % Load the reference phase, in radians
    phi_te_ref = load('phi_te_ref_lb1.txt');
    
    % Interpolate to get the appropriate phases
    phi_corr = interp1(phi_te_ref(:,1), phi_te_ref(:,2), te);
    
    % Correct
    sp = phaseSpec(sp, phi_corr.*(180/pi));
    
elseif (strcmp(seqfil, 'laser_breast_3') == 1)
    
    te = get(sp,'te');
    
    % Load the reference phase, in radians
    phi_te_ref = load('phi_te_ref_lb1.txt');
    
    % Interpolate to get the appropriate phases
    phi_corr = interp1(phi_te_ref(:,1), phi_te_ref(:,2), te);
    
    % Correct
    sp = phaseSpec(sp, phi_corr.*(180/pi));
    
else
    disp('corrSeqPhase: no phase correction');
% else, no correction    
end
    








