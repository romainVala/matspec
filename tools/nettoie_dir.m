function dirname = nettoie_dir(dirname)

% cherche s'il y a des caracteres non alphanumeriques dans la chaine
str = isstrprop(dirname,'alphanum');
spec = find(~str);
% remplace les caracteres non alphanumeriques par des '_'
dirname(spec) = '_';
% pour fignoler, on supprime un '_' s'il y en a 2 qui se suivent
while ~isempty(strfind(dirname,'__'));
    dirname = strrep(dirname,'__','_');
end
% toujours pour fignoler, si le nom se termine par un '_', on l'elimine
if(dirname(length(dirname)) == '_')
    dirname(length(dirname)) = '';
end

