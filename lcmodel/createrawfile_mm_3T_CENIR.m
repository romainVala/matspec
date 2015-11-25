%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% createrawfile.m
%
% PGH Oct 2003
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y=createrawfile(metabname,fid,cenfreq,np,dw,rp,lp,TRAMP,VOLUME)

[p f e] = fileparts(metabname)
if ~isempty(e)
  rawfilename = metabname;
  metabname = fullfile(p,f)
else
  rawfilename=[metabname '.RAW'];
end

plotinfilename=[metabname '.PLOTIN'];


%declareglobalparams; % declare parameters used in other subprograms

% generate .RAW file for LCModel


%fid=fid(:,1)+1i*fid(:,2);

%fid=[real(fid) imag(fid)];

disp(['Creating file ' rawfilename]);

fileid=fopen( rawfilename,'w');


fprintf(fileid,' $SEQPAR\n');
fprintf(fileid,[' SEQ=''MEGA''\n']);
fprintf(fileid,' $END\n\n');

fprintf(fileid,[' $NMID ID=''' rawfilename ''', FMTDAT=''(8E13.5)''\n']);
fprintf(fileid,' TRAMP=%0.4f , VOLUME=%0.4f  $END\n',TRAMP,VOLUME);
fprintf(fileid,'%13.5E%13.5E%13.5E%13.5E%13.5E%13.5E%13.5E%13.5E\n',fid'); 

fclose(fileid);

% generate .PLOTIN file for PlotRaw

disp(['Creating file ' plotinfilename]); disp(' ')

fileid=fopen( plotinfilename,'w');

fprintf(fileid,' $PLTRAW\n');
fprintf(fileid,[' HZPPPM=' num2str(cenfreq) '\n']);
fprintf(fileid,[' NUNFIL=' num2str(np) '\n']);
fprintf(fileid,[' DELTAT=' num2str(dw) '\n']);
fprintf(fileid,[' FILRAW=''' rawfilename '''\n']);
fprintf(fileid,[' FILPS=''' metabname '.PS''\n']);
fprintf(fileid,[' DEGZER=' num2str(-(rp+0.5*lp)) '\n']);
fprintf(fileid,[' DEGPPM=' num2str(-lp/((1/dw)/cenfreq)) '\n']);
fprintf(fileid,' $END\n');

fclose(fileid);


