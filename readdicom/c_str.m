function outstr = c_str(instr)
% eja function to read C-style null-terminated strings
% (strips everything past the first null)

if (isempty(instr))
    outstr = '';
else
    if (instr(1) == char(0))
        outstr = '';
    else
        outstr = strtok(instr, char(0));
    end
end
