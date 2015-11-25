% read .COORD file and plot data
% PGH Oct 2001

function lcmodelresults=readcoord(filename)

% define output structure for results

%lcmodelresults=struct('spectrumppm',0,'spectrumdata',0,'spectrumfit',0,'spectrumbasl',0,'metabconc',0,'linewidth',0,'SN',0);
%lcmodelresults.metabconc=struct('name',0,'relconc',0,'absconc',0,'SD',0);

[pathstr,fname,ext] = fileparts(filename);
lcmodelresults.name=fname;

% open .COORD file

fprintf('**** READING LCMODEL RESULTS IN .COORD FILE *****\n\n');
fprintf(['Opening file ' filename '\n']); 
fileid=fopen(filename);

% discard text until beginning of concentrations table (preceded by word 'Metab.')
go_after('Metabolite',fileid);


% read concentration values

index=1;
endtable=0;
while (endtable==0)
       lcmodelresults.metabconc(index).relconc=fscanf(fileid,'%f',1);
       lcmodelresults.metabconc(index).SD=fscanf(fileid,'%f',1);
       temp=fscanf(fileid,'%s',1);                  % read and discard '%' character
       if (temp=='lines') endtable=1; end   % if word 'lines' found then concentration table has been completely read
       lcmodelresults.metabconc(index).absconc=fscanf(fileid,'%f',1);
       lcmodelresults.metabconc(index).name=fscanf(fileid,'%s',1);
       index=index+1;
end

lcmodelresults.metabconc(end)=[]; % discard last line of table
fprintf([num2str(length(lcmodelresults.metabconc)) ' metabolite concentrations values have been read\n'])

% discard text until linewidth (preceded by word 'FWHM')


go_after('FWHM',fileid)
s=fscanf(fileid,'%s',1); % discard '='
% read linewidth
lcmodelresults.linewidth=fscanf(fileid,'%f',1);

lcmodelresults.SN = find_float_after('=',fileid);

%read data shift
lcmodelresults.data_shift = find_float_after('=',fileid);

%read phase cor
lcmodelresults.phase_cor = find_float_after('Ph:',fileid);
%read phase cor
lcmodelresults.phase1_cor = find_float_after('deg',fileid);

%lcmodelresults.BaseLineB = find_float_after('=',fileid);
%lcmodelresults.BaseLineS = find_float_after(',',fileid);

% discard text until number of data points (preceded by word 'extrema')
go_after('extr',fileid)

% read number of points

nbpoints=fscanf(fileid,'%d',1);

% read and discard text 'points on ppm-axis = NY'

s=fscanf(fileid,'%s',5);

% read ppm values
lcmodelresults.spectrumppm=fscanf(fileid,'%f',nbpoints);
fprintf([num2str(length(lcmodelresults.spectrumppm)) ' ppm values have been read\n'])

% read and discard text 'NY phased data points follow'
s=fscanf(fileid,'%s',5);

% read data values
lcmodelresults.spectrumdata=fscanf(fileid,'%f',nbpoints);
fprintf([num2str(length(lcmodelresults.spectrumdata)) ' data values have been read\n'])

% read and discard text 'NY points of the fit to the follow'
% read and discard text 'NY points of the fit to the data follow
%s=fscanf(fileid,'%s',9);
s = fgetl(fileid);
s = fgetl(fileid);

% read fit values
lcmodelresults.spectrumfit=fscanf(fileid,'%f',nbpoints);
fprintf([num2str(length(lcmodelresults.spectrumfit)) ' fit values have been read\n'])
    
% read and discard text 'NY background values follow'
%s=fscanf(fileid,'%s',4);
s = fgetl(fileid); %so you do not depend on the number of word
s = fgetl(fileid);

% read baseline values
lcmodelresults.spectrumbasl=fscanf(fileid,'%f',nbpoints);
fprintf([num2str(length(lcmodelresults.spectrumbasl)) ' baseline values have been read\n\n'])
  
% close .COORD file


l=[];
while isempty(findstr(l,'diagnostic table'))
  l=fgetl(fileid);
end

s=fscanf(fileid,'%s',1);
s=fscanf(fileid,'%s',1);
warn=[];

while strcmp(s,'warning')
  warn=[warn,fscanf(fileid,'%s',1),' ',fscanf(fileid,'%s',1)];
  s=fscanf(fileid,'%s',1);
  s=fscanf(fileid,'%s',1);
end

lcmodelresults.warning=warn;
fclose(fileid);



function go_after(str,fileid)
s=[];
while isempty(findstr(s,str))
    s=fscanf(fileid,'%s',1);
end

function f=find_float_after(str,fileid)

c=[];
while isempty(findstr(c,str))
  c=fscanf(fileid,'%s',1);
end

c(1:length(str))='';

if isempty(c)
  %read the float value
  f = fscanf(fileid,'%f',1);
else
  f = str2num(c)
end

%keyboard
