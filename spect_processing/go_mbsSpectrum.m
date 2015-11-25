% Create a new one
sp = mbsSpectrum;
fname = 'M:\prj\MRS_for_gosia\MR-SE017-laser_te45_ref-TC-30\MR-ST002-SE017-0001.dcm';

sp = readSiemens(sp, fname);
plotSpec(sp);
figure(4)
plotFid(sp);

% Modifying
sp_phased = aph0(sp);
figure(2)
plotSpec(sp_phased);

% Chaining togehter
figure(3)
plotSpec(lineBroaden(aph0(sp), 10))

% Extracting data
timeax = get(sp, 'time');
fid = get(sp, 'fid');
freq = get(sp, 'freq');
spec = get(sp, 'spec');
plot(freq, real(spec));
at = get(sp, 'at');
% open up the "get" function to see all that is available.

% Shifting
sp_shift = shiftSpec(sp, 5);
plotSpec(shiftSpec(sp, 5))

sp_moved = set(sp, 'centerfreq', 500);
plotSpec(sp_moved);

% For b0 correction, I usually use findMax, 



