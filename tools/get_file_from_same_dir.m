function B = get_file_from_same_dir(A,B)
%for a given cell list of infile A : construct a file list from the same dir  
% of A with regulare expression given by B 
%if B is a cell list (already set by the user) just check the length is the same as A

if iscell(B)
    if length(B)==length(A)
        return
    else
        error('input argument of different length %d instead of %d (first is %s',length(B),length(A),B{1})
    end
end

dir = get_parent_path(A,1);
B = get_subdir_regex_files(dir,B,1);
