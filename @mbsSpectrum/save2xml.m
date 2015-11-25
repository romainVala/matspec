% ****************************************************************************** 
%             MBS - Minnesota Breast Spectroscopy analysis package
%               Developed by Patrick Bolan and Michael Garwood
% ****************************************************************************** 
% FUNCTION: mbsSpectrum - save2xml
% AUTHOR: pjb
% CREATED: 9/26/2006
% DESCRIPTION: Streams the essentials to an xml file
% ARGUMENTS: mbsSpectrum, filename
% RETURNS: nothing
% MODIFICATIONS:
% ****************************************************************************** 
function save2xml(sp, filename)

% Create a compact structure
out.head.spectype = 'fid';
out.head.centerFrequency = sp.sfrq * 1000000.0;
out.head.numberTraces = sp.numspec;
out.head.numberSamples = sp.pts;
out.head.samplingInterval = sp.at / (sp.pts-1);

for idx = 1: sp.numspec
   out.trace{idx}.real = real(sp.fid(:,idx));
   out.trace{idx}.imag = imag(sp.fid(:,idx));
end

% Save it out using the xmltree
% Need a version number for the object
tree = struct2xml(out);

% Change the name of the root element 
tree = set(tree,root(tree),'name','mbsSpectrum');
tree = attributes(tree, 'add', root(tree), 'version', '3.0');

save(tree, filename);


% The java way
% docNode = com.mathworks.xml.XMLUtils.createDocument('mbsSpectrum');
% docRootNode = docNode.getDocumentElement;
% headElement = docNode.createElement('head');
% spectypeElement = docNode.createElement('spectype');
% spectypeElement.appendChild(docNode.createTextNode('fid'));
% headElement.appendChild(spectypeElement);
% docRootNode.appendChild(headElement);
% xmlwrite(filename, docNode);