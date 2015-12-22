function spec_info = explore_spectro_data_ref(P)

if ~exist('P')
    P = spm_select([1 Inf],'dir','Select directories of dicom files');
end

spec_info = explore_spectro_data(P)

for nbs=1:length(spec_info)
    fnoise = spec_info(nbs);
    fnoise.fid = fnoise.fid(:,2);
    spec_info(nbs).fid = spec_info(nbs).fid(:,1);
    spec_info(nbs).fnoise=fnoise;
end

