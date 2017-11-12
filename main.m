clear
set(0,'DefaultFigureWindowStyle','docked')
addpath(genpath('functions'));

%% Load platemap
PlateMap = load_plate_map_from_google_spreadsheet();

%% Convert given datasets from .mat to .csv
clear filters; n=1;
% filters(n).column = {'Dataset; strcmp(Dataset,''20170811_LL_domneg_p1c2'')'}; % Lior
% filters(n).column = {'Dataset; strcmp(Dataset,''20170322_TG_Fibroblast_movie_2__2017-03-22T17_52_56-Measurement1'')'}; % Heather
filters(n).column = {'Dataset; strcmp(Dataset,''20171103_RB_LFS__2017-11-03T17_30_39-Measurement1'')'}; % Ron
n=n+1;

for i=1:size(filters,2)
  % Select experiment 
  SubsetPlateMap = filter_table(PlateMap, filters(i));
  if length(unique(SubsetPlateMap.Dataset)) > 1
      error('Cannot save experiment to csv because I am expecting only one experiment here.')
  end
  SubsetPlateMap(:,{'Row','Column'})={'*'}; % Load ALL data for this experiment, not just some wells
  % Load experiment as .mat
  data_type = 'SegResultFile';
  ResultTable = load_dataset(SubsetPlateMap,data_type);
  % Save experiment as .csv
  [filepath,filename,ext] = fileparts(char(SubsetPlateMap.SegResultFile(1)));
  output_csv_file = sprintf('%s/%s.csv',filepath,filename);
  NewTable = ResultTable_to_CSV(ResultTable,output_csv_file);
end


%% Curate cells by eliminating bad cell traces
% Load data
% csv_file = '\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Processed OutPutFiles\Dataset_20171103_RB_LFS__2017_11_03T17_30_39RESULTS\ResultTable - 2 wells, 1 fields, thresh 160_with_Traces_full.csv';
csv_file = 'ResultTable - 2 wells, 1 fields, thresh 160_with_Traces_full.csv';
ResultTable = readtable(csv_file);
Filter.column = {'Row; Row == 5 ', 'Column; Column == 2 '};
SubsetTable = filter_table(ResultTable, Filter);

% Load images
count=1;
well = SubsetTable.FileName{1}(1:12); % eg. r05c02f19p01
channel = SubsetTable.CellCh(1); % eg. 1
img_dir = SubsetTable.ImageDir{1};
for t=sort(unique(SubsetTable.Time))'
  img_file = sprintf('%s/%s-ch%dsk%dfk1fl1.tiff',img_dir,well,channel,t);
  fprintf('Loading image file "%s"\n',img_file);
  img = imread(img_file);
  if ~exist('img_stack')
    img_stack = zeros(size(img,1),size(img,2),length(unique(SubsetTable.Time)));
  end
  img_stack(:,:,count)=img;
  count=count+1;
end
figure; imshow3D(img_stack,[]);



unique(SubsetTable.FileName)


% load images
% display color overlay
% ginput loop
% save csv


%% Calculate new measurement
for i=1:size(filters,2)
  % Select experiment 
  SubsetPlateMap = filter_table(PlateMap, filters(i))
  % Load experiment as .csv
  data_type = 'csvFile';
  ResultTable = load_dataset(SubsetPlateMap,data_type);
  % Calculate new measurement
  new_measurment(SubsetPlateMap,'output_csv_file'); % INCOMPLETE
end



%% Plot given datasets
clear filters; n=1;
filters(n).sort = 'SaddlePoint'; % mitotic
filters(n).last = 5;

filters(n).column = { ...
            'SaddlePoint; SaddlePoint < 50', ... % not mitotic
            'NArea; NArea > median(NArea)', ...
            'NArea; NArea < prctile(NArea,99.9)' ...
            'Row; Row == 1 ' ...
            'Column; Column == 1 ' ...
            'Field; Field == 10 ' ...
            'Time; Time >= 1 ' ...
            'Time; Time <= 10 ' ...
}; 
filters(n).sort = 'Solidity'; % not mitotic
filters(n).first = 5;
filters(n).last = 5;
n=n+1;

filters(n).sort = 'Eccentricity';
filters(n).first = 5;
filters(n).last = 5;
n=n+1;

data_type = 'csvFile';
ResultTable = load_dataset(SubsetPlateMap,data_type);

for i=1:size(filters,2)
  SubsetTable = filter_table(DataTable, filters(i));
  display_single_cell(SubsetTable);
end