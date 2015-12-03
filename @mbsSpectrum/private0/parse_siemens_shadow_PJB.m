function [img, ser, mrprot] = parse_siemens_shadow(dcm)
% function to parse siemens numaris 4 shadow data
% returns two structs with image, series header info

ver_string = deblank(char(dcm.Private_0029_1008));
csa_string = deblank(char(dcm.Private_0029_10xx_Creator));

% Can't do string compares unless the strings are in rows
ver_string=reshape(ver_string, 1, length(ver_string));
csa_string=reshape(csa_string, 1, length(csa_string));

if (strcmp(ver_string,'IMAGE NUM 4'))
    if (strcmp(csa_string,'SIEMENS CSA HEADER'))
        img = parse_shadow_func(char(dcm.Private_0029_1010));
        ser = parse_shadow_func(char(dcm.Private_0029_1020));
    else
        error('shadow: Invalid CSA HEADER identifier: %s',csa_string);
    end
elseif (strcmp(ver_string,'SPEC NUM 4'))
    if (strcmp(csa_string,'SIEMENS CSA NON-IMAGE'))
        try
            img = parse_shadow_func(char(dcm.Private_0029_1210));
            ser = parse_shadow_func(char(dcm.Private_0029_1220));
        catch
            img = parse_shadow_func(char(dcm.Private_0029_1110));
            ser = parse_shadow_func(char(dcm.Private_0029_1120));
        end
    else
        error('shadow: Invalid CSA HEADER identifier: %s',csa_string);
    end
else
    error('shadow: Unknown/invalid NUMARIS version: %s',ver_string);
end

% now parse the mrprotocol
tmp_fn = tempname;
fp = fopen(tmp_fn,'w+');
fwrite(fp,ser.MrProtocol,'char');
frewind(fp);
mrprot = parse_mrprot(fp);
fclose(fp);
delete(tmp_fn);

%--------------------------------------------------------------------------

function hdr = parse_shadow_func(dcm)
% internal function to parse shadow header

% dump everything to a temp file
tmp_fn = tempname;

fp = fopen(tmp_fn,'w');
fwrite(fp,dcm,'char');
fclose(fp);

% open it using little endian ordering, so this should work on any machine
fp = fopen(tmp_fn,'r','ieee-le');

%fprintf('\nReading IMAGE header\n');
img_ver = fread(fp,4,'*char')';                  % version string?  SV10
int1 = fread(fp,1,'int');                        % unknown (chars 1,2,3,4)
nelem = fread(fp,1,'int');                       % # of elements
int2 = fread(fp,1,'int');                        % unknown (77)
%fprintf('Found %d elements\n', nelem);
for y=1:nelem
    data_start_pos = ftell(fp);
    tag = c_str(fread(fp,64,'*char')');
    vm = fread(fp,1,'int');
    vr = c_str(fread(fp,4,'*char')');
    SyngoDT = fread(fp,1,'int');                 % SyngoDT
    NoOfItems = fread(fp,1,'int');               % NoOfItems

    if (vm == 0) % this can happen in spectroscopy files
        vm = 6;
    end
    
    str_data = '';
    
    if (NoOfItems > 1)
        int3 = fread(fp,1,'int'); % unknown (77)

        for z=1:vm
            int_items = fread(fp,4,'int'); % unknown (77)
            use_fieldwidth = ceil(int_items(4) / 4) * 4;
            tmp_data = c_str(fread(fp,use_fieldwidth,'*char')');
            str_data = [str_data tmp_data];
            if (z < vm) str_data = [str_data '\']; end

            switch vr
                case {'AE','AS','CS','DA','DT','LO','LT','OB','OW','PN','SH','SQ','ST','TM','UI','UN','UT'}
                    % these are string values
                    %fprintf('String VR %s, data = %s\n',vr,str_data);
                    if (z == 1) val_data = ''; end
                    val_data = strvcat(val_data, tmp_data);
                case {'IS','LO','SL','SS','UL','US'}
                    % these are int/long values
                    %fprintf('%s: Int/Long VM %d, VR %s, data = %s, val = %d\n',tag,vm,vr,tmp_data,str2num(tmp_data));
                    if (z == 1) val_data = zeros(vm,1); end
                    if (size(tmp_data,2) > 0) val_data(z) = str2num(tmp_data); end
                case {'DS','FL','FD'} 
                    % these are floating point values
                    %fprintf('%s: Float/double VM %d, VR %s, data = %s, val = %.8f\n',tag,vm,vr,tmp_data,str2num(tmp_data));
                    if (z == 1) val_data = zeros(vm,1); end
                    if (size(tmp_data,2) > 0) val_data(z) = str2num(tmp_data); end
                otherwise % just assume string
                    %error('Unknown VR = %s found!\n',vr);
                    %fprintf('Unknown VR %s, data = %s\n',vr,str_data);
                    if (z == 1) val_data = ''; end
                    val_data = strvcat(val_data, tmp_data);
            end
        end
    else
        val_data = [];
    end

    junk_len = 16 * (NoOfItems - vm);
    if (NoOfItems < 1)
        junk_len = 4;
    else
        if ( (junk_len < 16) && (junk_len ~= 0) )
            junk_len = 16;
        end
    end

    data_end_pos = ftell(fp);
    junk_data = fread(fp,junk_len,'*char');
    data_final_pos = ftell(fp);

%     fprintf('%2d - ''%s''\tVM %d, VR %s, SyngoDT %d, NoOfItems %d, Data',y-1, tag, vm, vr, SyngoDT, NoOfItems);
%     if (size(str_data))
%         fprintf(' ''%s''', str_data);
%     end
%     fprintf('\n');
%     fprintf('data_len: %d  pad_len: %d  total_len: %d\n',data_end_pos-data_start_pos,data_final_pos-data_end_pos,data_final_pos-data_start_pos);
%     fprintf('VR %s\n',vr);
    
    try
        hdr.(tag) = val_data;
    catch
       disp(['Failed reading tag'  tag]); 
    end
end

fclose(fp);
delete(tmp_fn);
