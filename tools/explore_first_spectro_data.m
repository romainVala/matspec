function spec_info = explore_spectro_data(P)

if ~exist('P')
  P = spm_select([1 Inf],'dir','Select directories of dicom files') 
end

if exist('spec_info'),found=length(spec_info);else found=0;end

for nbdir=1:size(P,1)
  [afid, adcm]=spec_read_first(deblank(P(nbdir,:))); 
  if ~isempty(afid)
    found=found+1;
    spec_info(found).fid = afid; dcm=adcm;
  
    [imghdr,serhdr,mrprot]=parse_siemens_shadow(dcm(1));

    Snum = sprintf('S%.2d',dcm(1).SeriesNumber);
    s_descrip = [dcm(1).PatientID, ' Exam ', dcm(1).StudyID ,' ', Snum, '-',dcm(1).SeriesDescription];
    spec_info(found).Serie_description = s_descrip;

    spec_info(found).seqname = imghdr.SequenceName{1};
    
    spec_info(found).patient_age = dcm(1).PatientAge(1:end-1);
    
    spec_info(found).mega_ws=serhdr.MiscSequenceParam(12);
    if mrprot.sPrepPulses.ucWaterSat ==64
      spec_info(found).vapor_ws=0;
    elseif  mrprot.sPrepPulses.ucWaterSat ==1
      spec_info(found).vapor_ws=1;
    else
      spec_info(found).vapor_ws=-1;
    end
    spec_info(found).Nex = imghdr.NumberOfAverages;
    spec_info(found).Number_of_spec = size(spec_info(found).fid,2);
    spec_info(found).TI = mrprot.sSpecPara.lAcquisitionDelay/1000;
    spec_info(found).TR =  mrprot.alTR;
    spec_info(found).TE =  mrprot.alTE;
    spec_info(found).SubjectID = [dcm(1).PatientID, '_E', dcm(1).StudyID ];    

[p,f]=fileparts(dcm(1).Filename);
[p,f] = fileparts(p);
[p,f] = fileparts(p);
if length(f)>26
  spec_info(found).sujet_name = f(21:27);
else
  spec_info(found).sujet_name =f;
end
spec_info(found).examnumber = ['E',dcm(1).StudyID];


    SerDescr = dcm(1).SeriesDescription;
    if  findstr(SerDescr,'MEGA-PRESS '); SerDescr(1:11)='';end
    if  findstr(SerDescr,'matrix '); SerDescr(1:7)='';end
    
    spec_info(found).SerDescr = SerDescr; clear SerDescr;
    spec_info(found).studydate = dcm(1).StudyDate;
   
    spec.ppm_center = 4.7; 		% receiver (4.7 ppm)
    spec.magfield = mrprot.sProtConsistencyInfo.flNominalB0;% magnetic field (2.8936 T)
    spec.cenfreq = mrprot.sTXSPEC.asNucleusInfo(1).lFrequency/1000000;% center frequency of acquisition in Hz
    spec.SW_h=1e9/(serhdr.ReadoutOS * mrprot.sRXSPEC.alDwellTime(1));% spectral width in Hz
    spec.SW_p=spec.SW_h/spec.cenfreq;			% spectral width in ppm
    spec.np=mrprot.sSpecPara.lVectorSize;	% number of points
    spec.dw=1/(spec.SW_h);				% dwell time

    spec.n_data_points  = spec.np;
    spec.spectral_widht = spec.SW_h;
    spec.FreqAt0        = spec.SW_h/2;
    spec.synthesizer_frequency = spec.cenfreq;
    spec.Freq_order = 1;
    spec.spectrum_offset_frequency=0;

    spec_info(found).spectrum=spec;
    
    Pos.VoiFOV = [ imghdr.VoiReadoutFoV imghdr.VoiPhaseFoV imghdr.VoiThickness];
    Pos.VoiOrientation = reshape(imghdr.ImageOrientationPatient,[3,2]);
    Pos.VoiPosition = imghdr.VoiPosition;
    spec_info(found).Pos = Pos;

  end
end
