function f = correct_fid_lana(f)


for k = 1:length(f)
  
  fid = f(k).water_ref.fid;
  sw = f(k).spectrum.SW_h;

  np=size(fid,1);
  timeD=transpose(0:1/sw:(np)*1/sw-1/sw);
  RtermLor=exp(-timeD/0.15);
  
  ywat = transpose(fid);
  [mConAmpCor mSPhase mT2used] = LineShapeExtract(ywat,sw);

  fidcor =  transpose(LineShapeCorrect(ywat,mConAmpCor,mSPhase,mT2used,sw,0));
  fidcor = fidcor.*RtermLor;
  
  f(k).water_ref.fid = fidcor;
  

%  fidmet = transpose(f(k).fid) ;
%  fidcor =  transpose(LineShapeCorrect(fidmet,mConAmpCor,mSPhase,mT2used,sw,0));
%  fidcor = fidcor.*RtermLor;

end

