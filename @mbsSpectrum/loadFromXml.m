% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - loadFromXml
% AUTHOR: pjb
% CREATED: 9/26/2006
% DESCRIPTION: Streams the essentials from an xml file
% ARGUMENTS: mbsSpectrum, filename
% RETURNS: mbsSpectrum
% MODIFICATIONS:
% ****************************************************************************** 
function sp = loadFromXml(sp, filename)

% Use the xmltree helper to load
tree = xmltree(filename);
in = convert(tree);

% Get all the values needed for calcAxes
sp.sfrq = str2num(in.head.centerFrequency) / 1000000.0;
deltaT = str2num(in.head.samplingInterval);
sp.pts = str2num(in.head.numberSamples);
sp.at = deltaT * (sp.pts - 1);
sp.centerfreq = 0;
sp.numspec = str2num(in.head.numberTraces);

sp.fid = zeros(sp.pts, sp.numspec);
if(sp.numspec ==1 )
    realvals = eval(in.trace.real);
    imagvals = eval(in.trace.imag);
    sp.fid(:, 1) = realvals + i.*imagvals;
else
    for idx = 1:sp.numspec
        realvals = eval(in.trace{idx}.real);
        imagvals = eval(in.trace{idx}.imag);
        sp.fid(:, idx) = realvals + i.*imagvals;
    end
end
sp = spec_fft(sp);
sp = calcAxes(sp);
