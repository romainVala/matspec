function [mrprot] = parse_siemens_shadow_mrprot
(dcm)
% [ mrprot] = parse_siemens_shadow(dcm)
% function to parse siemens numaris 4 shadow data
% returns  mrprot info
% does not work with arrayed dcm()

if (size(dcm,2) > 1)
    error('parse_siemens_shadow does not work on arrayed dicominfo data!')
end


% now parse the mrprotocol
tmp_fn = tempname;
fp = fopen(tmp_fn,'w+');
if isfield(ser, 'MrPhoenixProtocol') % VB13
    MrProtocol = char(ser.MrPhoenixProtocol);
else
    MrProtocol = char(ser.MrProtocol);
end
spos = strfind(MrProtocol,'### ASCCONV BEGIN ###');
epos = strfind(MrProtocol,'### ASCCONV END ###');
MrProtocol = MrProtocol(spos+22:epos-2);
fwrite(fp,MrProtocol,'char');
frewind(fp);
mrprot = parse_mrprot(fp);
fclose(fp);
delete(tmp_fn);


mrprot.sPrepPulses.ucWaterSat