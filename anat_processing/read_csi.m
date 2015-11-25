function [CSIdata] = read_csi(file,type)

% type = 'Siemens', 'Philips', 'GE'
[p,f,e] = fileparts(file);
if strcmp(lower(e),'.rda')
    type = 'Siemens';
elseif strcmp(lower(e),'.sdat') || strcmp(lower(e),'.spar')
    type = 'Philips';
elseif strcmp(lower(e),'.7')
    type = 'GE';
end

if strcmp(type,'Siemens')
    fid = fopen(file, 'r', 'ieee-le');

    head_start_text = '>>> Begin of header <<<';
    head_end_text   = '>>> End of header <<<';

    tline = fgets(fid);

    while (isempty(strfind(tline , head_end_text)))

        tline = fgets(fid)

        if ( isempty(strfind (tline , head_start_text)) + isempty(strfind (tline , head_end_text )) == 2)


            % Store this data in the appropriate format

            occurence_of_colon = findstr(':',tline);
            variable = tline(1:occurence_of_colon-1) ;
            value    = tline(occurence_of_colon+1 : length(tline)) ;

            switch variable
                case { 'PatientID' , 'PatientName' , 'StudyDescription' , 'PatientBirthDate' , 'StudyDate' , 'StudyTime' , 'PatientAge' , 'SeriesDate' , ...
                        'SeriesTime' , 'SeriesDescription' , 'ProtocolName' , 'PatientPosition' , 'ModelName' , 'StationName' , 'InstitutionName' , ...
                        'DeviceSerialNumber', 'InstanceDate' , 'InstanceTime' , 'InstanceComments' , 'SequenceName' , 'SequenceDescription' , 'Nucleus' ,...
                        'TransmitCoil' }
                    eval(['rda.' , variable , ' = value ;']);
                case { 'PatientSex' }
                    % Sex converter! (int to M,F,U)
                    switch value
                        case 0
                            rda.sex = 'Unknown';
                        case 1
                            rda.sex = 'Male';
                        case 2

                            rda.sex = 'Female';
                    end

                case {  'SeriesNumber' , 'InstanceNumber' , 'AcquisitionNumber' , 'NumOfPhaseEncodingSteps' , 'NumberOfRows' , 'NumberOfColumns' , 'VectorSize' }
                    %Integers
                    eval(['rda.' , variable , ' = str2num(value) ;']);
                case { 'PatientWeight' , 'TR' , 'TE' , 'TM' , 'DwellTime' , 'NumberOfAverages' , 'MRFrequency' , 'MagneticFieldStrength' , 'FlipAngle' , ...
                        'SliceThickness' ,  'FoVHeight' , 'FoVWidth' , 'PercentOfRectFoV' , 'PixelSpacingRow' , 'PixelSpacingCol','PixelSpacing3D'}
                    %Floats
                    eval(['rda.' , variable , ' = str2num(value) ;']);
                case {'SoftwareVersion[0]' }
                    rda.software_version = value;
                case {'CSIMatrixSize[0]' }
                    rda.CSIMatrix_Size(1) = str2num(value);
                case {'CSIMatrixSize[1]' }
                    rda.CSIMatrix_Size(2) = str2num(value);
                case {'CSIMatrixSize[2]' }
                    rda.CSIMatrix_Size(3) = str2num(value);
%                case {'PositionVector[0]' }
                case {'VOIPositionSag' }
                    rda.PositionVector(1) =  str2num(value);
%                case {'PositionVector[1]' }
                case {'VOIPositionCor' }
                    rda.PositionVector(2) = str2num(value);
%                case {'PositionVector[2]' }
                case {'VOIPositionTra' }
                    rda.PositionVector(3) = str2num(value);
                case {'RowVector[0]' }
                    rda.RowVector(1) = str2num(value);
                case {'RowVector[1]' }
                    rda.RowVector(2) = str2num(value);
                case {'RowVector[2]' }
                    rda.RowVector(3) = str2num(value);
                case {'ColumnVector[0]' }
                    rda.ColumnVector(1) = str2num(value);
                case {'ColumnVector[1]' }
                    rda.ColumnVector(2) = str2num(value);
                case {'ColumnVector[2]' }
                    rda.ColumnVector(3) = str2num(value);

                otherwise
                    % We don't know what this variable is.  Report this just to keep things clear
                    %disp(['Unrecognised variable ' , variable ]);
            end

        else
            % Don't bother storing this bit of the output
        end

    end

%     tpos1 = findstr(charfilecontent(1:end),'>>> End of header <<<');
%     header_size = tpos1+21;

%     fseek(FileId, header_size+1, 'bof');
    [temp_data, count] = fread(fid, inf, 'double');

    num_row = rda.CSIMatrix_Size(2);
    num_column = rda.CSIMatrix_Size(1);
    num_datapoints = rda.VectorSize;

    temp_data = reshape(temp_data,[num_datapoints*2 num_row*num_column]);
    real_data = temp_data(1:2:end,:);
    imag_data = temp_data(2:2:end,:);
    real_data = reshape(real_data,[num_datapoints num_row num_column]);
    imag_data = reshape(imag_data,[num_datapoints num_row num_column]);

    datatot_time = real_data + i*imag_data;
    datatot_time = permute(datatot_time,[2 3 1]);

    CSIdata.data = datatot_time;
    CSIdata.dim = [num_column num_row rda.CSIMatrix_Size(3)];
%    CSIdata.vox = [rda.PixelSpacingRow rda.PixelSpacingCol rda.SliceThickness];
    CSIdata.vox = [ rda.PixelSpacingCol rda.PixelSpacingRow rda.SliceThickness];
    CSIdata.orient = [rda.RowVector' rda.ColumnVector'];
%    CSIdata.orient = [ rda.ColumnVector' rda.RowVector'];
    CSIdata.pos = rda.PositionVector';
    CSIdata.Ts = rda.DwellTime/1000;
    CSIdata.MRFrequency = rda.MRFrequency;
    CSIdata.nbpts = rda.VectorSize;
    CSIdata.TR = rda.TR;
    CSIdata.TE = rda.TE;
    
    % Nifti header %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dim    = CSIdata.dim;
    dt     = [spm_type('int16') spm_platform('bigend')];

    analyze_to_dicom = [diag([1 -1 1]) [0 (dim(2)-1) 0]'; 0 0 0 1]*[eye(4,3) [-1 -1 -1 1]'];

%     orient(1,1) = CSIdata.OrientRowX;
%     orient(2,1) =  CSIdata.OrientRowY;
%     orient(3,1) =  CSIdata.OrientRowZ;
%     orient(1,2) = CSIdata.OrientColumnX;
%     orient(2,2) =  CSIdata.OrientColumnY;
%     orient(3,2) =  CSIdata.OrientColumnZ;
    orient = CSIdata.orient;

    orient(:,3)      = null(orient');
    if det(orient)<0, orient(:,3) = -orient(:,3); end;
    %     z = get_numaris4_numval(hdr{1}.Private_0029_1210,...
    %                 'SliceThickness');
    CSIdata.orient = orient;
    vox = CSIdata.vox;
    %pos = get_numaris4_numval(hdr{1}.Private_0029_1210,'ImagePositionPatient')';
    pos = CSIdata.pos; %position of the upper left corner of the voxel!!
    %pos = pos + [vox(1)/2;vox(2)/2;-vox(3)/2]; %position of the center of the voxel
    %CSIdata.pos = pos;
    dicom_to_patient = [orient*diag(vox) pos ; 0 0 0 1];
    patient_to_tal   = diag([-1 -1 1 1]);
    % warning('Don''t know exactly what positions in spectroscopy files should be - just guessing!')
    mat = patient_to_tal*dicom_to_patient*analyze_to_dicom;

%     % Create voxels corners description %%%%%%%%%%%%%%
%     pos1 = [CSIdata.posX;CSIdata.posY;CSIdata.posZ-z/2];
%     dicom_to_patient1 = [orient*diag(vox) pos1 ; 0 0 0 1];
%     mat_corner = patient_to_tal*dicom_to_patient1*analyze_to_dicom;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pinfo = [1 0 0]';

    % Write the image volume
    %-------------------------------------------------------------------

    [path,fname,ext] = fileparts(file);
    file_name = [path filesep fname,'.nii'];
    N      = nifti;
    %dim(3) = 2;
    %dim(4) = size(CSIdata.data,3);
    %dim(3) = size(CSIdata.data,3);
    N.dat  = file_array(file_name,dim,dt,0,pinfo(1),pinfo(2));
    N.mat  = mat;
    N.mat0 = mat;
    N.mat_intent  = 'Scanner';
    N.mat0_intent = 'Scanner';
    N.descrip     = '';
    create(N);
    %volume = zeros(dim);
%    volume = fftshift(abs(fft(CSIdata.data,[],3)),3);
    volume = 10*ones(dim);
    volume(1:2:end,1:2:end,1) = -10;
    volume(2:2:end,2:2:end,1) = -10;
%     %volume(:,:,2) = 0;
    N.dat(:,:,:) = volume;
    CSIdata.nifti = N;
%     orient(:,4) = [0;0;0];
%     CSIdata.orient = [orient;0 0 0 1];
    save([path filesep fname,'_csi.mat'],'CSIdata');
    
elseif strcmp(type,'Philips')
    [ppp,fff,ext] = fileparts(file);
    fileparam = [ppp filesep fff '.SPAR'];
    fid = fopen(fileparam, 'r', 'ieee-le');
    if fid < 0
       fileparam = [ppp filesep fff '.spar'];
        fid = fopen(fileparam, 'r', 'ieee-le'); 
    end
    tline = fgets(fid);
    while tline ~= -1
        %dtline = deblank(tline)
        if isempty(strfind(tline,'!')) && ~isempty(tline)
            occurence_of_colon = findstr(':',tline);
            variable = tline(1:occurence_of_colon-2) ;
            value    = tline(occurence_of_colon+1 : length(tline)) ;

            switch variable
                case { 'examination_name' , 'scan_id' , 'scan_date' , 'patient_name' , 'patient_birth_date' , 'patient_position' , 'patient_orientation' , ...
                        'nucleus' , 'volume_selection_enable' , 't1_measurement_enable' , 't2_measurement_enable' , 'time_series_enable' , 'phase_encoding_enable' , ...
                        'phase_encoding_direction' , 'spec_data_type' , 'spec_sample_extension' , 'spec_col_extension', ...
                        'spec_row_extension' , 'dim1_ext' , 'dim1_direction' , 'dim2_ext' , 'dim2_direction' , 'dim3_ext' , 'dim3_direction' }
                    eval(['spar.' , variable , ' = value ;']);
                case { 'samples' , 'rows' , 'synthesizer_frequency' , 'offset_frequency' , 'sample_frequency' , 'echo_nr' , 'mix_number' , 't0_mu1_direction' , ...
                        'echo_time' , 'repetition_time' , 'averages' , 'volumes' , 'ap_size' , 'lr_size' , 'cc_size' , 'ap_off_center' , 'lr_off_center' , ...
                        'cc_off_center' , 'ap_angulation' , 'lr_angulation' , 'cc_angulation' , 'volume_selection_method' , 'nr_phase_encoding_profiles' , ...
                        'si_ap_off_center' , 'si_lr_off_center' , 'si_cc_off_center' , 'si_ap_off_angulation' , 'si_lr_off_angulation' , 'si_cc_off_angulation' , ...
                        't0_kx_direction' , 't0_ky_direction' , 'nr_of_phase_encoding_profiles_ky' , 'phase_encoding_fov' , 'slice_thickness' , 'image_plane_slice_thickness' , ...
                        'slice_distance' , 'nr_of_slices_for_multislice' , 'spec_num_col' , 'spec_col_lower_val' , 'spec_col_upper_val' , 'spec_num_row' , ...
                        'spec_row_lower_val' , 'spec_row_upper_val' , 'num_dimensions' , 'dim1_pnts' , 'dim1_low_val' , 'dim1_step' , 'dim1_direction' , 'dim1_t0_point' , ...
                        'dim2_pnts' , 'dim2_low_val' , 'dim2_step' , 'dim2_t0_point' , 'dim3_pnts' , 'dim3_low_val' , 'dim3_step' , 'dim3_t0_point' ,'SUN_num_dimensions' , ...
                        'SUN_dim1_pnts' , 'SUN_dim1_low_val' , 'SUN_dim1_step' , 'SUN_dim1_direction' , 'SUN_dim1_t0_point' , 'SUN_dim2_pnts' , 'SUN_dim2_low_val' , ...
                        'SUN_dim2_step' , 'SUN_dim2_t0_point' , 'SUN_dim3_pnts' , 'SUN_dim3_low_val' , 'SUN_dim3_step' , 'SUN_dim3_t0_point' }
                    eval(['spar.' , variable , ' = str2num(value) ;']);
            end
            
            
        end
        tline = fgets(fid);
    end
    fclose(fid);
    
    
    
    if isfield(spar,'SUN_dim1_pnts')
        num_row = spar.SUN_dim2_pnts;
        num_column = spar.SUN_dim3_pnts;
    else
        num_row = spar.dim2_pnts;
        num_column = spar.dim3_pnts;
    end
    num_datapoints = spar.samples;
    
    filedata = [ppp filesep fff '.SDAT'];     
    fid = fopen(filedata, 'r', 'g');
    if fid < 0
        filedata = [ppp filesep fff '.sdat'];     
        fid = fopen(filedata, 'r', 'g');
    end
    data = fread(fid,'float');
    data = data([1:2:length(data)]) - i*data([2:2:length(data)]);
    data = reshape(data(:),[num_datapoints num_row num_column]);
    data = permute(data,[2 3 1]);
    data2 = zeros(size(data));
    for tt=1:size(data2,3)
        data2(:,:,tt) = fliplr(flipud(data(:,:,tt)));
    end
    fclose(fid);
    
    CSIdata.data = data2;
    CSIdata.dim = [num_column num_row 1];
    CSIdata.vox = [spar.phase_encoding_fov/num_column  spar.phase_encoding_fov/num_row spar.slice_thickness];
    %CSIdata.vox = [spar.ap_size/num_column  spar.lr_size/num_row spar.slice_thickness];
    pos_spar(1) = -spar.si_lr_off_center; % position off the center of the fov
    pos_spar(1) = spar.si_ap_off_center;
    pos_spar(3) = spar.si_cc_off_center;
    pos = pos_spar(:) + [-(CSIdata.dim(1)-1)*CSIdata.vox(1)/2;-(CSIdata.dim(2)-1)*CSIdata.vox(2)/2;0];
    CSIdata.pos = pos;
    %CSIdata.Ts = spar.sample_frequency/1000;
    CSIdata.Ts = 1000/spar.sample_frequency;
    CSIdata.MRFrequency = spar.synthesizer_frequency/10^6;
    CSIdata.nbpts = spar.samples;
    CSIdata.TR = spar.repetition_time;
    CSIdata.TE = spar.echo_time;
        
    angLR = spar.si_lr_off_angulation;
    angAP = spar.si_ap_off_angulation;
    angCC = spar.si_cc_off_angulation;
    
    angRL = -angLR; % ??
    angFH = angCC;
    
    r1 = [1 0 0; 0 cos(angRL*pi/180) -sin(angRL*pi/180); 0 sin(angRL*pi/180) cos(angRL*pi/180)];
    r2 = [cos(angAP*pi/180) 0 sin(angAP*pi/180); 0 1 0; -sin(angAP*pi/180) 0 cos(angAP*pi/180)];
    r3 = [cos(angFH*pi/180) -sin(angFH*pi/180) 0; sin(angFH*pi/180) cos(angFH*pi/180) 0; 0 0 1];
    orient = r1*r2*r3;
    CSIdata.orient = orient;
    
%     dim = CSIdata.dim;
%     R_tot=[[r1*r2*r3,[0 0 0]'];0 0 0 1];
%     realvoxsize = CSIdata.vox;
%     Zm=[diag(realvoxsize) zeros(3,1);0 0 0 1];
%     patient_to_tal   = diag([-1 -1 1 1]);
%     analyze_to_dicom = diag([1  -1 1 1]);
%     A_tot=patient_to_tal*R_tot*Zm*analyze_to_dicom;
%     dim = CSIdata.dim;
%     p_orig = [(dim(1)-1)/2, (dim(2)-2)/2, (dim(3)-1)/2, 1];
%     offsetA=A_tot*p_orig';
%     % trying to incorporate AP FH RL translation: determined using some
%     % common sense, Chris Rordon's help + source code and trial and error,
%     % this is considered EXPERIMENTAL!
%     A_tot(1:3,4)=[-offsetA(1);-offsetA(2);-offsetA(3)] - [spar.lr_off_center;spar.ap_off_center;-spar.cc_off_center];
%     mat1=A_tot;


    dim = CSIdata.dim;
    vox = CSIdata.vox;
    pos = CSIdata.pos;
    analyze_to_dicom = [diag([1 -1 1]) [0 (dim(2)-1) 0]'; 0 0 0 1]*[eye(4,3) [-1 -1 -1 1]'];
    dicom_to_patient = [orient*diag(vox) pos ; 0 0 0 1];
    patient_to_tal   = diag([-1 -1 1 1]);
    mat = patient_to_tal*dicom_to_patient*analyze_to_dicom;
    
    
    
    dt     = [spm_type('int16') spm_platform('bigend')];
    pinfo = [1 0 0]';

    % Write the image volume
    %-------------------------------------------------------------------

    [path,fname,ext] = fileparts(file);
    file_name = [path filesep fname,'.nii'];
    N      = nifti;
    N.dat  = file_array(file_name,dim,dt,0,pinfo(1),pinfo(2));
    N.mat  = mat;
    N.mat0 = mat;
    N.mat_intent  = 'Scanner';
    N.mat0_intent = 'Scanner';
    N.descrip     = '';
    create(N);
    volume = ones(dim);
    N.dat(:,:,:) = volume;
    CSIdata.nifti = N;
    save([path filesep fname,'_csi.mat'],'CSIdata');
    
   
    
elseif strcmp(type,'GE')
    [ppp,fff,ext] = fileparts(file);
    currentdir = pwd;
    if ~isempty(ppp)
        cd(ppp)
    end
    % read hdr
    prog = which('read_csi.m');
    progdir = fileparts(prog);
    unix([progdir '/./rdgehdr ' file ' > out.txt']);
    if ~isempty(ppp)
        cd(currentdir)
    end
    
    fid = fopen('out.txt', 'r', 'ieee-le');
    tline = fgets(fid);
    while tline ~= -1
        %dtline = deblank(tline)
        if isempty(strfind(tline,'!')) && ~isempty(tline)
            occurence_of_colon = findstr(':',tline);
            ras = findstr('(r,a,s)',lower(tline));
            parent = findstr('(',tline);
            if ~isempty(ras)
                variable = lower(tline(1:occurence_of_colon-1)); 
            elseif ~isempty(parent)
                variable = lower(tline(1:parent-1)); 
            else
                variable = lower(tline(1:occurence_of_colon-1)); 
            end
            value    = tline(occurence_of_colon+1 : length(tline)); 

            variable = deblank(variable);
            switch variable
                case '...rhspecrescsix'
                    eval(['CSIdata.dim(1)= str2num(value) ;']);
                case '...rhspecrescsiy'
                    eval(['CSIdata.dim(2)= str2num(value) ;']);
                case '...rhdaxres'
                    eval(['CSIdata.nbpts= str2num(value) ;']);
                case {'...specwidth filter width khz'}
                    eval(['CSIdata.Ts= 1/str2num(value) ;']);
                case {'...ps aps center frequency hz'}
                    eval(['CSIdata.MRFrequency= str2num(value)/10^7 ;']);
                case {'...rx x csi volume dimension'}
                    eval(['CSIdata.vox(1)= str2num(value)/CSIdata.dim(1) ;']);
                case {'...rx y csi volume dimension'}
                    eval(['CSIdata.vox(2)= str2num(value)/CSIdata.dim(2) ;']);
                case {'...rx z csi volume dimension'}
                    eval(['CSIdata.vox(3)= str2num(value) ;']);
                case {'...rx x csi volume center'}
                    eval(['CSIdata.pos(2)= str2num(value) - (CSIdata.dim(2)-1)*CSIdata.vox(2)/2 ;']);
                case {'...rx y csi volume center'}
                    eval(['CSIdata.pos(1)= str2num(value) - (CSIdata.dim(1)-1)*CSIdata.vox(1)/2 ;']);
                case {'...rx z csi volume center'}
                    eval(['CSIdata.pos(3)= str2num(value) ;']);
                case {'...pulse repetition time'}
                    eval(['CSIdata.TR= str2num(value)/10^3 ;']);
                case {'...pulse echo time'}
                    eval(['CSIdata.TE= str2num(value)/10^3 ;']);
                case {'...(r,a,s) coord of top left hand corner'}
                    aa =findstr(',',value);
                    bb =findstr('(',value);
                    cc =findstr(')',value);
                    eval(['r1(1) = str2num(deblank(value(bb+1:aa(1)-1)));']);
                    eval(['r1(2) = str2num(deblank(value(aa(1)+1:aa(2)+1)));']);
                    eval(['r1(3) = str2num(deblank(value(aa(2)+1:cc-1)));']);
                case {'...(r,a,s) coordinate of top left hand corner'}
                    aa =findstr(',',value);
                    bb =findstr('(',value);
                    cc =findstr(')',value);
                    eval(['r1(1) = str2num(deblank(value(bb+1:aa(1)-1)));']);
                    eval(['r1(2) = str2num(deblank(value(aa(1)+1:aa(2)+1)));']);
                    eval(['r1(3) = str2num(deblank(value(aa(2)+1:cc-1)));']);
                case {'...(r,a,s) coord of top right hand corner'}
                    aa =findstr(',',value);
                    bb =findstr('(',value);
                    cc =findstr(')',value);
                    eval(['r2(1) = str2num(deblank(value(bb+1:aa(1)-1)));']);
                    eval(['r2(2) = str2num(deblank(value(aa(1)+1:aa(2)+1)));']);
                    eval(['r2(3) = str2num(deblank(value(aa(2)+1:cc-1)));']);
                case {'...(r,a,s) coordinate of top right hand corner'}
                    aa =findstr(',',value);
                    bb =findstr('(',value);
                    cc =findstr(')',value);
                    eval(['r2(1) = str2num(deblank(value(bb+1:aa(1)-1)));']);
                    eval(['r2(2) = str2num(deblank(value(aa(1)+1:aa(2)+1)));']);
                    eval(['r2(3) = str2num(deblank(value(aa(2)+1:cc-1)));']);
                case {'...(r,a,s) coord of bottom right hand corner'}
                    aa =findstr(',',value);
                    bb =findstr('(',value);
                    cc =findstr(')',value);
                    eval(['r3(1) = str2num(deblank(value(bb+1:aa(1)-1)));']);
                    eval(['r3(2) = str2num(deblank(value(aa(1)+1:aa(2)+1)));']);
                    eval(['r3(3) = str2num(deblank(value(aa(2)+1:cc-1)));']);
                case {'...(r,a,s) coordinate of bottom right hand corner'}
                    aa =findstr(',',value);
                    bb =findstr('(',value);
                    cc =findstr(')',value);
                    eval(['r3(1) = str2num(deblank(value(bb+1:aa(1)-1)));']);
                    eval(['r3(2) = str2num(deblank(value(aa(1)+1:aa(2)+1)));']);
                    eval(['r3(3) = str2num(deblank(value(aa(2)+1:cc-1)));']);
                case {'...(r,a,s) center coord of plane image'}
                    aa =findstr(',',value);
                    bb =findstr('(',value);
                    cc =findstr(')',value);
                    eval(['pos(1) = str2num(deblank(value(bb+1:aa(1)-1)));']);
                    eval(['pos(2) = str2num(deblank(value(aa(1)+1:aa(2)+1)));']);
                    eval(['pos(3) = str2num(deblank(value(aa(2)+1:cc-1)));']);
                case {'...(r,a,s) center coordinate of image'}
                    aa =findstr(',',value);
                    bb =findstr('(',value);
                    cc =findstr(')',value);
                    eval(['pos(1) = str2num(deblank(value(bb+1:aa(1)-1)));']);
                    eval(['pos(2) = str2num(deblank(value(aa(1)+1:aa(2)+1)));']);
                    eval(['pos(3) = str2num(deblank(value(aa(2)+1:cc-1)));']);

                    
            end
            
                    end
        tline = fgets(fid);
    end
    fclose(fid);
    
    CSIdata.dim(3) =1;
    
    %CSIdata.pos = CSIdata.pos';
    %CSIdata.pos = r2';
    %CSIdata.pos = r1'; % position of the top left hand corner
    CSIdata.pos = [r1(2);r1(1);r1(3)];
    %CSIdata.pos = pos(:) + [-(CSIdata.dim(1)-1)*CSIdata.vox(1)/2;-(CSIdata.dim(2)-1)*CSIdata.vox(2)/2;0];
    %CSIdata.pos = pos(:);
    %vox = CSIdata.vox;
    %pos = CSIdata.pos + [vox(1)/2;vox(2)/2;-vox(3)/2];
    %CSIdata.pos = pos;

    rowVector = r2 - r1;
    columnVector = r3 - r2;
    CSIdata.orient = ([rowVector/norm(rowVector);columnVector/norm(columnVector)])';
    
    % read_data
	data_frame = read_pfile(file);
    
    CSIdata.data = data_frame;
       
    % Nifti header %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dim    = CSIdata.dim;
    dt     = [spm_type('int16') spm_platform('bigend')];

    analyze_to_dicom = [diag([1 -1 1]) [0 (dim(2)-1) 0]'; 0 0 0 1]*[eye(4,3) [-1 -1 -1 1]'];
    orient = CSIdata.orient;

    orient(:,3)      = null(orient');
    if det(orient)<0, orient(:,3) = -orient(:,3); end;
    CSIdata.orient = orient;
    vox = CSIdata.vox;
    pos = CSIdata.pos; 
    dicom_to_patient = [orient*diag(vox) pos ; 0 0 0 1];
    patient_to_tal   = diag([-1 -1 1 1]);
    % warning('Don''t know exactly what positions in spectroscopy files should be - just guessing!')
    mat = patient_to_tal*dicom_to_patient*analyze_to_dicom;

%     % Create voxels corners description %%%%%%%%%%%%%%
%     pos1 = [CSIdata.posX;CSIdata.posY;CSIdata.posZ-z/2];
%     dicom_to_patient1 = [orient*diag(vox) pos1 ; 0 0 0 1];
%     mat_corner = patient_to_tal*dicom_to_patient1*analyze_to_dicom;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pinfo = [1 0 0]';

    % Write the image volume
    %-------------------------------------------------------------------

    [path,fname,ext] = fileparts(file);
    file_name = [path filesep fname,'.nii'];
    N      = nifti;
    %dim(3) = 2;
    %dim(4) = size(CSIdata.data,3);
    %dim(3) = size(CSIdata.data,3);
    N.dat  = file_array(file_name,dim,dt,0,pinfo(1),pinfo(2));
    N.mat  = mat;
    N.mat0 = mat;
    N.mat_intent  = 'Scanner';
    N.mat0_intent = 'Scanner';
    N.descrip     = '';
    create(N);
    %volume = zeros(dim);
%    volume = fftshift(abs(fft(CSIdata.data,[],3)),3);
    volume = 10*ones(dim);
    volume(1:2:end,1:2:end,1) = -10;
    volume(2:2:end,2:2:end,1) = -10;
%     %volume(:,:,2) = 0;
    N.dat(:,:,:) = volume;
    CSIdata.nifti = N;
%     orient(:,4) = [0;0;0];
%     CSIdata.orient = [orient;0 0 0 1];
    save([path filesep fname,'_csi.mat'],'CSIdata');
    
end

