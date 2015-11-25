%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  peakremovalgui(createrdbflag,hsvdflag,datadir,rp,npeak,ncol,...
          receiveroffset_ppm,magnet,rawflag,savefid,rawfile,...
          lb,gf,sifactor,tmsampl,rmampl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% peakremovalgui.m remove selected peaks using filtered hsvd from mrui  
% to run under Sun Solaris 
% Dinesh Deelchand July 2006
% Updated Nov 2006
% Updated for GUI version (16 March 2007)
% Updated to include peak amplitude to remove (Aug 2007)
% Updated 31 July 2008 
% Updated 06 Aug 2008 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%magnet 1H frequency in MHz 
% if magnet==3
%     sfrq1H=127.8;                  
% elseif magnet==4
%     sfrq1H=169.27;               
% elseif magnet==9.4
%     sfrq1H=400.25;              
% end
sfrq1H=42.58*magnet;
%sfrq1H=400.3656;

% lcmodel parameters 
%rp : zero-order phase in deg (RUN createrbd and hsvd again)
%fidrp : zero-order phase in deg applied to RAW file
%fidlp : first-order phase in deg applied to RAW file
%sifactor : zero filling
fidrp=0;
fidlp=0;
tmsampl=tmsampl/1;			% amplitude of TMS peak

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define filename
rdb_file = 'rdb.dat';
rdb_out  = 'rdb_filtered1.dat'; 
outputflag=0;
dirname  = 'hsvd';

% verify computer MATLAB is running
pc=computer;
if pc~='SOL2'
    str = sprintf(' HSVD should be run on SUN SOLARIS machine');  error(str);
end

% verify if data path exists
if exist(datadir,'dir')~=7
    str = sprintf(' path %s not found',datadir);  error(str);
else
    curdir=pwd; cd(datadir);
end

% verify dirname path 
if exist([datadir '/' dirname],'dir')~=7
    dircheck=0;
else
    dircheck=1;
end

% read vnmr data
if createrdbflag==1
    %%%% read fid %%%%
    vnmrname = 'fid';
    fprintf(' Reading vnmr file ... \n ');
    fid = fopen([datadir '/' vnmrname],'r','ieee-be');
    if fid == -1
        str = sprintf('Can not open file %s',vnmrname);
        error(str);
    end
    
    % Read datafileheader
    nblocks   = fread(fid,1,'int32');
    ntraces   = fread(fid,1,'int32');
    np        = fread(fid,1,'int32');
    ebytes    = fread(fid,1,'int32');
    tbytes    = fread(fid,1,'int32');
    bbytes    = fread(fid,1,'int32');
    vers_id   = fread(fid,1,'int16');
    status    = fread(fid,1,'int16');
    nbheaders = fread(fid,1,'int32');
    
    s_data    = bitget(status,1);
    s_spec    = bitget(status,2);
    s_32      = bitget(status,3);
    s_float   = bitget(status,4);
    s_complex = bitget(status,5);
    s_hyper   = bitget(status,6);
    
    infohd = [nblocks; ntraces; np; ebytes; tbytes; bbytes; vers_id; status; nbheaders];
    
    % reset output structures
    RE = [];
    IM = [];
    for b = 1:nblocks
        fprintf('  read block %d\n',b)
        % Read a block header
        scale     = fread(fid,1,'int16');
        bstatus   = fread(fid,1,'int16');
        index     = fread(fid,1,'int16');
        mode      = fread(fid,1,'int16');
        ctcount   = fread(fid,1,'int32');
        lpval     = fread(fid,1,'float32');
        rpval     = fread(fid,1,'float32');
        lvl       = fread(fid,1,'float32');
        tlt       = fread(fid,1,'float32');
        
        infobk = [scale; bstatus; index; mode; ctcount; lpval; rpval; lvl; tlt];
        
        if s_float == 1
            data = fread(fid,np,'float32');
            str='   reading floats';
        elseif s_32 == 1
            data = fread(fid,np,'int32');
            str='   reading 32bit';
        else
            data = fread(fid,np,'int16');
            str='   reading 16bit';
        end
    end
    disp(str);
    RE = data(1:2:np);
    IM = data(2:2:np);   
    
    % verify number of points (np) in fid is an element of 1024 and make adjustment
    %    if np>=1024
    %        elem=mod(np/2,1024);
    %        if elem==0 %| elem<1024
    %	    rawfid=RE+1i*IM;
    %        else
    %         for ielem=1:(np/2-elem)
    %              newRE(ielem,1)=RE(ielem);
    %	      newIM(ielem,1)=IM(ielem);
    %         end    
    %         rawfid=newRE+1i*newIM;
    %         np=(np/2-elem)*2;
    %        end
    %    end
    rawfid=RE+1i*IM;
    
    %zero-order phase
    rawfid=exp(-i * (2*pi/360) * rp) * rawfid;
    newdata=zeros(length(rawfid),1);
    newdata(1:2:np)= real(rawfid);
    newdata(2:2:np)= imag(rawfid);
    data=newdata;
    
    %%%% read procpar %%%%
    procpar_file = 'procpar';
    str1 = sprintf(' Reading %s file ... ',procpar_file);
    disp(str1);
    if exist([procpar_file '.'],'file')~=2
        str2 = sprintf(' File not found %s',procpar_file);
        error(str2);
    end
    procpar=struct('sfrq',0,'sw',0);
    fileid=fopen(procpar_file);
    s=[];
    while strcmp(s,'sfrq')==0
        s=fscanf(fileid,'%s',1);
    end
    njunk=fscanf(fileid,'%f',11);
    procpar.sfrq=fscanf(fileid,'%f',1);
    s=[];
    while strcmp(s,'sw')==0
        s=fscanf(fileid,'%s',1);
    end
    njunk=fscanf(fileid,'%f',11);
    procpar.sw=fscanf(fileid,'%f',1);
    fclose(fileid);
    
    %%%% write rdb file (required to run hsvd) %%%%
    if dircheck == 0 
        mkdir(dirname);
    end
    cd(dirname);
    h_file=struct('npoints',0,'step',0,'bdelay',0,'fltrest1',zeros(1,10-3),'sfrq',0,'scans',0,'scale',0,'norm',1000,'fltrest2',zeros(1,64-10-4));
    vdata=data;
    s_vdata = size(vdata);
    if s_vdata(2) == 1  
        xnp      = s_vdata(1);
        xntraces = 1;
        xnblocks = 1;
    else
        sprintf('! can not handle data with size(): ',(s_vdata))
    end
    
    h_file.npoints = xnp;
    h_file.step    = 1000./procpar.sw;
    h_file.bdelay  = [0] * h_file.step;
    h_file.sfrq = procpar.sfrq * 1e6;
    h_file.scans = 0;
    h_file.scale = real(max(abs(vdata)));	
    bdata = reshape(vdata, 2, h_file.npoints/2, xntraces*xnblocks);   
    hrec = (64 * 4);
    bdrec = (h_file.npoints/2 * 4);	
    fprintf([' Writing rdb file \n']); 
    
    fid = fopen(rdb_file,'w','ieee-be');
    fwrite(fid,hrec,'integer*4');
    fwrite(fid,h_file.npoints,'real*4');
    fwrite(fid,h_file.step,'real*4');
    fwrite(fid,h_file.bdelay,'real*4');
    fwrite(fid,h_file.fltrest1,'real*4');
    fwrite(fid,h_file.sfrq,'real*4');
    fwrite(fid,h_file.scans,'real*4');
    fwrite(fid,h_file.scale,'real*4');
    fwrite(fid,h_file.norm,'real*4');
    fwrite(fid,h_file.fltrest2,'real*4');
    fwrite(fid,hrec,'integer*4');
    fwrite(fid,bdrec,'integer*4');
    fwrite(fid,bdata(1,:),'real*4');
    fwrite(fid,bdrec,'integer*4');
    fwrite(fid,bdrec,'integer*4');
    fwrite(fid,bdata(2,:),'real*4');
    fwrite(fid,bdrec,'integer*4');
    fclose(fid); 
else
    %%%% load rdb.dat %%%%    
    if dircheck == 0 
        str2 = sprintf(' Check location path: %s/%s/%s',datadir,dirname,rdb_file);  error(str2);
    end
    cd(dirname);
    str1 = sprintf(' Reading %s file ... \n',rdb_file);  disp(str1);
    if exist(rdb_file,'file')~=2
        str2 = sprintf(' File not found %s',rdb_file);  error(str2);
    end
    h_file=struct('npoints',0,'step',0,'bdelay',0,'fltrest1',0,'sfrq',0,'scans',0,'scale',0,'norm',1000,'fltrest2',0);
    fid = fopen(rdb_file,'r','ieee-be');
    hrec = fread(fid,1,'int32');
    h_file.npoints   = fread(fid,1,'float32');
    h_file.step      = fread(fid,1,'float32');
    h_file.bdelay    = fread(fid,1,'float32');
    h_file.fltrest1  = fread(fid,7,'float32');
    h_file.sfrq      = fread(fid,1,'float32');
    h_file.scans     = fread(fid,1,'float32');
    h_file.scale     = fread(fid,1,'float32');
    h_file.norm      = fread(fid,1,'float32');
    h_file.fltrest2  = fread(fid,50,'float32');
    hrec   = fread(fid,1,'int32');
    bdrec  = fread(fid,1,'int32');    
    RE = fread(fid,h_file.npoints/2,'float32');
    bdrec  = fread(fid,1,'int32');
    bdrec  = fread(fid,1,'int32');
    IM = fread(fid,h_file.npoints/2,'float32');
    bdrec = fread(fid,1,'int32');
    fclose(fid);
    rawfid=RE+1i*IM;
    np=h_file.npoints;    
end


%%%%  run hsvd  %%%%
if hsvdflag==1
    hsvdpath='/home/naxos/dinesh/mrui/bin/';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % hlmain usage hlmain fname ndp ncol nssv nit
    % 	fname: name of dat file 
    %   ndp:   number of data points 
    %   ncol:  size of hankel data matrix (usually ndp/2)
    %	nssv:  number of signal-related singular values (no. of peaks expected) 
    %   nit:   number of iterations (10 times number of resonances)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nit=npeak*10;
    hsvdndp=np/2;
    if (hsvdndp > 2048)
        hsvdndp = 2000;
    end
    
    if ncol==0
        msgg=sprintf(' Executing HSVD program: \n   %shlmain %s %4.0f %4.0f %4.0f %4.0f \n',hsvdpath, rdb_file, hsvdndp, hsvdndp/2, npeak, nit);
        disp(msgg);
        hlsvd = [hsvdpath,'hlmain ',rdb_file,' ',num2str(hsvdndp),' ',num2str(hsvdndp/2),' ',num2str(npeak),' ',num2str(nit)];
    else
        msgg=sprintf(' Executing HSVD program: \n   %shlmain %s %4.0f %4.0f %4.0f %4.0f \n',hsvdpath, rdb_file, hsvdndp, ncol, npeak, nit);
        disp(msgg);
        hlsvd = [hsvdpath,'hlmain ',rdb_file,' ',num2str(hsvdndp),' ',num2str(ncol),' ',num2str(npeak),' ',num2str(nit)];
    end
    eval(['! ',hlsvd,' >! junk.tmp']);
    delete('junk.tmp')
    %eval(['! ',hlsvd]);
end



%%%% process and display hsvd results %%%%
% read track.sv 
nbpeak = textread('track.sv','%*s %*d %*s %d %*s %*s');
lengthnbpeak=length(nbpeak);
nbpeak=nbpeak(lengthnbpeak);
if nbpeak>npeak
    fprintf('\n    %d peaks specified.\n',npeak)
    fprintf('    %d peaks FOUND from analysis.\n',nbpeak);
    response1=input('\nContinue ? Y/N [Y]: ','s');
    if response1=='n' | response1=='N' 
        fprintf('\n** Rerun analysis ** \n\n')
        return
    end
end

% read hsvscr.par
hsvdparfile='hsvscr.par';
fprintf('\n **** Retrieve Results ****\n');
str1 = sprintf(' Reading hsvscr.par ... \n');
disp(str1);
if exist(hsvdparfile,'file')~=2
    str2 = sprintf(' hsvscr.par not found');
    error(str2);
end
fil = fopen(hsvdparfile,'r');
pname   = fscanf(fil,' data file:    %s\n',1);
indp	= fscanf(fil,' number of data points in signal:%14d\n',1);
istep	= fscanf(fil,' step size of signal (ms):%g\n',1);
ibeg	= fscanf(fil,' begin time of signal (ms):%g\n',1);
algor   = fscanf(fil,' number of data points in %5s:',1);
nfit	= fscanf(fil,'%15d\n',1);
il		= fscanf(fil,' size parameter of hankel matrix:%14d\n',1);
nlor	= fscanf(fil,' number of frequencies:%24d\n',1);
ivarobs	= fscanf(fil,' noise standard deviation:%g\n',1);
dummy   = fscanf(fil,' root mean square of %5s fit:',1);
irms	= fscanf(fil,' %g\n',1);
ipar	= fscanf(fil,' test parameter:%31d\n',1);
while 1
    at = fscanf(fil,'%60s\n', 1);
    if strcmp(at,'fre(khz)')
        fscanf(fil,'%60s\n',3);
        break
    end
end
insv = length(textread('hsvsiv.par'));
infound	= min(nlor,insv);
par = fscanf(fil,'%g\n',[4 infound]);
fclose(fil);

% transpose rawfid
icount=1;
for ilength = 1:length(rawfid)
    forig(1,icount)=rawfid(ilength);
    icount = icount+1;
end

% separate freq, damping, amplitude and phase 
freq  = par(1,:)';
damt  = par(2,:)';
damf  = 1 ./ damt;
ampl  = par(3,:)';
phas  = par(4,:)';
if all(damt < 0)
    nrec = indp;
else
    nrec = nfit;
end

% determine ppm scale
sw=1000/h_file.step;
fmax=(sw)/2;
f=[fmax:-2*fmax/(np/2-1):-fmax];
scale_ppm=f/(h_file.sfrq/1e6)+receiveroffset_ppm;

% reconstructed signal
tstep  = h_file.step;
times  = 0:tstep:(nrec-1)*tstep;
icount=1;
xpon   = exp(times' * (damf' + i * 2 * pi * freq'));
camp   = ampl .* exp(i * phas * pi / 180);
recon  = (xpon * camp).';                   %reconstructed fid

% reverse recon and zero-filled 
if nrec < indp
    iii=1;
    for irev=length(recon):-1:1
        newrecon(irev)=recon(iii);
        iii=iii+1;
    end
    recon=newrecon;
    recon(nrec+1:indp) = zeros(1,indp-nrec);
end

% individual components
fcomp = zeros(nlor,indp);
for j = 1:nlor
    fcomp(j,1:nrec) = (xpon(1:nrec,j) * camp(j)).';
end

figure
% filtered fid
response='y';
while strcmp(response,'y') | strcmp(response,'Y')
    clear fsignew recon_pk
    % display fit
    fprintf('  Line#    shift(ppm)        dam(ms)      amp(a.u.)    phase(degr.)\n');    
    for ij=1:infound
        freq2ppm=freq(ij)*1e3/(h_file.sfrq/1e6)-receiveroffset_ppm;
        if sign(freq2ppm)==1
            freq2ppm=-freq2ppm;
        else
            freq2ppm=abs(freq2ppm);
        end		 
        fprintf('    %d %14.2f %14.6f %14.6f %14.6f \n',ij,freq2ppm,damt(ij),ampl(ij),phas(ij));
    end
    % display spectrum
    clf
    subplot(312);
    title(' Individual components')
    hold on
    for ii=1:nlor
        plot(scale_ppm,real(fftshift(fft(fcomp(ii,:)))),'b');
    end
    set(gca,'Xdir','Reverse');
    curaxis=axis;
    axis([0 6 curaxis(3) curaxis(4)]);
    useaxis=axis;
    subplot(311);
    hold on;
    plot(scale_ppm,real(fftshift(fft(forig))),'r:');
    plot(scale_ppm,real(fftshift(fft(recon))),'b'); 
    title(' Original & Reconstructed signals')
    set(gca,'Xdir','Reverse');
    axis(useaxis);
    % input peaks to remove    
    disp('           < Peak numbered from right to left on figure >');
    peaknum=0;
    xcount=0;
    while (max(peaknum) > infound) | (min(peaknum) < 1)
        clear peaknum newpeaknum 
        if xcount==1
            disp('ERROR re-enter numbers: ')
            peaknumI=input('\n ','s');
        else
            peaknumI=input('\nInput peak''s number to remove (e.g 1-5 30): ','s');   
        end
        peaknumI=sscanf(peaknumI,'%f %f %f %f %f %f %f %f %f %f %f %f');
        % generate peak numbers to remove
        peakpos=find(peaknumI < 0);
        icount=1;
        for ij=1:length(peakpos)
            for j=peaknumI(peakpos(ij)-1):1:abs(peaknumI(peakpos(ij)))
                newpeaknum(icount)=j;
                icount=icount+1;
            end
        end
        % add input peak numbers (absolute)
        for ik=1:length(peaknumI)
            newpeaknum(icount)=abs(peaknumI(ik));
            icount=icount+1; 
        end
        peaknum=unique(sort(newpeaknum));
        xcount=1;
    end
    % show selected peaks as green line
    subplot(312); hold on;
    for il=1:length(peaknum)
        recon_pk(il,:)=(xpon(:,peaknum(il)) * 1.0*camp(peaknum(il))).';
        plot(scale_ppm,real(fftshift(fft(recon_pk(il,:)))),'g')	
    end
    % construct filtered signal
    ftemp=forig;
    [msize,nsize]=size(recon_pk);
    for iq=1:msize
        fsigtemp=ftemp-recon_pk(iq,:)*rmampl;             % updated Aug 2007%
        ftemp=fsigtemp;
    end
    fsignew=ftemp;
    subplot(313);
    plot(scale_ppm,real(fftshift(fft(fsignew))),'b')
    set(gca,'Xdir','Reverse');
    title(' Filtered Signal')    
    curaxis=axis;
    axis([0 6 curaxis(3) curaxis(4)]);
    refresh
    % redo remove process
    response=input('\nReselect peak? Y/N [N]: ','s');
    if isempty(response)
        response = 'N';
    end
end


%%%% save filtered signal in .dat format %%%%
if outputflag == 1
    str1 = sprintf('\n Saving filtered signal as %s \n',rdb_out);
    disp(str1);
    RE1= real(fsignew);
    IM1= imag(fsignew);
    fid = fopen(rdb_out,'w','ieee-be');
    fwrite(fid,hrec,'integer*4');
    fwrite(fid,h_file.npoints,'real*4');
    fwrite(fid,h_file.step,'real*4');
    fwrite(fid,h_file.bdelay,'real*4');
    fwrite(fid,h_file.fltrest1,'real*4');
    fwrite(fid,h_file.sfrq,'real*4');
    fwrite(fid,h_file.scans,'real*4');
    fwrite(fid,h_file.scale,'real*4');
    fwrite(fid,h_file.norm,'real*4');
    fwrite(fid,h_file.fltrest2,'real*4');
    fwrite(fid,hrec,'integer*4');
    fwrite(fid,bdrec,'integer*4');
    fwrite(fid,RE1,'real*4');
    fwrite(fid,bdrec,'integer*4');
    fwrite(fid,bdrec,'integer*4');
    fwrite(fid,IM1,'real*4');
    fwrite(fid,bdrec,'integer*4');
    fclose(fid); 
end

FID=fsignew;
%%%% create .RAW file for LCModel %%%%
    
    % line broadening 
    t=[0:1/sw:(np-1)/sw/2]; 
    fsignew=fsignew.*exp(-t*pi*lb-t.^2/(gf^2));    
    
    % determine ppm scale
    npnew=length(fsignew);
    f=[fmax:-2*fmax/(npnew-1):-fmax];
    scale_ppm=f/(h_file.sfrq/1e6)+receiveroffset_ppm;
    
    response = 'Y';
    while strcmp(response,'Y') | strcmp(response,'y')
        % apply zero-order and first order phase
        % fsignew=exp(-i * (2*pi/360) * fidrp) * fsignew;
        pivot =[-1/(2*h_file.step): 1/((length(fsignew)-1)*h_file.step):1/(2*h_file.step)];
        phi = 2 * pi * (fidrp / 360 + fidlp * pivot);
        fsigtemp=exp(-i * phi) .* fsignew;
        
        clf
        plot(scale_ppm,real(fftshift(fft(fsigtemp))),'b');
        set(gca,'Xdir','Reverse');
        response=input('\nRe-enter phases? Y/N [Y]: ','s');
        if isempty(response) | strcmp(response,'Y') | strcmp(response,'y')
            response = 'Y';
            fidrp=input('\n Zero-order: ');
            fidlp=input('\n first-order: ');
        end
    end    
    
    % add tms peak
    tmschemshift=0;
    re=tmsampl*cos(2*pi*t*(tmschemshift-receiveroffset_ppm)*sfrq1H).*exp(-t*pi*lb-t.^2/(gf^2));
    im=tmsampl*sin(2*pi*t*(tmschemshift-receiveroffset_ppm)*sfrq1H).*exp(-t*pi*lb-t.^2/(gf^2)); 
    fsignew=fsigtemp+re-1i*im;      
    
    % zero-fill
    fsignew=[fsignew zeros(1,length(fsignew)*sifactor)];   
    
    % determine ppm scale
    npnew=length(fsignew);
    f=[fmax:-2*fmax/(npnew-1):-fmax];
    scale_ppm=f/(h_file.sfrq/1e6)+receiveroffset_ppm;
    
    clf
    plot(scale_ppm,real(fftshift(fft(fsignew))),'b')
    title(' Filtered Signal');
    set(gca,'Xdir','Reverse');
    
    % generate .RAW
    if rawflag==1
        str1 = sprintf('\n Generate %s.RAW file \n',rawfile);
        disp(str1);
        fileid=fopen([rawfile '.RAW'],'w');
        fprintf(fileid,[' $NMID ID=''' char(rawfile) ''', FMTDAT=''(8E13.5)''\n']);
        fprintf(fileid,[' TRAMP=1., VOLUME=1. $END\n']);
        fprintf(fileid,'%13.5E%13.5E%13.5E%13.5E%13.5E%13.5E%13.5E%13.5E\n',[real(fsignew); imag(fsignew)]);    
        fclose(fileid);
        str1 = sprintf('\n ***** VERIFY if TMS peak (0 ppm) is visible ***** \n');
        disp(str1);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % save as Vnmr fid in float format
    if savefid==1
        filename=rawfile; 
	
	%% Data file header
	[m,n]=size(fsignew);
	nblocks=m;
	ntraces=1;
	np=n*2;
        ebytes=4;
        tbytes=np*ebytes;
        nbheaders=1;
        bbytes=ntraces*tbytes + nbheaders*28;
        vers_id=65;
        status=25;
        nbheaders=nbheaders;
	
	%% Data block header
	scale=0;
	status=281;
	index=0;
	mode=0;
	ctcount=0;
	lpval=0;
	rpval=0;
	lvl=0;
	tlt=0;	
	
	% reorganize fid
        newdata(1:2:np)= real(fsignew);
        newdata(2:2:np)= imag(fsignew);
        data=newdata';

        fprintf([' Writing vnmr fid file: ']); 
        
        fid = fopen(filename,'w','ieee-be');
        
        % Write datafileheader
	fwrite(fid,nblocks,'int32');
	fwrite(fid,ntraces,'int32');
	fwrite(fid,np,'int32');
	fwrite(fid,ebytes,'int32');
	fwrite(fid,tbytes,'int32');
	fwrite(fid,bbytes,'int32');
	fwrite(fid,vers_id,'int16');
	fwrite(fid,status,'int16');
	fwrite(fid,nbheaders,'int32');
       
        % Write block header
	fwrite(fid,scale,'int16');
	fwrite(fid,status,'int16');
	fwrite(fid,index,'int16');
	fwrite(fid,mode,'int16');
	fwrite(fid,ctcount,'int32');
	fwrite(fid,lpval,'float32');
	fwrite(fid,rpval,'float32');
	fwrite(fid,lvl,'float32');
	fwrite(fid,tlt,'float32');    

        % Write data in float format
        fwrite(fid,data,'float32');       
        fclose(fid);
    end
    

cd(curdir);
disp(' ')
disp('Analysis done...');
return

