% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - plotSpecArray
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Plots the summed spec, arrayed
% ARGUMENTS: mbsSpectrum, axis ('h' for Hz, 'ppm')
%   plotSpecArray(sp, axis, hoffset, voffset, mode)
% RETURNS: none
% MODIFICATIONS:
% ****************************************************************************** 
function plotSpecArray(sp, axis, hoffset, voffset, mode)
clf
if nargin > 1 & axis == 'h'
    freqax = sp.freq .* sp.sfrq;
else
    freqax = sp.freq;
end

if nargin <= 2
    hoffset = 0;
    voffset = .01;
end

% mode: 0=real, 1=imag, 2=abs
if nargin<5
    mode = 0;
end

spave = average(sp);
offset = max(abs(spave.spec)) * voffset;

hold on
for idx = 1:sp.numspec
    switch (mode)
        case 0
            signal = real(sp.spec(:,idx));

        case 1
            signal = imag(sp.spec(:,idx));

        otherwise
            signal = abs(sp.spec(:,idx));
    end
    
     
    plot(freqax - (idx-1)*hoffset, ...
        signal+(idx-1)*offset,'k');
end
hold off
set(gca,'Xdir','reverse')
if offset>0
    set(gca,'Ylim', [-5*offset 150*offset])
end
