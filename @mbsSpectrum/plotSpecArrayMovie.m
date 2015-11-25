% ******************************************************************************
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ******************************************************************************
% FUNCTION: mbsSpectrum - plotSpecArrayMovie
% AUTHOR: pjb
% CREATED: 8/7/2002
% DESCRIPTION: Plots the summed spec
% ARGUMENTS: mbsSpectrum, axis ('h' for Hz, 'ppm')
% RETURNS: none
% MODIFICATIONS:
% ******************************************************************************
function plotSpecArrayMovie(sp, axis, mode, xlim, ylim)

if nargin > 1 & axis == 'h'
    freqax = sp.freq .* sp.sfrq;
    axlabel = 'Hz';
else
    freqax = sp.freq;
    axlabel = 'ppm';
end

% mode: 0=real, 1=imag, 2=abs, 3=real+imag
if nargin<3
    mode = 3;
end

numspec = get(sp, 'numspec');
spone = extractSpec(sp, 1);

switch (mode)
    case 0
        plot(freqax, real(spone.spec), 'b');
    case 1
        plot(freqax, imag(spone.spec), 'b');
    case 2
        plot(freqax, abs(spone.spec), 'b');

    otherwise
        plot(freqax, real(spone.spec), 'b', freqax, imag(spone.spec), 'g');
end

set(gca,'Xdir','reverse')
xlabel(axlabel);

if (nargin<4)
    xlim = get(gca, 'Xlim');
    ylim = get(gca, 'Ylim');
else
    set(gca, 'Xlim', xlim);
    set(gca, 'Ylim', ylim);
end

for idx = 2:numspec
    dummy = input(sprintf('Showing %d/%d (press return)', idx-1, numspec));
    %disp(sprintf('Showing %d/%d (press return)', idx-1, numspec));
    pause(.1);

    spone = extractSpec(sp, idx);

    switch (mode)
        case 0
            plot(freqax, real(spone.spec), 'b');
        case 1
            plot(freqax, imag(spone.spec), 'b');
        case 2
            plot(freqax, abs(spone.spec), 'b');

        otherwise
            plot(freqax, real(spone.spec), 'b', freqax, imag(spone.spec), 'g');
    end

    set(gca,'Xdir','reverse')
    set(gca, 'Xlim', xlim);
    set(gca, 'Ylim', ylim);
    xlabel(axlabel);
end
