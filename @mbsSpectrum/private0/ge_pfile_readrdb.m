function rdb = readrdb(lun)
% GEMSBG Include File
% Copyright (C) 1992 The General Electric Company
% $Source: rdbm.h $
% $Revision: 1.23 $  $Date: 4/4/94 12:41:07 $
%
% adapted to matlab code by DB Clayton - 2003 Jan 30
%-

ACQ_TAB_SIZE = 20480; % LX 7.x

rdb.rdbm_rev           = fread(lun, 1, 'float');
if (rdb.rdbm_rev >= 8.)
  ACQ_TAB_SIZE = 40960; % LX 8.x
end
rdb.run_int            = fread(lun, 1, 'long');
rdb.scan_seq           = fread(lun, 1, 'short');
rdb.run_char           = fread(lun, 6, '*char');
rdb.scan_date          = fread(lun, 10, '*char');
rdb.scan_time          = fread(lun, 8, '*char');
rdb.logo               = fread(lun, 10, '*char');

rdb.file_contents      = fread(lun, 1, 'short');
rdb.lock_mode          = fread(lun, 1, 'short');
rdb.dacq_ctrl          = fread(lun, 1, 'short');
rdb.recon_ctrl         = fread(lun, 1, 'short');
rdb.exec_ctrl          = fread(lun, 1, 'short');
rdb.scan_type          = fread(lun, 1, 'short');
rdb.data_collect_type  = fread(lun, 1, 'short');
rdb.data_format        = fread(lun, 1, 'short');
rdb.recon              = fread(lun, 1, 'short');
rdb.datacq             = fread(lun, 1, 'short');

rdb.npasses            = fread(lun, 1, 'short');
rdb.npomp              = fread(lun, 1, 'short');
rdb.nslices            = fread(lun, 1, 'short');
rdb.nechoes            = fread(lun, 1, 'short');
rdb.navs               = fread(lun, 1, 'short');
rdb.nframes            = fread(lun, 1, 'short');
rdb.baseline_views     = fread(lun, 1, 'short');
rdb.hnover             = fread(lun, 1, 'short');
rdb.frame_size         = fread(lun, 1, 'short');
rdb.point_size         = fread(lun, 1, 'short');

rdb.vquant             = fread(lun, 1, 'short');

rdb.cheart             = fread(lun, 1, 'short');
rdb.ctr                = fread(lun, 1, 'float');
rdb.ctrr               = fread(lun, 1, 'float');

rdb.initpass           = fread(lun, 1, 'short');
rdb.incrpass           = fread(lun, 1, 'short');

rdb.method_ctrl        = fread(lun, 1, 'short');
rdb.da_xres            = fread(lun, 1, 'short');
rdb.da_yres            = fread(lun, 1, 'short');
rdb.rc_xres            = fread(lun, 1, 'short');
rdb.rc_yres            = fread(lun, 1, 'short');
rdb.im_size            = fread(lun, 1, 'short');
rdb.rc_zres            = fread(lun, 1, 'long');

rdb.raw_pass_size      = fread(lun, 1, 'long');
rdb.sspsave            = fread(lun, 1, 'long');
rdb.udasave            = fread(lun, 1, 'long');

rdb.fermi_radius       = fread(lun, 1, 'float');
rdb.fermi_width        = fread(lun, 1, 'float');
rdb.fermi_ecc          = fread(lun, 1, 'float');
rdb.clip_min           = fread(lun, 1, 'float');
rdb.clip_max           = fread(lun, 1, 'float');
rdb.default_offset     = fread(lun, 1, 'float');
rdb.xoff               = fread(lun, 1, 'float');
rdb.yoff               = fread(lun, 1, 'float');
rdb.nwin               = fread(lun, 1, 'float');
rdb.ntran              = fread(lun, 1, 'float');
rdb.scalei             = fread(lun, 1, 'float');
rdb.scaleq             = fread(lun, 1, 'float');
rdb.rotation           = fread(lun, 1, 'short');
rdb.transpose          = fread(lun, 1, 'short');
rdb.kissoff_views      = fread(lun, 1, 'short');
rdb.slblank            = fread(lun, 1, 'short');
rdb.gradcoil           = fread(lun, 1, 'short');
rdb.ddaover            = fread(lun, 1, 'short');

rdb.sarr               = fread(lun, 1, 'short');
rdb.fd_tr              = fread(lun, 1, 'short');
rdb.fd_te              = fread(lun, 1, 'short');
rdb.fd_ctrl            = fread(lun, 1, 'short');
rdb.algor_num          = fread(lun, 1, 'short');
rdb.fd_df_dec          = fread(lun, 1, 'short');

rdb.dab_start_rcv0     = fread(lun, 1, 'short');
rdb.dab_stop_rcv0      = fread(lun, 1, 'short');
rdb.dab_start_rcv1     = fread(lun, 1, 'short');
rdb.dab_stop_rcv1      = fread(lun, 1, 'short');
rdb.dab_start_rcv2     = fread(lun, 1, 'short');
rdb.dab_stop_rcv2      = fread(lun, 1, 'short');
rdb.dab_start_rcv3     = fread(lun, 1, 'short');
rdb.dab_stop_rcv3      = fread(lun, 1, 'short');

rdb.user0              = fread(lun, 1, 'float');
rdb.user1              = fread(lun, 1, 'float');
rdb.user2              = fread(lun, 1, 'float');
rdb.user3              = fread(lun, 1, 'float');
rdb.user4              = fread(lun, 1, 'float');
rdb.user5              = fread(lun, 1, 'float');
rdb.user6              = fread(lun, 1, 'float');
rdb.user7              = fread(lun, 1, 'float');
rdb.user8              = fread(lun, 1, 'float');
rdb.user9              = fread(lun, 1, 'float');
rdb.user10             = fread(lun, 1, 'float');
rdb.user11             = fread(lun, 1, 'float');
rdb.user12             = fread(lun, 1, 'float');
rdb.user13             = fread(lun, 1, 'float');
rdb.user14             = fread(lun, 1, 'float');
rdb.user15             = fread(lun, 1, 'float');
rdb.user16             = fread(lun, 1, 'float');
rdb.user17             = fread(lun, 1, 'float');
rdb.user18             = fread(lun, 1, 'float');
rdb.user19             = fread(lun, 1, 'float');

rdb.v_type             = fread(lun, 1, 'long');
rdb.v_coefxa           = fread(lun, 1, 'float');
rdb.v_coefxb           = fread(lun, 1, 'float');
rdb.v_coefxc           = fread(lun, 1, 'float');
rdb.v_coefxd           = fread(lun, 1, 'float');
rdb.v_coefya           = fread(lun, 1, 'float');
rdb.v_coefyb           = fread(lun, 1, 'float');
rdb.v_coefyc           = fread(lun, 1, 'float');
rdb.v_coefyd           = fread(lun, 1, 'float');
rdb.v_coefza           = fread(lun, 1, 'float');
rdb.v_coefzb           = fread(lun, 1, 'float');
rdb.v_coefzc           = fread(lun, 1, 'float');
rdb.v_coefzd           = fread(lun, 1, 'float');
rdb.vm_coef1           = fread(lun, 1, 'float');
rdb.vm_coef2           = fread(lun, 1, 'float');
rdb.vm_coef3           = fread(lun, 1, 'float');
rdb.vm_coef4           = fread(lun, 1, 'float');
rdb.v_venc             = fread(lun, 1, 'float');

rdb.spectral_width     = fread(lun, 1, 'float');
rdb.csi_dims           = fread(lun, 1, 'short');
rdb.xcsi               = fread(lun, 1, 'short');
rdb.ycsi               = fread(lun, 1, 'short');
rdb.zcsi               = fread(lun, 1, 'short');
rdb.roilenx            = fread(lun, 1, 'float');
rdb.roileny            = fread(lun, 1, 'float');
rdb.roilenz            = fread(lun, 1, 'float');
rdb.roilocx            = fread(lun, 1, 'float');
rdb.roilocy            = fread(lun, 1, 'float');
rdb.roilocz            = fread(lun, 1, 'float');
rdb.numdwell           = fread(lun, 1, 'float');

rdb.ps_command         = fread(lun, 1, 'long');
rdb.ps_mps_r1          = fread(lun, 1, 'long');
rdb.ps_mps_r2          = fread(lun, 1, 'long');
rdb.ps_mps_tg          = fread(lun, 1, 'long');
rdb.ps_mps_freq        = fread(lun, 1, 'long');
rdb.ps_aps_r1          = fread(lun, 1, 'long');
rdb.ps_aps_r2          = fread(lun, 1, 'long');
rdb.ps_aps_tg          = fread(lun, 1, 'long');
rdb.ps_aps_freq        = fread(lun, 1, 'long');
rdb.ps_scalei          = fread(lun, 1, 'float');
rdb.ps_scaleq          = fread(lun, 1, 'float');
rdb.ps_snr_warning     = fread(lun, 1, 'long');
rdb.ps_aps_or_mps      = fread(lun, 1, 'long');
rdb.ps_mps_bitmap      = fread(lun, 1, 'long');
rdb.ps_powerspec       = fread(lun, 256, '*char');
rdb.ps_filler1         = fread(lun, 1, 'long');
rdb.ps_filler2         = fread(lun, 1, 'long');

rdb.rec_noise_mean0    = fread(lun, 1, 'float');
rdb.rec_noise_mean1    = fread(lun, 1, 'float');
rdb.rec_noise_mean2    = fread(lun, 1, 'float');
rdb.rec_noise_mean3    = fread(lun, 1, 'float');
rdb.rec_noise_mean4    = fread(lun, 1, 'float');
rdb.rec_noise_mean5    = fread(lun, 1, 'float');
rdb.rec_noise_mean6    = fread(lun, 1, 'float');
rdb.rec_noise_mean7    = fread(lun, 1, 'float');
rdb.rec_noise_mean8    = fread(lun, 1, 'float');
rdb.rec_noise_mean9    = fread(lun, 1, 'float');
rdb.rec_noise_mean10   = fread(lun, 1, 'float');
rdb.rec_noise_mean11   = fread(lun, 1, 'float');
rdb.rec_noise_mean12   = fread(lun, 1, 'float');
rdb.rec_noise_mean13   = fread(lun, 1, 'float');
rdb.rec_noise_mean14   = fread(lun, 1, 'float');
rdb.rec_noise_mean15   = fread(lun, 1, 'float');
rdb.rec_noise_std0     = fread(lun, 1, 'float');
rdb.rec_noise_std1     = fread(lun, 1, 'float');
rdb.rec_noise_std2     = fread(lun, 1, 'float');
rdb.rec_noise_std3     = fread(lun, 1, 'float');
rdb.rec_noise_std4     = fread(lun, 1, 'float');
rdb.rec_noise_std5     = fread(lun, 1, 'float');
rdb.rec_noise_std6     = fread(lun, 1, 'float');
rdb.rec_noise_std7     = fread(lun, 1, 'float');
rdb.rec_noise_std8     = fread(lun, 1, 'float');
rdb.rec_noise_std9     = fread(lun, 1, 'float');
rdb.rec_noise_std10    = fread(lun, 1, 'float');
rdb.rec_noise_std11    = fread(lun, 1, 'float');
rdb.rec_noise_std12    = fread(lun, 1, 'float');
rdb.rec_noise_std13    = fread(lun, 1, 'float');
rdb.rec_noise_std14    = fread(lun, 1, 'float');
rdb.rec_noise_std15    = fread(lun, 1, 'float');

rdb.halfecho           = fread(lun, 1, 'short');

rdb.im_size_y          = fread(lun, 1, 'short');
rdb.data_collect_type1 = fread(lun, 1, 'long');
rdb.freq_scale         = fread(lun, 1, 'float');
rdb.phase_scale        = fread(lun, 1, 'float');
rdb.ovl                = fread(lun, 1, 'short');

rdb.pclin              = fread(lun, 1, 'short');
rdb.pclinnpts          = fread(lun, 1, 'short');
rdb.pclinorder         = fread(lun, 1, 'short');
rdb.pclinavg           = fread(lun, 1, 'short');
rdb.pccon              = fread(lun, 1, 'short');
rdb.pcconnpts          = fread(lun, 1, 'short');
rdb.pcconorder         = fread(lun, 1, 'short');
rdb.pcextcorr          = fread(lun, 1, 'short');
rdb.pcgraph            = fread(lun, 1, 'short');
rdb.pcileave           = fread(lun, 1, 'short');
rdb.hdbestky           = fread(lun, 1, 'short');
rdb.pcctrl             = fread(lun, 1, 'short');
rdb.pcthrespts         = fread(lun, 1, 'short');
rdb.pcdiscbeg          = fread(lun, 1, 'short');
rdb.pcdiscmid          = fread(lun, 1, 'short');
rdb.pcdiscend          = fread(lun, 1, 'short');
rdb.pcthrespct         = fread(lun, 1, 'short');
rdb.pcspacial          = fread(lun, 1, 'short');
rdb.pctemporal         = fread(lun, 1, 'short');
rdb.pcspare            = fread(lun, 1, 'short');
rdb.ileaves            = fread(lun, 1, 'short');
rdb.kydir              = fread(lun, 1, 'short');
rdb.alt                = fread(lun, 1, 'short');
rdb.reps               = fread(lun, 1, 'short');
rdb.ref                = fread(lun, 1, 'short');

rdb.pcconnorm          = fread(lun, 1, 'float');
rdb.pcconfitwt         = fread(lun, 1, 'float');
rdb.pclinnorm          = fread(lun, 1, 'float');
rdb.pclinfitwt         = fread(lun, 1, 'float');

rdb.pcbestky           = fread(lun, 1, 'float');

rdb.vrgf               = fread(lun, 1, 'long');
rdb.vrgfxres           = fread(lun, 1, 'long');

rdb.bp_corr            = fread(lun, 1, 'long');
rdb.recv_freq_s        = fread(lun, 1, 'float');
rdb.recv_freq_e        = fread(lun, 1, 'float');

rdb.hniter             = fread(lun, 1, 'long');

rdb.fast_rec           = fread(lun, 1, 'long');

rdb.refframes          = fread(lun, 1, 'long');
rdb.refframep          = fread(lun, 1, 'long');
rdb.scnframe           = fread(lun, 1, 'long');
rdb.pasframe           = fread(lun, 1, 'long');

rdb.user_usage_tag     = fread(lun, 1, 'ulong');
rdb.user_fill_mapMSW   = fread(lun, 1, 'ulong');
rdb.user_fill_mapLSW   = fread(lun, 1, 'ulong');

rdb.user20	       = fread(lun, 1, 'float');
rdb.user21	       = fread(lun, 1, 'float');
rdb.user22	       = fread(lun, 1, 'float');
rdb.user23	       = fread(lun, 1, 'float');
rdb.user24	       = fread(lun, 1, 'float');
rdb.user25	       = fread(lun, 1, 'float');
rdb.user26	       = fread(lun, 1, 'float');
rdb.user27	       = fread(lun, 1, 'float');
rdb.user28	       = fread(lun, 1, 'float');
rdb.user29	       = fread(lun, 1, 'float');
rdb.user30	       = fread(lun, 1, 'float');
rdb.user31	       = fread(lun, 1, 'float');
rdb.user32	       = fread(lun, 1, 'float');
rdb.user33	       = fread(lun, 1, 'float');
rdb.user34	       = fread(lun, 1, 'float');
rdb.user35	       = fread(lun, 1, 'float');
rdb.user36	       = fread(lun, 1, 'float');
rdb.user37	       = fread(lun, 1, 'float');
rdb.user38	       = fread(lun, 1, 'float');
rdb.user39	       = fread(lun, 1, 'float');
rdb.user40	       = fread(lun, 1, 'float');
rdb.user41	       = fread(lun, 1, 'float');
rdb.user42	       = fread(lun, 1, 'float');
rdb.user43	       = fread(lun, 1, 'float');
rdb.user44	       = fread(lun, 1, 'float');
rdb.user45	       = fread(lun, 1, 'float');
rdb.user46	       = fread(lun, 1, 'float');
rdb.user47	       = fread(lun, 1, 'float');
rdb.user48	       = fread(lun, 1, 'float');

rdb.pcfitorig          = fread(lun, 1, 'short');
rdb.pcshotfirst        = fread(lun, 1, 'short');
rdb.pcshotlast         = fread(lun, 1, 'short');
rdb.pcmultegrp         = fread(lun, 1, 'short');
rdb.pclinfix           = fread(lun, 1, 'short');

rdb.pcconfix           = fread(lun, 1, 'short');

rdb.pclinslope         = fread(lun, 1, 'float');
rdb.pcconslope         = fread(lun, 1, 'float');
rdb.pccoil             = fread(lun, 1, 'short');

rdb.vvsmode            = fread(lun, 1, 'short');
rdb.vvsaimgs           = fread(lun, 1, 'short');
rdb.vvstr              = fread(lun, 1, 'short');
rdb.vvsgender          = fread(lun, 1, 'short');

rdb.zip_factor         = fread(lun, 1, 'short');

rdb.maxcoef1a	       = fread(lun, 1, 'float');
rdb.maxcoef1b	       = fread(lun, 1, 'float');
rdb.maxcoef1c	       = fread(lun, 1, 'float');
rdb.maxcoef1d	       = fread(lun, 1, 'float');
rdb.maxcoef2a	       = fread(lun, 1, 'float');
rdb.maxcoef2b	       = fread(lun, 1, 'float');
rdb.maxcoef2c	       = fread(lun, 1, 'float');
rdb.maxcoef2d	       = fread(lun, 1, 'float');
rdb.maxcoef3a	       = fread(lun, 1, 'float');
rdb.maxcoef3b	       = fread(lun, 1, 'float');
rdb.maxcoef3c	       = fread(lun, 1, 'float');
rdb.maxcoef3d	       = fread(lun, 1, 'float');

rdb.ut_ctrl            = fread(lun, 1, 'long');
rdb.dp_type            = fread(lun, 1, 'short');

%rdp.arw		       = fread(lun, 1, 'short');
%rdp.vps		       = fread(lun, 1, 'short');
%rdp.mcReconEnable      = fread(lun, 1, 'short');
%rdb.fov 	       = fread(lun, 1, 'float');
%rdp.te		       = fread(lun, 1, 'short');
%rdp.te2		       = fread(lun, 1, 'short');
rdb.excess	       = fread(lun, 423, 'short');

rdb.PER_PASS	       = fread(lun, 4096, 'char');
rdb.UNLOCK_RAW         = fread(lun, 4096, 'char');
rdb.DATA_ACQ_TAB       = fread(lun, ACQ_TAB_SIZE, 'char');
rdb.NEX_TAB	       = fread(lun, 2052, 'char');
rdb.NEX_ABORT_TAB      = fread(lun, 2052, 'char');
rdb.TOOLS	       = fread(lun, 2048, 'char');
rdb.EXAM	       = fread(lun, 1040, 'char');
rdb.SERIES	       = fread(lun, 1028, 'char');
rdb.IMAGE	       = fread(lun, 1044, 'char');
% $$$ rdb.IMAGE	       = fread(lun, 208, 'char');
% $$$ rdb.te	       = fread(lun, 1, 'long');
