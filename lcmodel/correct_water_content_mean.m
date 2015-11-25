function c = correct_water_content_mean(c)



for npool=1:length(c)
  c(npool).fgray = ones(1,length(c(npool).fgray)) .* mean(c(npool).fgray);
  c(npool).fwhite = ones(1,length(c(npool).fwhite)) .* mean(c(npool).fwhite);
  c(npool).fcsf = ones(1,length(c(npool).fcsf)) .* mean(c(npool).fcsf);
end

