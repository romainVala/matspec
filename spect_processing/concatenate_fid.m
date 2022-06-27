function [info_o] = concatenate_fid(info,str_concat)

if nargin==1
    str_concat=''; %concatexam
end
if strfind('subject',str_concat)
    concat_OK=1;
else
    concat_OK=0;
end
    

correct_center_freq = 0;
io=1;

while length(info)>1
    
    info_o(io) = info(1);
    
    info(1) = [];
    
    ind_to_remove=[];
    for nf = 1:length(info)
        if (compare_pos(info_o(io).Pos,info(nf).Pos) & compare_ws(info_o(io),info(nf))) | concat_OK
            
            fprintf('Concatanate %s with %s \n',info(nf).Serie_description,info_o(io).Serie_description);
            
            if (info_o(io).spectrum.cenfreq ~= info(nf).spectrum.cenfreq) & correct_center_freq
                delta_nu =(info(nf).spectrum.cenfreq - info_o(io).spectrum.cenfreq)*1e6;
                delta_nu = delta_nu/2;
                %	delta_nu = -delta_nu;
                
                pas_temps=info(nf).spectrum.dw;
                k = 1:1:info(nf).spectrum.np;
                correction=exp(-2*pi*1i*delta_nu*(k-1)*pas_temps);
                correction=transpose(correction);
                for kk=1:size( info(nf).fid,2)
                    info(nf).fid(:,kk) = info(nf).fid(:,kk) .* correction;
                end
                fprintf('frequency corection of %f\n',delta_nu);
                keyboard
            end
            
            if findstr(info_o(io).seqname,'mega');
                info_o(io).fid = cat_mega_fid(info_o(io).fid,info(nf).fid);
            else
                info_o(io).fid = cat(2,info_o(io).fid,info(nf).fid);
            end
            
            %      info_o(io).Serie_description = [info_o(io).Serie_description ,' & ',info(nf).Serie_description ];
            
            
            info_o(io).Nex = info_o(io).Nex + info(nf).Nex ;
            info_o(io).Number_of_spec = info_o(io).Number_of_spec + info(nf).Number_of_spec ;
            info_o(io).Serie_description = [info(1).Serie_description '_' num2str(info_o(io).Nex)];
            
            
            if strcmp(str_concat,'concatexam')
                info_o(io).examnumber = [info_o(io).examnumber info(nf).examnumber];
            end
            
            ind_to_remove = [ind_to_remove , nf];
        end
    end
    
    info(ind_to_remove)=[];
    
    io=io+1;
end

if length(info)==1
    info_o(io) = info(1);
end

%_______________________________________________________________________________________________
function fo = cat_mega_fid(f1,f2)

s1 = size(f1,2)/2;
s2 = size(f2,2)/2;

f1_1 = f1(:,1:s1);
f1_2 = f1(:,s1+1:end);

f2_1 = f2(:,1:s2);
f2_2 = f2(:,s2+1:end);


fo = cat(2,f1_1,f2_1,f1_2,f2_2);


%_______________________________________________________________________________________________

function ok = compare_pos(p1,p2)

ok = all(p1.VoiFOV==p2.VoiFOV) & all(p1.VoiOrientation==p2.VoiOrientation) %& compare_pos(p1.VoiPosition==p2.VoiPosition) ;

%_______________________________________________________________________________________________
function ok = compare_ws(i1,i2)

ok= (i1.mega_ws == i2.mega_ws) & (i1.vapor_ws==i2.vapor_ws);

