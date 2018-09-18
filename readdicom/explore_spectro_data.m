function spec_info = explore_spectro_data(P,par)

if ~exist('par'), par='';end

if  ~isfield(par,'serie_level'), par.serie_level = 1; end
if  ~isfield(par,'subject_level'), par.subject_level = 3; end

if ~exist('P')
    P = spm_select([1 Inf],'dir','Select directories of dicom files')
end

if exist('spec_info'),found=length(spec_info);else found=0;end

for nbdir=1:size(P,1)
    [afid, adcm]=spec_read_all(deblank(P(nbdir,:)));
    if ~isempty(afid)
        
        found=found+1;
        spec_info(found).fid = afid; dcm=adcm;
        
        [imghdr,serhdr,mrprot]=parse_siemens_shadow(dcm(1));
        
        Snum = sprintf('S%.2d',dcm(1).SeriesNumber);
        if isfield(dcm(1),'SeriesDescription')
            s_descrip = [dcm(1).PatientID, ' Exam ', dcm(1).StudyID ,' ', Snum, '-',dcm(1).SeriesDescription];
        else
            [pp s_descrip] = get_parent_path({deblank(P(nbdir,:))},par.serie_level) ;  s_descrip=s_descrip{1};                     
        end
        spec_info(found).Serie_description = s_descrip;
        
        [p,f] = fileparts(adcm(1).Filename);
        
        [spec_info(found).suj_dir,spec_info(found).ser_dir] = fileparts(p);
        
        spec_info(found).seqname = imghdr.SequenceName{1};
        if strcmp(spec_info(found).seqname,'eja_svs_mpress')
            spec_info(found).seqname='eja_svs_megapress';
        end
        
        if isfield(dcm(1),'PatientAge')
            spec_info(found).patient_age = dcm(1).PatientAge(1:end-1);
            spec_info(found).patient_sex = dcm(1).PatientSex;
        end
        
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
        if isfield(mrprot.sSpecPara,'lAcquisitionDelay')
            spec_info(found).TI = mrprot.sSpecPara.lAcquisitionDelay/1000;
        end
        if isfield(mrprot,'sWiPMemBlock')
            if length( mrprot.sWiPMemBlock.alFree)>25
                if isfield(mrprot,'adFlipAngleDegree')
                    if length(mrprot.adFlipAngleDegree)>=2
                        spec_info(found).Exite_angle = mrprot.adFlipAngleDegree(1);
                        spec_info(found).Refocus_angle = mrprot.adFlipAngleDegree(2);
                        spec_info(found).rf_exc_Volt = mrprot.sTXSPEC.aRFPULSE(1).flAmplitude;
                        spec_info(found).rf_ref_Volt = mrprot.sTXSPEC.aRFPULSE(2).flAmplitude;
                        spec_info(found).reference_Volt = mrprot.sTXSPEC.asNucleusInfo(1).flReferenceAmplitude;
                        spec_info(found).Refocus_pulse_dur = mrprot.sWiPMemBlock.alFree(2);
                        spec_info(found).Exite_pulse_dur = mrprot.sWiPMemBlock.alFree(25);
                        
                        spec_info(found).real_ref_FA = spec_info(found).rf_ref_Volt * 180 ./(spec_info(found).reference_Volt * ...
                            1000/spec_info(found).Refocus_pulse_dur * 400/36.711385);
                        
                        spec_info(found).real_ext_FA = spec_info(found).rf_exc_Volt * 180 ./(spec_info(found).reference_Volt * ...
                            1000/spec_info(found).Exite_pulse_dur * 400/45.490761 );
                    end
                end
                
            end
        end
        
        spec_info(found).TR =  mrprot.alTR;
        spec_info(found).TE =  mrprot.alTE;
        spec_info(found).SubjectID = [dcm(1).PatientID, '_E', dcm(1).StudyID ];

        [p,f] = get_parent_path({dcm(1).Filename},par.subject_level);
        f=f{1};
        
        spec_info(found).sujet_name =f;
        
        spec_info(found).examnumber = ['E',dcm(1).StudyID];
                       
        spec_info(found).SerDescr = s_descrip; 
        spec_info(found).studydate = dcm(1).StudyDate;
        
        spec.ppm_center = 4.7; 		% receiver (4.7 ppm)
        spec.magfield = mrprot.sProtConsistencyInfo.flNominalB0;% magnetic field (2.8936 T)
        spec.cenfreq = mrprot.sTXSPEC.asNucleusInfo(1).lFrequency/1000000;% center frequency of acquisition in Hz
        spec.SW_h=1e9/(serhdr.ReadoutOS * mrprot.sRXSPEC.alDwellTime(1));% spectral width in Hz
        spec.SW_p=spec.SW_h/spec.cenfreq;			% spectral width in ppm
        
        if isfield(imghdr,'DataPointColumns')
            spec.np = imghdr.DataPointColumns;  %in case of interpolation
        else
            spec.np=mrprot.sSpecPara.lVectorSize;	% number of points
        end
        
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
        
        try
            if isfield(mrprot.sRXSPEC,'lGain')
                seq.lgain = mrprot.sRXSPEC.lGain;
            end
            if isfield(mrprot.sSpecPara,'dSpecWaterSupprBandwidth');
                seq.WaterSupprBw = mrprot.sSpecPara.dSpecWaterSupprBandwidth;
                seq.LipidSupprBandwidth = mrprot.sSpecPara.dSpecLipidSupprBandwidth;
                %seq.PreparingScans =  mrprot.lPreparingScans;
            end
            
            seq.flRefAmp = mrprot.sTXSPEC.asNucleusInfo(1).flReferenceAmplitude;
            
            seq.bgainvalid = mrprot.sRXSPEC.bGainValid ;
            seq.Refocus_pulse_dur = mrprot.sWiPMemBlock.alFree(2);
            seq.Spoiler_dur = mrprot.sWiPMemBlock.alFree(13);
            seq.Excite_pulse_dur = mrprot.sWiPMemBlock.alFree(16);
            seq.Vapordelay8 = mrprot.sWiPMemBlock.alFree(10);
            seq.VaporDelay7 = mrprot.sWiPMemBlock.alFree(9);
            seq.VaporFA = mrprot.sWiPMemBlock.alFree(14);
            seq.HSpulseN = mrprot.sWiPMemBlock.alFree(49);
            seq.HSpulseR = mrprot.sWiPMemBlock.alFree(50);
            %seq. = mrprot.sWiPMemBlock.alFree();
        catch
            seq='oups';
        end
        
        spec_info(found).sequence = seq;
        
        spec_info(found).sertime = adcm(1).SeriesTime;
        spec_info(found).acqtime = adcm(1).AcquisitionTime;
        
        if ~isempty(which('spm_dicom_headers'))
            hh = spm_dicom_headers(adcm(1).Filename);
            hh = hh{1};
            
            [h,m,s,ms] = get_time(hh.SeriesTime);
            
            spec_info(found).sertime = datenum(sprintf('%d:%d:%d',h,m,s),'HH:MM:SS') ;
            [h,m,s,ms] = get_time(hh.AcquisitionTime);
            thedate = datestr(hh.AcquisitionDate,29);
            
            spec_info(found).acqtime = datenum(sprintf('%s %d:%d:%d',thedate,h,m,s),'yyyy-mm-dd HH:MM:SS') ;
            
        end
    end
end
