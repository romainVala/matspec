%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Freq + Phase correction + sum of an array of FIDs  %%%%%%%%%%%%%
%%%%		JV    13/12/04                                 %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SUM fid_cor] = add_array_scans(DATA,SW_h,SW_p,ppm_center)

global spec_total fid_metab ppm_center SW_p zero_filling pas_temps

NS=size(DATA,1);
zero_filling=size(DATA,2);

pas_temps=1/SW_h;	% pas (en s) entre 2 points complexes successifs;

fprintf('Adding scans: processing (be patient...)\n');

h = waitbar(0,'Adding, please wait...');
count=0;

spec_total=zeros(1,zero_filling);
SUM=zeros(1,zero_filling);

for scan=1:NS
    
	fid_metab=squeeze(DATA(scan,:));
            
	spec_metab=fftshift(fft(fid_metab));
    
	spec_total=spec_total+spec_metab;
    
end

spec_total=spec_total/NS;

for scan=1:NS
    
	fid_metab0=squeeze(DATA(scan,:));
	fid_metab=fid_metab0;
    
    	%% Freq correction
    
	x=lsqnonlin('cout_nu',[1 0],[0.1 -50],[10 50]);           
    
	factor=x(1);
	delta_nu=x(2);

	k=(1:1:zero_filling);

	correction(k)=exp(2*pi*1i*delta_nu*(k-1)*pas_temps);

	fid_metab0=fid_metab0.*correction;
	fid_metab=factor*fid_metab.*correction;
                
	spec_metab=fftshift(fft(fid_metab));  
 
	%% Phase correction
    
	phi=lsqnonlin('cout_phase',[0],[-pi],[pi]);     
    
	fid_metab=exp(1i*phi)*fid_metab0;
    
	SUM=SUM+fid_metab;
    
	count=count+1;      
	waitbar(count/NS);

	fid_cor(scan,:) = fid_metab;

end

SUM=SUM/NS;

close(h);

fprintf('Adding scans: OK\n');

f=figure;
figure(f);
hold on;
plot(real(spec_total),'r');
plot(real(fftshift(fft(SUM))));
