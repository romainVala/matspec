function  hsvdRAW(filename,magnet,hsvdflag,npeak,ncol)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hsvdRAW.m 
% Remove selected peaks using filtered HSVD algorithm (from mrui)  
% Use .RAW file ONLY (for Vnmr fid use peakremoval.m)
% Run under Sun Solaris 
%
% hsvdRAW(filename,magnet,hsvdflag,npeak,ncol)
% 	filename : name of .RAW file
%	magnet   : 3 or 9.4
%	hsvdflag : flag to run algorithm = 0 or 1 (default is 1)
%	npeak    : number of peaks in spectrum (default is 10)
%	ncol     : number of points to consider by hsvd (default is 1500)
% 
% Dinesh Deelchand Nov 2006
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc

if nargin<2
    error('hsvdRAW requires at least two arguments')
    return
end

if nargin<3
    hsvdflag = 1;
    npeak = 10;  
    ncol = 1500;
elseif nargin<4
    npeak = 10;  
    ncol = 1500;
elseif nargin<5
    ncol = 1500;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vnmr parameters 
if magnet == 9.4
    sfrq=400.25;
    sw=10001;
else
    sfrq=123.261;
    sw=1200;
end
receiveroffset_ppm=4.65;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% verify computer MATLAB is running
pc=computer;
if pc~='SOL2'
    str = sprintf(' HSVD should be run on SUN SOLARIS machine');  error(str);
end

% verify dirname path 
datadir=pwd;

disp(datadir);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% read RAW file %%%%
fileid=fopen([filename '.RAW'],'r');
if fileid == -1
    str = sprintf('Can not open file %s',filename); error(str);
end
s=[];
while strcmp(s,'$END')==0
    s=fscanf(fileid,'%s',1);
end
data=fscanf(fileid,'%g%g%g%g%g%g%g%g');
fclose(fileid);

j=1;
for i=1:2:length(data)
    RE(j)=data(i);
    IM(j)=data(i+1);
    j=j+1;
end
rawfid=RE+1i*IM;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% write rdb file (required by hsvd) %%%%
dirname  = 'hsvd';
if exist([datadir '/' dirname],'dir')~=7
    mkdir(dirname);
end
cd(dirname);   
h_file=struct('npoints',0,'step',0,'bdelay',0,'fltrest1',zeros(1,10-3),'sfrq',0,'scans',0,'scale',0,'norm',1000,'fltrest2',zeros(1,64-10-4));
np=size(data,1);
h_file.npoints = np;
h_file.step    = 1000./sw;
h_file.bdelay  = [0] * h_file.step;
h_file.sfrq = sfrq * 1e6;
h_file.scans = 0;
h_file.scale = real(max(abs(data)));	

if hsvdflag == 1
    bdata = reshape(data, 2, h_file.npoints/2, 1*1);   
    hrec = (64 * 4);
    bdrec = (h_file.npoints/2 * 4);	
    rdb_file = [filename '.dat'];
    disp(sprintf('\n Writing rdb file: %s\n',rdb_file))
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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  run hsvd  %%%%
if hsvdflag==1
    hsvdpath='/home/naxos/dinesh/mrui/bin/';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % hlmain usage hlmain fname ndp ncol nssv nit
    % 	fname: name of dat file 
    %   ndp:   number of data points 
    %   ncol:  size of hankel data matrix (usually ndp/2)
    %	nssv:  number of signal-related singular values (no. of peaks
    %	expected) nit:   number of iterations (10 times number of
    %	resonances)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nit=npeak*10;
    hsvdndp=np/2;
    if (hsvdndp > 2048)
        hsvdndp = 2048;
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
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% process and display hsvd results %%%%
% read track.sv 
nbpeak = textread('track.sv','%*s %*d %*s %d %*s %*s');
lengthnbpeak=length(nbpeak);
nbpeak=nbpeak(lengthnbpeak);
if nbpeak>npeak
    %    fprintf('\n    %d peaks specified.\n',npeak)
    %    fprintf('    %d peaks FOUND from analysis.\n',nbpeak);
    %    response1=input('\nContinue ? Y/N [N]: ','s');
    %    if isempty(response1) | response1=='n' | response1=='N' 
    %	fprintf('\n** Rerun analysis ** \n\n')
    %        return
    %    end
end

% read hsvpol.par
fprintf('\n **** Retrieve Results ****\n');
str1 = sprintf(' Reading hsvpol.par ... \n');
disp(str1);
[insv,polesr,polesi] = textread('hsvpol.par');
poles=polesr+1i*polesi;
insv=length(insv);

% clean up unnecessary files
if hsvdflag == 1 
    delete sinval.dat hsvscr.par hsvsiv.par
end
cd(datadir);

% separate freq, damping, amplitude and phase  
str1 = sprintf(' Generating reconstructed signals ... \n');
disp(str1);
lpoles = log(poles.');
nrec=np/2;
infound	= min(npeak,insv);

x      = zeros(nrec,infound);
c      = zeros(infound,1);
tstep  	    = h_file.step;
times       = 0:1:(nrec-1);
x(1:nrec,:) = exp(times' * lpoles);
c           = x \ rawfid(1,1:nrec).';
recon       = (x * c).';		%reconstructed fid
fre         = imag(lpoles) / (2 * pi * tstep);

% determine ppm scale
sw=1000/h_file.step;
fmax=(sw)/2;
f=[fmax:-2*fmax/(np/2-1):-fmax];
scale_ppm=f/(h_file.sfrq/1e6)+receiveroffset_ppm;    

% individual components
fcomp = zeros(infound,insv);
for j = 1:infound
    fcomp(j,1:nrec) = (x(1:nrec,j) * c(j)).';
end   

% filtered fid
response='y';
forig=rawfid;
while strcmp(response,'y') | strcmp(response,'Y')
    clear fsignew recon_pk
    % display fit
    fprintf('  Line#    shift(ppm)        amp(a.u.)\n');    
    for ij=1:infound
        freq2ppm=fre(ij)*1e3/(h_file.sfrq/1e6)-receiveroffset_ppm;
        if sign(freq2ppm)==1
            freq2ppm=-freq2ppm;
        else
            freq2ppm=abs(freq2ppm);
        end		 
        fprintf('    %d %14.2f %14.0f \n',ij,freq2ppm,abs(c(ij)));
    end
    % display spectrum
    clf
    subplot(312);
    title(' Individual components')
    hold on
    for ii=1:infound
        plot(scale_ppm,real(fftshift(fft(fcomp(ii,:)))),'b');
    end
    set(gca,'Xdir','Reverse');
    curaxis=axis;
    axis([-1 6 curaxis(3) curaxis(4)]);
    useaxis=axis;
    subplot(311);
    hold on;
    plot(scale_ppm,real(fftshift(fft(forig))),'r:');
    plot(scale_ppm,real(fftshift(fft(recon))),'b'); 
    title(' Original (red) & Reconstructed (blue) signals')
    set(gca,'Xdir','Reverse');
    axis(useaxis);
    % input peaks to remove    
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
        recon_pk(il,:)=(x(:,peaknum(il)) * 1.0*c(peaknum(il))).';
        plot(scale_ppm,real(fftshift(fft(recon_pk(il,:)))),'g')	
    end
    % construct filtered signal
    ftemp=forig;
    [msize,nsize]=size(recon_pk);
    for iq=1:msize
        fsigtemp=ftemp-recon_pk(iq,:);
        ftemp=fsigtemp;
    end
    fsignew=ftemp;
    subplot(313);
    plot(scale_ppm,real(fftshift(fft(fsignew))),'b')
    set(gca,'Xdir','Reverse');
    title(' Filtered Signal')    
    curaxis=axis;
    axis([-1 6 curaxis(3) curaxis(4)]);
    refresh
    % redo remove process
    response=input('\nReselect peak? Y/N [N]: ','s');
    if isempty(response)
        response = 'N';
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% create .RAW file for LCModel %%%%
FID=fsignew
rawflag=1;
if rawflag == 1
    rawfile = [filename '_s.RAW'];
    if exist(rawfile,'file') == 2
        str1 = sprintf('\n %s EXISTS	',rawfile); disp(str1);
        response1=input(' Do you want to overwrite?? y/n [y]: ','s');
        if response1=='n' | response1=='n'
            disp('Aborted')
            return
        end
    end
    str1 = sprintf('\n Saving %s \n',rawfile); disp(str1);
    
    figure
    plot(scale_ppm,real(fftshift(fft(fsignew))),'b')
    title(' Filtered Signal');
    set(gca,'Xdir','Reverse');   
    
    % generate .RAW file
    fileid=fopen(rawfile,'w');
    fprintf(fileid,[' $NMID ID=''' char(rawfile) ''', FMTDAT=''(8E13.5)''\n']);
    fprintf(fileid,[' TRAMP=1., VOLUME=1. $END\n']);
    fprintf(fileid,'%13.5E%13.5E%13.5E%13.5E%13.5E%13.5E%13.5E%13.5E\n',[real(fsignew); imag(fsignew)]);    
    fclose(fileid);
end



