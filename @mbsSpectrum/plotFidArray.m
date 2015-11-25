% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - plotSpecArray
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Plots the summed spec, arrayed
% ARGUMENTS: mbsSpectrum, axis ('h' for Hz, 'ppm')
%   plotFidArray(sp, axis, hoffset, voffset, mode)
% RETURNS: none
% MODIFICATIONS:
% ****************************************************************************** 
function plotFidArray(sp, hoffset, voffset, mode)
clf

timeax = sp.time;

if nargin < 2
    hoffset = 0;
    voffset = .01;
end

% mode: 0=real, 1=imag, 2=abs
if nargin<4
    mode = 0;
end

fidave = average(sp);
offset = max(abs(fidave.fid)) * voffset;

hold on
for idx = 1:sp.numspec
    switch (mode)
        case 0
            signal = real(sp.fid(:,idx));

        case 1
            signal = imag(sp.fid(:,idx));

        otherwise
            signal = abs(sp.fid(:,idx));
    end
    
     
    plot(timeax + (idx-1)*hoffset, ...
        signal+(idx-1)*offset,'k');
end
hold off
if offset>0
    set(gca,'Ylim', [-5*offset 150*offset])
end
