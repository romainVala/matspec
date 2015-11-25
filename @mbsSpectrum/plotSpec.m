% ******************************************************************************
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ******************************************************************************
% FUNCTION: mbsSpectrum - plotSpec
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Plots the summed spec
% ARGUMENTS: mbsSpectrum, axis ('h' for Hz, 'ppm')
% RETURNS: none
% MODIFICATIONS:
% ******************************************************************************
function plotSpec(sp, axis, mode)

if nargin > 1 & axis == 'h'
    freqax = sp.freq .* sp.sfrq;
    axlabel = 'Hz';
else
    freqax = sp.freq;
    axlabel = 'ppm';
end

% mode: 0=real, 1=imag, 2=abs, 3=real+imag
if nargin<3
    mode = 0;
end

sp = average(sp);

switch (mode)
    case 0
        plot(freqax, real(sp.spec), 'b');
    case 1
        plot(freqax, imag(sp.spec), 'b');
    case 2
        plot(freqax, abs(sp.spec), 'b');
        
    otherwise
        plot(freqax, real(sp.spec), 'b', freqax, imag(sp.spec), 'g');
end

set(gca,'Xdir','reverse')
xlabel(axlabel);
