function outstr = c_str(instr)
% eja function to read C-style null-terminated strings
% (strips everything past the first null)

%rrr added because fread use with type UINT8 instead of char
if  isnumeric(instr)
  instr = char(instr);
end

outstr = strtok(instr, char(0));
