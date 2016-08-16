function fi = average_fid(fi,nb_spectra)

if ~exist('nb_spectra')
    for nbser = 1:length(fi)
        nb_spectra(nbser) = size(fi(nbser).fid,2);
    end
end


if length(fi) > length(nb_spectra)
    nb_spectra=ones(size(fi))*nb_spectra;
end

for nbser = 1:length(fi)
    
    fi(nbser).fid =sum( fi(nbser).fid(:,1:nb_spectra(nbser)),2)./nb_spectra(nbser);
    
end
