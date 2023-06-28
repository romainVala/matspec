function [CSIdata] = write_fid_to_nii(fids,rootdir,naming_convention)

if ~exist('rootdir')
  rootdir=spm_select([1 Inf],'dir','Select directories to write nii','',pwd);
end

if ~exist('naming_convention')
  naming_convention=3;
end


for k=1:length(fids)
    f=fids(k);
    
    CSIdata.dim = [1 1 1];
    CSIdata.vox = f.Pos.VoiFOV;
    CSIdata.pos = f.Pos.VoiPosition;
    
    if isfield(f.Pos,'Voimat')
        CSIdata.orient = f.Pos.Voimat;
        orient = CSIdata.orient;
    else
        CSIdata.orient = f.Pos.VoiOrientation;
        orient = CSIdata.orient;
        
        orient(:,3)      = null(orient');
        if det(orient)<0, orient(:,3) = -orient(:,3); end;
        CSIdata.orient = orient;        
    end
    
        if det(orient)<0, orient(:,3) = -orient(:,3); end;
        CSIdata.orient = orient;

    % Nifti header %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dim    = CSIdata.dim;
    dt     = [spm_type('int16') spm_platform('bigend')];

    analyze_to_dicom = [diag([1 -1 1]) [0 (dim(2)-1) 0]'; 0 0 0 1]*[eye(4,3) [-1 -1 -1 1]'];

    vox = CSIdata.vox;
    %pos = get_numaris4_numval(hdr{1}.Private_0029_1210,'ImagePositionPatient')';
    pos = CSIdata.pos; %position of the upper left corner of the voxel!!
    %pos = pos + [vox(1)/2;vox(2)/2;-vox(3)/2]; %position of the center of the voxel
    %CSIdata.pos = pos;
    if isstruct(pos)
        pos = [pos.dSag, pos.dCor, pos.dTra]';
    end
    
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
    if naming_convention==1
      sd =fullfile(rootdir,f.sujet_name);
      ser = f.Serie_description(length(f.SubjectID)+6:end);
      sr = (fullfile(sd,nettoie_dir(ser))); if ~exist(sr), mkdir(sr);end
      fname = [f.SerDescr];
      fname = nettoie_dir(fname);
      
      file_name = fullfile(sr,[fname,'.nii']);
    elseif naming_convention==2

      sujreg = [f.SubjectID(1:2) '$'];
      dirsuj = get_subdir_regex(rootdir,sujreg)

      %ser = f.Serie_description(length(f.SubjectID)+6:end);
      ser = ['Suj' f.SubjectID(1:2) '_' f.ser_dir '_NEX' num2str(f.Nex)];
      sr = (fullfile(dirsuj{1},nettoie_dir(ser))); if ~exist(sr), mkdir(sr);end
      fname = [f.SerDescr];
      fname = nettoie_dir(fname);
      file_name = fullfile(sr,[fname,'.nii']);
    
    elseif naming_convention==3
      sd =fullfile(rootdir,f.sujet_name);
      ser = f.ser_dir;
      sr = fullfile(sd,ser); if ~exist(sr), mkdir(sr);end
      fname = [f.SerDescr];
      fname = nettoie_dir(fname);
      file_name = fullfile(sr,[fname,'.nii']);
     
    else
      fname = [f.sujet_name,'_',f.examnumber,'_',f.SerDescr];
      fname = nettoie_dir(fname);
      file_name = fullfile(rootdir,[fname,'.nii']);
    end
    
    
    if exist(file_name)
      warning('file %s exist',file_name)
    else 
      fprintf('creating %s \n',file_name)
    end
    
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

    %volume = zeros(dim);
%    volume = fftshift(abs(fft(CSIdata.data,[],3)),3);
    volume = 10*ones(dim);
    N.dat(:,:,:) = volume;

    create(N);
    
%    o = maroi_image(struct('vol', spm_vol(file_name), 'binarize',1,...			 'func', 'img>0'));
%    o = label(o,fname);
%    o = spm_hold(o,0)
%    roi_fname =  fullfile(rootdir,[fname,'_roi.mat']);
%    saveroi(o, roi_fname);

%     orient(:,4) = [0;0;0];
%     CSIdata.orient = [orient;0 0 0 1];
%    save([path filesep fname,'_csi.mat'],'CSIdata');
    
end