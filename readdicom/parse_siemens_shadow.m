function [img, ser, mrprot] = parse_siemens_shadow(varargin)
% [img, ser, mrprot] = parse_siemens_shadow(dcm, debugOutput=false)
% function to parse siemens numaris 4 shadow data
% returns three structs with image, series header, mrprot info
% does not work with arrayed dcm()
%    dependencies: parse_mrprot.m
%                  c_str.m
%                  mread.m
%   E. Auerbach, CMRR, Univ. of Minnesota, 2022

version = '2022.04.01 ''The April Fool''';

fprintf('   ** parse_siemens_shadow version %s started\n', version);

debugOutput = false;

if ((nargin < 1) || (nargin > 2))
    error('invalid input arguments');
else
    dcm = varargin{1};
    if (nargin == 2), debugOutput = varargin{2}; end
end

if (size(dcm,2) > 1)
    error('parse_siemens_shadow does not work on arrayed dicominfo data!')
end

if isfield(dcm,'Private_0029_10xx_Creator')
    % this is the case for most data
    ver_string = private_field_str_fix(dcm.Private_0029_1008);
    csa_string = private_field_str_fix(dcm.Private_0029_10xx_Creator);
elseif isfield(dcm,'Private_0021_14xx_Creator')
    % new DICOM MR spectroscopy data
    ver_string = private_field_str_fix(dcm.Private_0021_14xx_Creator);
    csa_string = '';
elseif isfield(dcm,'Private_0021_12xx_Creator')
    % new XA image data
    ver_string = private_field_str_fix(dcm.Private_0021_12xx_Creator);
    csa_string = '';
end

haveCSAhdr = false;

if (strcmp(ver_string,'IMAGE NUM 4'))
    if (strcmp(csa_string,'SIEMENS CSA HEADER'))
        img = parse_shadow_func(dcm.Private_0029_1010, debugOutput);
        ser = parse_shadow_func(dcm.Private_0029_1020, debugOutput);
        haveCSAhdr = true;
    else
        error('shadow: Invalid CSA HEADER identifier: %s',csa_string);
    end
elseif (strcmp(ver_string,'SPEC NUM 4'))
    if (strcmp(csa_string,'SIEMENS CSA NON-IMAGE'))
        if isfield(dcm,'Private_0029_1210')
            img = parse_shadow_func(dcm.Private_0029_1210, debugOutput);
            ser = parse_shadow_func(dcm.Private_0029_1220, debugOutput);
            haveCSAhdr = true;
        else %VB13
            img = parse_shadow_func(dcm.Private_0029_1110, debugOutput);
            ser = parse_shadow_func(dcm.Private_0029_1120, debugOutput);
            haveCSAhdr = true;
        end
    else
        error('shadow: Invalid CSA HEADER identifier: %s',csa_string);
    end
elseif (strcmp(ver_string,'SIEMENS MR MRS 05') || strcmp(ver_string,'SIEMENS MR SDR 01'))
    % XA MR formats use "standard" DICOM private format fields, not CSA headers
    img = parse_private_func(dcm.PerFrameFunctionalGroupsSequence.Item_1);
    ser = parse_private_func(dcm.SharedFunctionalGroupsSequence.Item_1);
else
    error('shadow: Unknown/invalid NUMARIS version: %s',ver_string);
end

% now parse the mrprotocol
if isfield(ser, 'MrPhoenixProtocol') % VB13
    MrProtocol = char(ser.MrPhoenixProtocol);
else
    MrProtocol = char(ser.MrProtocol);
end
spos = strfind(MrProtocol,'### ASCCONV BEGIN ###');
slen = 22;
if (isempty(spos)) % new VD11 format ==> ### ASCCONV BEGIN <arbitrary text> ###
    spos = strfind(MrProtocol,'### ASCCONV BEGIN');
    slen = strfind(MrProtocol(spos+3:end),'###')+6;
end
epos = strfind(MrProtocol,'### ASCCONV END ###');
if ((isempty(spos)) || (isempty(epos))), error('parse_siemens_shadow error: can''t find MrProtocol!'); end
MrProtocol = MrProtocol(spos+slen:epos-2);
mrprot = parse_mrprot(MrProtocol);

% compatibility fixes
if (~haveCSAhdr)
    if (isfield(dcm,'PulseSequenceName')), img.SequenceName = cellstr(dcm.PulseSequenceName); end
    if (isfield(mrprot,'sSpecPara'))
        if (isfield(mrprot.sSpecPara,'sVoI'))
            if (isfield(mrprot.sSpecPara.sVoI,'dReadoutFOV')), img.VoiReadoutFoV = mrprot.sSpecPara.sVoI.dReadoutFOV; end
            if (isfield(mrprot.sSpecPara.sVoI,'dPhaseFOV')), img.VoiPhaseFoV = mrprot.sSpecPara.sVoI.dPhaseFOV; end
            if (isfield(mrprot.sSpecPara.sVoI,'dThickness')), img.VoiThickness = mrprot.sSpecPara.sVoI.dThickness; end
            if (isfield(mrprot.sSpecPara.sVoI,'sPosition')), img.VoiPosition = mrprot.sSpecPara.sVoI.sPosition; end
        end
    end
    if (isfield(ser,'ImageOrientationPatient')), img.ImageOrientationPatient = ser.ImageOrientationPatient; end
end

%--------------------------------------------------------------------------

function hdr = parse_private_func(private)
% internal function to parse private parameters

if (~isstruct(private))
    error('ERROR: input is not struct?!');
end

hdrCreators = [];
hdr = [];
private_fn = fieldnames(private);

for priv_idx=1:size(private_fn,1)
    item = private.(private_fn{priv_idx});

    if (isstruct(item))
        item_fn = fieldnames(item);

        for item_idx=1:size(item_fn,1)
            item_nm = sprintf('Item_%d',item_idx);

            if (isfield(item,item_nm))
                param = item.(item_nm);
                param_fn = fieldnames(param);

                for param_idx=1:size(param_fn,1)
                    param_name = param_fn{param_idx};
                    param_val = param.(param_fn{param_idx});

                    if (~isstruct(param_val) && ~isempty(param_val))
                        if ( (length(param_name) == 25) && (strcmp(param_name(1:8),'Private_')) && (strcmp(param_name(end-7:end),'_Creator')) )
                            hdrCreators.(param_name) = param_val;
                        end
                        
                        if (ischar(param_val) && (size(item_fn,1) > 1))
                            param_val = cellstr(param_val);
                        end
                        if ((length(param_name) == 17) && (strncmp(param_name,'Private_',8)))
                            param_name = rename_private_field(param_name, hdrCreators);
                        end

                        if (isfield(hdr,param_name)) % catch duplicates
                            if (strcmp(param_name, 'FlowCompensation') && (strcmp(param_val, 'NONE') || strcmp(param_val, 'No')))
                                % this is known: FlowCompensation is doubly defined as 'NONE' and 'No'
                            elseif (size(hdr.(param_name)) == size(param_val))
                                % ignore if same size (overwrite)
                            elseif (size(hdr.(param_name)) == size(param_val'))
                                % ignore if same size (overwrite)
                            elseif (strcmp(param_name, 'ReferencedFrameNumber'))
                                % don't care about this
                            else
                                fprintf('parse_siemens_shadow WARNING: duplicate values found for %s:\n', param_name);
                                disp(hdr.(param_name));
                                disp(param_val);
                            end
                        else
                            hdr.(param_name)(item_idx,:) = param_val;
                        end
                    end
                end
            end
        end
    end
end

%--------------------------------------------------------------------------

function realName = rename_private_field(codeName, hdrCreators)
% internal function to rename private fields
% cf. dictionary file (N4): C:\MedCom\config\dcmAccess\dcm_dict.conf
% cf. dictionary file (NX): %ProgramFiles%\Numaris\MriProduct\DcmAccess\dcm_dict.conf
% also %ProgramFiles%\Numaris\bin\Services\ElementDictionary\MR

realName = codeName;

if (length(codeName) ~= 17), return; end

if (strncmp(codeName, 'Private_0021_11', 15))
    hdrType = hdrCreators.Private_0021_11xx_Creator;
    if (~strcmp(hdrType,'SIEMENS MR SDI 02'))
        error('ERROR: expecting 0021,11xx to be image 02 shadow header, found %s', hdrType);
    end
elseif (strncmp(codeName, 'Private_0021_10', 15))
    hdrType = hdrCreators.Private_0021_10xx_Creator;
    if (~strcmp(hdrType,'SIEMENS MR SDS 01'))
        error('ERROR: expecting 0021,10xx to be series 01 shadow header, found %s', hdrType);
    end
elseif (strncmp(codeName, 'Private_0021_14', 15))
    hdrType = hdrCreators.Private_0021_14xx_Creator;
    if (~strcmp(hdrType,'SIEMENS MR MRS 05'))
        error('ERROR: expecting 0021,14xx to be MRS 05 header, found %s', hdrType);
    end
else
    fprintf('parse_siemens_shadow WARNING: unknown private group type %sxx\n', codeName(1:15));
    return;
end

if (strcmp(hdrType,'SIEMENS MR SDI 02'))
    % Group 21 Image Shadow Attribute private group SIEMENS IMAGE SHADOW ATTRIBUTES
    % ElementDictionary--MR-SIEMENS_IMAGE_SHADOW_ATTRIBUTES.xml
    switch (upper(codeName(end-1:end)))
        case '01', realName = 'NumberOfImagesInMosaic'                            ; % US;1
        case '02', realName = 'SliceNormalVector'                                 ; % FD;3
        case '03', realName = 'SliceMeasurementDuration'                          ; % DS;1
        case '04', realName = 'TimeAfterStart'                                    ; % DS;1
        case '05', realName = 'B_value'                                           ; % IS;1 NumX eMR obsolete
        case '06', realName = 'ICE_Dims'                                          ; % LO;1
        case '1A', realName = 'RFSWDDataType'                                     ; % SH;1
        case '1B', realName = 'MoCoQMeasure'                                      ; % US;1
        case '1C', realName = 'PhaseEncodingDirectionPositive'                    ; % IS;1
        case '1D', realName = 'PixelFile'                                         ; % OB;1
        case '1F', realName = 'FMRIStimulInfo'                                    ; % IS;1
        case '20', realName = 'VoxelInPlaneRot'                                   ; % DS;1
        case '21', realName = 'DiffusionDirectionality4MF'                        ; % CS;1 NumX eMR obsolete
        case '22', realName = 'VoxelThickness'                                    ; % DS;1
        case '23', realName = 'B_matrix'                                          ; % FD;6 NumX eMR obsolete
        case '24', realName = 'MultistepIndex'                                    ; % IS;1
        case '25', realName = 'Comp_AdjustedParam'                                ; % LT;1
        case '26', realName = 'Comp_Algorithm'                                    ; % IS;1
        case '27', realName = 'VoxelNormalCor'                                    ; % DS;1
        case '29', realName = 'FlowEncodingDirectionString'                       ; % SH;1
        case '2A', realName = 'VoxelNormalSag'                                    ; % DS;1
        case '2B', realName = 'VoxelPositionSag'                                  ; % DS;1
        case '2C', realName = 'VoxelNormalTra'                                    ; % DS;1
        case '2D', realName = 'VoxelPositionTra'                                  ; % DS;1
        case '2E', realName = 'UsedChannelMask'                                   ; % UL;1
        case '2F', realName = 'RepetitionTimeEffective'                           ; % DS;1
        case '30', realName = 'CsiImageOrientationPatient'                        ; % DS;6
        case '32', realName = 'CsiSliceLocation'                                  ; % DS;1
        case '33', realName = 'EchoColumnPosition'                                ; % IS;1
        case '34', realName = 'FlowVenc'                                          ; % FD;1 NumX eMR obsolete
        case '35', realName = 'MeasuredFourierLines'                              ; % IS;1
        case '36', realName = 'LQAlgorithm'                                       ; % SH;1
        case '37', realName = 'VoxelPositionCor'                                  ; % DS;1
        case '38', realName = 'Filter2'                                           ; % IS;1
        case '39', realName = 'FMRIStimulLevel'                                   ; % FD;1
        case '3A', realName = 'VoxelReadoutFOV'                                   ; % DS;1
        case '3B', realName = 'NormalizeManipulated'                              ; % IS;1
        case '3C', realName = 'RBMoCoRot'                                         ; % FD;3
        case '3D', realName = 'Comp_ManualAdjusted'                               ; % IS;1
        case '3F', realName = 'SpectrumTextRegionLabel'                           ; % SH;1
        case '40', realName = 'VoxelPhaseFOV'                                     ; % DS;1
        case '41', realName = 'GSWDDataType'                                      ; % SH;1
        case '42', realName = 'RealDwellTime'                                     ; % IS;1
        case '43', realName = 'Comp_JobID'                                        ; % LT;1
        case '44', realName = 'Comp_Blended'                                      ; % IS;1
        case '45', realName = 'ImaAbsTablePosition'                               ; % SL;3
        case '46', realName = 'DiffusionGradientDirection'                        ; % FD;3 NumX eMR obsolete
        case '47', realName = 'FlowEncodingDirection'                             ; % IS;1 NumX eMR obsolete
        case '48', realName = 'EchoPartitionPosition'                             ; % IS;1
        case '49', realName = 'EchoLinePosition'                                  ; % IS;1
        case '4B', realName = 'Comp_AutoParam'                                    ; % LT;1
        case '4C', realName = 'OriginalImageNumber'                               ; % IS;1
        case '4D', realName = 'OriginalSeriesNumber'                              ; % IS;1
        case '4E', realName = 'Actual3DImaPartNumber'                             ; % IS;1
        case '4F', realName = 'ImaCoilString'                                     ; % LO;1
        case '50', realName = 'CsiPixelSpacing'                                   ; % DS;2
        case '51', realName = 'SequenceMask'                                      ; % UL;1
        case '52', realName = 'ImageGroup'                                        ; % US;1
        case '53', realName = 'BandwidthPerPixelPhaseEncode'                      ; % FD;1
        case '54', realName = 'NonPlanarImage'                                    ; % US;1
        case '55', realName = 'PixelFileName'                                     ; % OB;1
        case '56', realName = 'ImaPATModeText'                                    ; % LO;1
        case '57', realName = 'CsiImagePositionPatient'                           ; % DS;3
        case '58', realName = 'AcquisitionMatrixText'                             ; % SH;1
        case '59', realName = 'ImaRelTablePosition'                               ; % IS;3
        case '5A', realName = 'RBMoCoTrans'                                       ; % FD;3
        case '5B', realName = 'SlicePosition_PCS'                                 ; % FD;3
        case '5C', realName = 'CsiSliceThickness'                                 ; % DS;1
        case '5E', realName = 'ProtocolSliceNumber'                               ; % IS;1
        case '5F', realName = 'Filter1'                                           ; % IS;1
        case '60', realName = 'TransmittingCoil'                                  ; % SH;1
        case '61', realName = 'NumberOfAveragesN4'                                ; % DS;1 NumX eMR obsolete
        case '62', realName = 'MosaicRefAcqTimes'                                 ; % FD;1-n NumX eMR obsolete
        case '63', realName = 'AutoInlineImageFilterEnabled'                      ; % IS;1
        case '65', realName = 'QCData'                                            ; % FD;1-n
        case '66', realName = 'ExamLandmarks'                                     ; % LT;1
        case '67', realName = 'ExamDataRole'                                      ; % ST;1
        case '68', realName = 'MRDiffusion'                                       ; % OB;1 NumX eMR obsolete
        case '69', realName = 'RealWorldValueMapping'                             ; % OB;1 NumX eMR obsolete
        case '70', realName = 'DataSetInfo'                                       ; % OB;1
        case '71', realName = 'UsedChannelString'                                 ; % UT;1
        case '72', realName = 'PhaseContrastN4'                                   ; % CS;1 NumX eMR obsolete
        case '73', realName = 'MRVelocityEncoding'                                ; % UT;1 NumX eMR obsolete
        case '74', realName = 'VelocityEncodingDirectionN4'                       ; % FD;3 NumX eMR obsolete
        case '75', realName = 'ImageType4MF'                                      ; % CS;1-n meaning has been changed !!
        case '76', realName = 'ImageHistory'                                      ; % LO;1-n
        case '77', realName = 'SequenceInfo'                                      ; % LO;1
        case '78', realName = 'ImageTypeVisible'                                  ; % CS;1-n NumX renamed to DistortionCorrectionHistory
        case '79', realName = 'DistortionCorrectionType'                          ; % CS;1
        case '80', realName = 'ImageFilterType'                                   ; % CS;1
        case '81', realName = 'PostprocessingUID'                                 ; % LO;1 eMR Image/MR Image syngo.via only
        case '82', realName = 'Distorcor_IntensityCorrection'                     ; % CS;1
        case '84', realName = 'UserDefinedImage'                                  ; % UT;1 NumX - eMR Image only
        case '85', realName = 'FmriResultSequence'                                ; % UT;1 NumX - eMR Image only   
        case '86', realName = 'MR_ASL'                                            ; % UT;1 NumX - eMR Image only
        case '87', realName = 'VolumetricProperties4MF'                           ; % CS;1 NumX - eMR Image only
        case '88', realName = 'SliceCenterDistancefromIsoCenter'                  ; % DS;1 NumX - eMR Image only
        case '89', realName = 'FrameInversionTime'                                ; % DS;1 NumX - eMR Image only; copied from Inversion Times 0018,9079
        case '8A', realName = 'FrameNumberInSeries'                               ; % IS;1 NumX - eMR Image only
        case '8B', realName = 'SlicePositionText'                                 ; % SH;1 NumX - eMR Image only
        case '8C', realName = 'MorphoQCThreshold'                                 ; % FD;1 NumX - eMR Image only
        case '8D', realName = 'MorphoQCIndex'                                     ; % FD;1 NumX - eMR Image only
        case '8E', realName = 'DICOM_Dims'                                        ; % ST;1 NumX - eMR Image only
        otherwise
            fprintf('parse_siemens_shadow WARNING: unknown image shadow header parameter %s\n', codeName);
    end
elseif (strcmp(hdrType,'SIEMENS MR SDS 01'))
    % Group 21 Series Shadow Attribute private SIEMENS SERIES SHADOW ATTRIBUTES
    % ElementDictionary--MR-SIEMENS_SERIES_SHADOW_ATTRIBUTES.xml
    switch (upper(codeName(end-1:end)))
        case '01', realName = 'UsedPatientWeight'                                 ; % IS;1 
        case '02', realName = 'SarWholeBody'                                      ; % DS;3 
        case '03', realName = 'MrProtocol'                                        ; % OB;1 NumX eMR obsolete
        case '04', realName = 'SliceArrayConcatenations'                          ; % DS;1 
        case '05', realName = 'RelTablePosition'                                  ; % IS;3 
        case '06', realName = 'CoilForGradient'                                   ; % LO;1 
        case '07', realName = 'LongModelName'                                     ; % LO;1 
        case '08', realName = 'GradientMode'                                      ; % SH;1 
        case '09', realName = 'PATModeText'                                       ; % LO;1 
        case '0A', realName = 'SW_korr_faktor'                                    ; % DS;1 
        case '0B', realName = 'RfPowerErrorIndicator'                             ; % DS;1 
        case '0C', realName = 'PositivePCSDirections'                             ; % SH;1 
        case '0D', realName = 'ProtocolChangeHistory'                             ; % US;1 
        case '0E', realName = 'DataFileName'                                      ; % LO;1 NumX eMR obsolete
        case '0F', realName = 'Stim_lim'                                          ; % DS;3 
        case '10', realName = 'MrProtocolVersion'                                 ; % IS;1 
        case '11', realName = 'PhaseGradientAmplitude'                            ; % DS;1 
        case '12', realName = 'ReadoutOS'                                         ; % FD;1 
        case '13', realName = 't_puls_max'                                        ; % DS;1 
        case '14', realName = 'NumberOfPrescans'                                  ; % IS;1 
        case '15', realName = 'MeasurementIndex'                                  ; % FL;1 NumX eMR obsolete
        case '16', realName = 'dBdt_thresh'                                       ; % DS;1 
        case '17', realName = 'SelectionGradientAmplitude'                        ; % DS;1 
        case '18', realName = 'RFSWDMostCriticalAspect'                           ; % SH;1 
        case '19', realName = 'MrPhoenixProtocol'                                 ; % OB;1 NumX eMR obsolete
        case '1A', realName = 'CoilString'                                        ; % LO;1 
        case '1B', realName = 'SliceResolution'                                   ; % DS;1 
        case '1C', realName = 'Stim_max_online'                                   ; % DS;3 NumX eMR obsolete
        case '1D', realName = 'Operation_mode_flag'                               ; % IS;1 
        case '1E', realName = 'AutoAlignMatrix'                                   ; % FL;16 NumX eMR obsolete
        case '1F', realName = 'CoilTuningReflection'                              ; % DS;2 NumX eMR obsolete
        case '20', realName = 'RepresentativeImage'                               ; % UI;1 NumX eMR obsolete
        case '22', realName = 'SequenceFileOwner'                                 ; % SH;1
        case '23', realName = 'RfWatchdogMask'                                    ; % IS;1
        case '24', realName = 'PostProcProtocol'                                  ; % LO;1NumX eMR obsolete
        case '25', realName = 'TablePositionOrigin'                               ; % SL;3
        case '26', realName = 'MiscSequenceParam'                                 ; % IS;1-n
        case '27', realName = 'Isocentered'                                       ; % US;1
        case '2A', realName = 'CoilId'                                            ; % IS;1-n
        case '2B', realName = 'PatReinPattern'                                    ; % ST;1
        case '2C', realName = 'Sed'                                               ; % DS;3
        case '2D', realName = 'SARMostCriticalAspect'                             ; % DS;3
        case '2E', realName = 'Stim_mon_mode'                                     ; % IS;1
        case '2F', realName = 'GradientDelayTime'                                 ; % DS;3
        case '30', realName = 'ReadoutGradientAmplitude'                          ; % DS;1
        case '31', realName = 'AbsTablePosition'                                  ; % IS;1
        case '32', realName = 'RFSWDOperationMode'                                ; % SS;1
        case '33', realName = 'CoilForGradient2'                                  ; % SH;1
        case '34', realName = 'Stim_faktor'                                       ; % DS;1
        case '35', realName = 'Stim_max_ges_norm_online'                          ; % DS;1
        case '36', realName = 'dBdt_max'                                          ; % DS;1
        case '37', realName = 'FlowCompensation'                                  ; % DS;1 NumX - eMR Image only
        case '38', realName = 'TransmitterCalibration'                            ; % DS;1
        case '39', realName = 'MrEvaProtocol'                                     ; % OB;1 NumX eMR obsolete
        case '3B', realName = 'dBdt_limit'                                        ; % DS;1
        case '3C', realName = 'VFModelInfo'                                       ; % OB;1
        case '3D', realName = 'PhaseSliceOversampling'                            ; % CS;1
        case '3E', realName = 'VFSettings'                                        ; % OB;1
        case '3F', realName = 'AutoAlignData'                                     ; % UT;1 NumX eMR obsolete
        case '40', realName = 'FmriModelParameters'                               ; % UT;1
        case '41', realName = 'FmriModelInfo'                                     ; % UT;1
        case '42', realName = 'FmriExternalParameters'                            ; % UT;1
        case '43', realName = 'FmriExternalInfo'                                  ; % UT;1
        case '44', realName = 'B1rms'                                             ; % DS;2
        case '45', realName = 'B1rmsSupervision'                                  ; % CS;1 
        case '46', realName = 'TalesReferencePower'                               ; % DS;1 
        case '47', realName = 'SafetyStandard'                                    ; % CS;1 NumX eMR obsolete
        case '48', realName = 'DICOMImageFlavor'                                  ; % CS;1 
        case '49', realName = 'DICOMAcquisitionContrast'                          ; % CS;1 
        case '50', realName = 'RfEchoTrainLength4MF'                              ; % US;1 
        case '51', realName = 'GradientEchoTrainLength4MF'                        ; % US;1
        case '52', realName = 'VersionInfo'                                       ; % LO;1  NumX eMR obsolete
        case '53', realName = 'Laterality4MF'                                     ; % CS;1     
        case '54', realName = 'FmriAcquisitionDescriptionSequence'                ; % UT;1 NumX - eMR Image only
        case '55', realName = 'ArterialSpinLabelingContrast'                      ; % CS;1 NumX - eMR Image only
        case '56', realName = 'ConfigFileInfo'                                    ; % UT;1 NumX - eMR Image only
        case '57', realName = 'UserDefinedSeries'                                 ; % UT;1 NumX - eMR Image only
        case '58', realName = 'AASpineModelVerificationStatus'                    ; % SL;1 NumX - eMR Image only
        case '59', realName = 'AASpineModelData'                                  ; % UT;1 NumX - eMR Image only
        case '5A', realName = 'ScanningSequence'                                  ; % CS;1 NumX - eMR Image only
        case '5B', realName = 'SequenceVariant'                                   ; % CS;1 NumX - eMR Image only
        case '5C', realName = 'MeasurementOptions'                                ; % CS;1-n 
        case '5D', realName = 'ScanRegionPositionIso'                             ; % SL;1 NumX - eMR Image only
        case '5E', realName = 'FieldOfViewText'                                   ; % LO;1 NumX - eMR Image only
        case '5F', realName = 'RelTablePositionText'                              ; % SH;1 NumX - eMR Image only
        case '60', realName = 'MeasurementStartDateTime'                          ; % DT;1 NumX - eMR Image only
        case '61', realName = 'ExtendedPositionInfo'                              ; % SH;1 NumX - eMR Image only
        case '62', realName = 'RFPulseAmplitude'                                  ; % FL;1-n NumX - eMR Image only
        otherwise
            fprintf('parse_siemens_shadow WARNING: unknown series shadow header parameter %s\n', codeName);
    end
elseif (strcmp(hdrType,'SIEMENS MR MRS 05'))
    % Group SIEMENS MR MRS 05 private group
    % ElementDictionary--MR-SIEMENS_SPECTROSCOPY_SHADOW_ATTRIBUTES.xml
    switch (upper(codeName(end-1:end)))
        case '01', realName = 'TransmitterReferenceAmplitude'                     ; % FD;1
        case '02', realName = 'HammingFilterWidth'                                ; % US;1
        case '03', realName = 'CsiGridshiftVector'                                ; % FD;3
        case '04', realName = 'MixingTime'                                        ; % FD;1
        case '05', realName = 'NumberOfRepetition'                                ; % IS;1
        %case '06', realName = 'OriginalWaterReferencedSOPInstanceUID'             ; % UI;1
        %case '07', realName = 'OriginalSOPInstanceUID'                            ; % UI;1
        %case '40', realName = 'SeriesProtocolInstance'                            ; % CS;1
        %case '41', realName = 'SpectroResultType'                                 ; % CS;1
        %case '42', realName = 'SpectroResultExtendType'                           ; % CS;1
        %case '43', realName = 'PostProcProtocol'                                  ; % CS;1
        %case '44', realName = 'RescanLevel'                                       ; % CS;1
        %case '45', realName = 'SpectroAlgoResult'                                 ; % OF;1
        %case '46', realName = 'SpectroDisplayParams'                              ; % OF;1
        %case '47', realName = 'VoxelNumber'                                       ; % IS;1
        %case '48', realName = 'APRSequence'                                       ; % SQ;1
        %case '49', realName = 'SyncData'                                          ; % CS;1
        %case '4A', realName = 'PostProcDetailedProtocol'                          ; % CS;1
        %case '4B', realName = 'SpectroResultExtendTypeDetailed'                   ; % CS;1
        otherwise
            fprintf('parse_siemens_shadow WARNING: unknown MRS shadow header parameter %s\n', codeName);
    end
else
    error('NEVER HAPPEN: could not match hdrType');
end

%--------------------------------------------------------------------------

function hdr = parse_shadow_func(varargin)
% internal function to parse shadow header

% input (dcm) is uint8 using little endian ordering; since this could be
% run on a little or big endian machine, we need to interpret

debugOutput = false;

if ((nargin < 1) || (nargin > 2))
    error('invalid input arguments');
else
    dcm = varargin{1};
    if (nargin == 2), debugOutput = varargin{2}; end
end

% scan through the data byte by byte

fp = 1;

[hdr_ver, fp] = mread(dcm, fp, 4, 'char');                              % version string? 4 chars 'SV10'
[unknown_str, fp] = mread(dcm, fp, 4, 'char');                          % subversion string? 4 chars '\4\3\2\1'

if (~strcmp(hdr_ver,'SV10') || ~strcmp(unknown_str,char([4 3 2 1])))
    error('this is not a recognized SV10 format header');
end

[nelem, fp] = mread(dcm, fp, 1, 'uint32-le');                           % # of elements uint32
[sig1, fp] = mread(dcm, fp, 1, 'uint32-le');                            % unknown uint32 (signature? always 77?)

if (sig1 ~= 77)
    error('unrecognized format (%d != 77 following nelem)', sig1);
end

%fprintf('Found %d elements\n', nelem);

for y=1:nelem
    %data_start_pos = fp;
    [tag, fp] = mread(dcm, fp, 64, 'c_str');                            % element name tag c_str[64]
    tag = strrep(tag,'-','_'); % remove invalid chars from field name
    [vm, fp] = mread(dcm, fp, 1, 'uint32-le');                          % VM (value multiplier) uint32
    [vr, fp] = mread(dcm, fp, 4, 'c_str');                              % VR (value representation) c_str[4]
    [SyngoDT, fp] = mread(dcm, fp, 1, 'uint32-le');                     % SyngoDT uint32 (seems to just map to VR)
    [NoOfItems, fp] = mread(dcm, fp, 1, 'uint32-le');                   % NoOfItems uint32
    [sig2, fp] = mread(dcm, fp, 1, 'uint32-le');                        % unknown uint32 (always 77 or 205?)
    
    if ((sig2 ~= 77) && (sig2 ~= 205))
        error('unrecognized format (%d following NoOfItems)', sig2);
    end

    if (debugOutput), str_data = ''; end
    val_data = cell(NoOfItems);
    
    for z=1:NoOfItems
        [field_info, fp] = mread(dcm, fp, 4, 'uint32-le');              % field length info uint32[4]
        
        % of these 4 uint32: #0,#1,#3 should be the same (duplicates of field width); #2 is always 77/205
        if ((field_info(1) ~= field_info(2)) || (field_info(1) ~= field_info(4)))
            error('field width inconsistency (%d %d %d)', field_info(1), field_info(2), field_info(4));
        end
        if ((field_info(3) ~= 77) && (field_info(3) ~= 205))
            error('unrecognized format (%d following field width)', field_info(3));
        end
        
        % data field is padded to multiple of 4 chars
        field_width = field_info(1);
        field_padding = mod(4 - mod(field_width, 4), 4);
        field_alloc = field_width + field_padding;
        
        if (field_width > 0)
            [tmp_data, ~] = mread(dcm, fp, field_width, 'c_str');
            if (debugOutput)
                str_data = [str_data tmp_data]; %#ok<AGROW>
                if (z < NoOfItems), str_data = [str_data '\']; end %#ok<AGROW>
            end
            
            switch vr
                case {'AE','AS','CS','DA','DT','LO','LT','OB','OW','PN','SH','SQ','ST','TM','UI','UN','UT'}
                    % these are string values
                    %fprintf('String VR %s, data = %s\n',vr,str_data);
                    if (z == 1), val_data = cell(vm,1); end
                    val_data{z} = tmp_data;
                case {'IS','SL','SS','UL','US'}
                    % these are int/long values
                    %fprintf('%s: Int/Long VM %d, VR %s, data = %s, val = %d\n',tag,vm,vr,tmp_data,str2num(tmp_data));
                    if (z == 1), val_data = zeros(vm,1); end
                    if (size(tmp_data,2) > 0), val_data(z) = str2double(tmp_data); end
                case {'DS','FL','FD'}
                    % these are floating point values
                    %fprintf('%s: Float/double VM %d, VR %s, data = %s, val = %.8f\n',tag,vm,vr,tmp_data,str2num(tmp_data));
                    if (z == 1), val_data = zeros(vm,1); end
                    if (size(tmp_data,2) > 0), val_data(z) = str2double(tmp_data); end
                otherwise % just assume string
                    %error('Unknown VR = %s found!\n',vr);
                    %fprintf('Unknown VR %s, data = %s\n',vr,str_data);
                    if (z == 1), val_data = cell(vm,1); end
                    val_data{z} = tmp_data;
            end
        end
        
        fp = fp + field_alloc; % skip padding at the end of this field
    end

    if (debugOutput)
        fprintf('%2d - ''%s''\tVM %d, VR %s, SyngoDT %d, NoOfItems %d, Data',y-1, tag, vm, vr, SyngoDT, NoOfItems);
        if (size(str_data))
          fprintf(' ''%s''', str_data);
        end
        fprintf('\n');
    end

    hdr.(tag) = val_data;
end

%--------------------------------------------------------------------------

function outdata = private_field_str_fix(indata)
% internal function to convert uint8 data to to char when reading private
% dicom fields. this is sometimes necessary if the dicom file has passed
% through a 3rd-party dicom server which does not have the private fields
% in its dictionary. the fields are then converted to an unknown type,
% which is usually uint8 instead of char.

if (ischar(indata))
    outdata = indata;
elseif (isa(indata,'uint8'))
    outdata = char(indata');
else
    error('unexpected data type %s - should be char or uint8!', class(indata));
end
