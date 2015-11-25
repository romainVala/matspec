
ga_file = '/home/romain/data/spectro/PROTO_SPECTRO_DYST/LCmodel/Basis_set/MEGA2/GABA_E3_Fantome_N128.RAW';

f = read_raw(ga_file)

f = zero_filling(f,8);

ppm_g1 = 3.1009;
ppm_g2 = 2.9488;

ppm_center = 4.7;
SW_p       = f.spectrum.SW_p;	% spectral width in ppm
np         = f.spectrum.np;		% number of points

dh =  f.spectrum.SW_h / f.spectrum.n_data_points;
 
spec = fftshift(fft(f.fid),1);

i_f_inf3=round(-(ppm_g1-ppm_center)*np/SW_p+np/2)+1;
i_f_sup3=round(-(ppm_g2-ppm_center)*np/SW_p+np/2);

Agaba = sum(real(spec(i_f_inf3:i_f_sup3)))*dh;
NGABA=2;


gl_file = '/home/romain/data/spectro/PROTO_SPECTRO_DYST/LCmodel/Basis_set/MEGA2/GLU_E3_Fantome_N128.RAW';

f = read_raw(gl_file);

f = zero_filling(f,8);

ppm_g2 = 3.6972;
ppm_g1 = 3.8064;

ppm_center = 4.7;
SW_p       = f.spectrum.SW_p;	% spectral width in ppm
np         = f.spectrum.np;		% number of points

dh =  f.spectrum.SW_h / f.spectrum.n_data_points;
 
spec = fftshift(fft(f.fid),1);

i_f_inf3=round(-(ppm_g1-ppm_center)*np/SW_p+np/2)+1;
i_f_sup3=round(-(ppm_g2-ppm_center)*np/SW_p+np/2);

Aglu = sum(real(spec(i_f_inf3:i_f_sup3)))*dh;
Nglu=1;





na_file = '/home/romain/data/spectro/PROTO_SPECTRO_DYST/LCmodel/Basis_set/MEGA2/NAA_E3_Fantome_N128.RAW';

f = read_raw(na_file);

f = zero_filling(f,8);

ppm_g2 = 1.9302;
ppm_g1 = 2.0615;

ppm_center = 4.7;
SW_p       = f.spectrum.SW_p;	% spectral width in ppm
np         = f.spectrum.np;		% number of points

dh =  f.spectrum.SW_h / f.spectrum.n_data_points;
 
spec = fftshift(fft(f.fid),1);

i_f_inf3=round(-(ppm_g1-ppm_center)*np/SW_p+np/2)+1;
i_f_sup3=round(-(ppm_g2-ppm_center)*np/SW_p+np/2);

Ana = -sum(real(spec(i_f_inf3:i_f_sup3)))*dh;
Nna = 3;


