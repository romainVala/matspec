function write_water_fid_to_lcRAW(fids,subdir,root_dir)


gessfile=1;

if nargin==1
  subdir = 0;
end

if ~exist('subdir')
  subdir = 0;
end
if ~exist('root_dir')
  root_dir=pwd;%'/homenasFC1/romain_sun/data/spectro/PROTO_SPECTRO_DYST/LCmodel/Raw';
  root_dir = spm_select(1,'dir','select a dir to save raw file in','',root_dir)
end


for nbser = 1:length(fids)

  if subdir
    %make subdir for suj name
    suj_dir = fullfile(root_dir,fids(nbser).sujet_name);
    if ~exist(suj_dir)
      mkdir(suj_dir)
    end
  else
    suj_dir = root_dir;
  end

  cenfreq    = fids(nbser).spectrum.cenfreq;	% center frequency of acquisition in Hz
  np         = fids(nbser).spectrum.np;		% number of points
  dw         = fids(nbser).spectrum.dw;		% dwell time	

  
  if findstr(fids(nbser).seqname,'mega')
    fid = fids(nbser).fid;  
    ns = size(fid,2)/2;
  
    fid1 = fid(:,1:ns);
    fid2 = fid(:,(ns+1):end);
    fid1m = mean(fid1,2);
    fid2m = mean(fid2,2);
  
    %  fid_lc = transpose(fid{nbser});
    fid_lc =  fid1m;
  else
    fid = fids(nbser).fid;
    fid_lc = mean(fid,2);
  end

  dif_fid = [real(fid_lc) imag(fid_lc)];
      
  rp=0;		% zero order phase correction - LCModel
  lp=0;		% first order phase correction - LCModel
  
  if gessfile

    %  file_name = nettoie_dir(fid(nbser).Serie_description);
    fname = [fids(nbser).sujet_name,' ',fids(nbser).examnumber,' ',fids(nbser).SerDescr];
    %      fname = [fids(nbser).sujet_name,' ',' ',fids(nbser).SerDescr];
    file_name = nettoie_dir(fname);
    filename = fullfile(suj_dir,[file_name,'.H2O']);
  end
  
  createrawfile_mm_3T_CENIR(filename,dif_fid,cenfreq,np,dw,rp,lp);
      
end
