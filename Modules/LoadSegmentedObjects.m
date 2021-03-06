function handles = LoadSegmentedObjects(handles)

% Help for the LoadSegmentedObjects module:
% Category: Object Processing
%
% SHORT DESCRIPTION:
% Loads object segmentation from iBRAIN's SEGMENTATION directory
% The channel, which forms the base of the file name of the segmentation
% can be specified (in case objects are from different pipelines) - by
% default the first channel as specified in the
% *************************************************************************
%
% Website: http://www.cellprofiler.org
%
% $Revision: 1809 $

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = For which object?
%defaultVAR01 = Cells
%infotypeVAR01 = objectgroup indep
ObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,1});

%textVAR02 = Which channel forms the basis of the filenames?
%infotypeVAR02 = imagegroup
iChannel = char(handles.Settings.VariableValues{CurrentModuleNum,2});
%inputtypeVAR02 = popupmenu

%%%VariableRevisionNumber = 5

%%%%%%%%%%%%%%%%
%%% ANALYSIS %%%
%%%%%%%%%%%%%%%%

% Get Position of the channel
FoundChannel = cell2mat(cellfun(@(x) strcmp(x,iChannel), handles.Measurements.Image.FileNamesText,'UniformOutput', false));
PosOfChannel = find(FoundChannel,1,'first');


% get the filename of the object setgementation as stored by
% SaveSegmentedCells
strOrigImageName = char(handles.Measurements.Image.FileNames{handles.Current.SetBeingAnalyzed}{1,PosOfChannel});

% format the segmentation file name
matDotIndices=strfind(strOrigImageName,'.');
% new CP apparently removes file extensions from image names
if ~isempty(matDotIndices)
    strOrigImageName = strOrigImageName(1,1:matDotIndices(end)-1);
end
strSegmentationFileName = [strOrigImageName,'_Segmented',ObjectName,'.png'];

% get the SEGMENTATION directory
% If output dir is BATCH directory, assume SEGMENTATION directory
strSegmentationDir = handles.Current.DefaultOutputDirectory;
if strcmp(getlastdir(strSegmentationDir),'BATCH')
    strSegmentationDir = strrep(strSegmentationDir, [filesep,'BATCH'],[filesep,'SEGMENTATION']);
end

% load segmentation image
strFilePath = fullfile(strSegmentationDir,strSegmentationFileName);
if fileattrib(strFilePath)
    matSegmentationImage = double(imread(fullfile(strSegmentationDir,strSegmentationFileName)));
else
    error('%s: looking for segmentation file ''%s''. Does not exist!',mfilename,strFilePath)
end



%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%%
drawnow

ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)
    if CPisHeadless == false
        %%% Activates the appropriate figure window.
        CPfigure(handles,'Image',ThisModuleFigureNumber);
        
        % RGB color
        ColoredLabelMatrixImage = CPlabel2rgb(handles,matSegmentationImage);
        CPimagesc(ColoredLabelMatrixImage,handles);
        %imagesc(ColoredLabelMatrixImage);
        
        title(sprintf('Loaded %s segmentation , cycle # %d',ObjectName,handles.Current.SetBeingAnalyzed));
    end
end



%%%%%%%%%%%%%%%%%%%%%
%%% STORE RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%


% These fields are stored in identifyprimautomatic, might be that other
% segmentation/object detection modules store more fields... check
% (secondary, and identifyprimlog...)

%%% Saves the segmented image, not edited for objects along the edges or
%%% for size, to the handles structure.
fieldname = ['UneditedSegmented',ObjectName];
handles.Pipeline.(fieldname) = matSegmentationImage;

%%% Saves the segmented image, only edited for small objects, to the
%%% handles structure.
fieldname = ['SmallRemovedSegmented',ObjectName];
handles.Pipeline.(fieldname) = matSegmentationImage;

%%% Saves the final segmented label matrix image to the handles structure.
fieldname = ['Segmented',ObjectName];
handles.Pipeline.(fieldname) = matSegmentationImage;

%%% Saves the ObjectCount, i.e., the number of segmented objects.
%%% See comments for the Threshold saving above
if ~isfield(handles.Measurements.Image,'ObjectCountFeatures')
    handles.Measurements.Image.ObjectCountFeatures = {};
    handles.Measurements.Image.ObjectCount = {};
end
column = find(~cellfun('isempty',strfind(handles.Measurements.Image.ObjectCountFeatures,ObjectName)));
if isempty(column)
    handles.Measurements.Image.ObjectCountFeatures(end+1) = {ObjectName};
    column = length(handles.Measurements.Image.ObjectCountFeatures);
end
handles.Measurements.Image.ObjectCount{handles.Current.SetBeingAnalyzed}(1,column) = max(matSegmentationImage(:));

%%% Saves the location of each segmented object
handles.Measurements.(ObjectName).LocationFeatures = {'CenterX','CenterY'};
tmp = regionprops(matSegmentationImage,'Centroid');
Centroid = cat(1,tmp.Centroid);
handles.Measurements.(ObjectName).Location(handles.Current.SetBeingAnalyzed) = {Centroid};

end
