clear
set(0,'DefaultFigureWindowStyle','docked')
addpath(genpath('functions'));

%% Load platemap
PlateMap = load_plate_map_from_google_spreadsheet();

%% Convert given datasets from .mat to .csv
clear filters; n=1;
fliters(n).column = {'Dataset; strcmp(Dataset,''20170811_LL_domneg_p1c2'')'};
n=n+1;
fliters(n).column = {'Dataset; strcmp(Dataset,''20170322_TG_Fibroblast_movie_2__2017-03-22T17_52_56-Measurement1'')'};
n=n+1;

for i=1:size(filters,2)
  % Select experiment 
  SubsetPlateMap = filter_table(PlateMap, fliters(i))
  % Load experiment as .mat
  data_type = 'SegResultFile';
  ResultTable = load_dataset(SubsetPlateMap,data_type);
  % Save experiment as .csv
  [filepath,filename,ext] = fileparts(SubsetPlateMap.SegResultFile)
  output_csv_file = sprintf('%s/%s.csv',filepath,filename);
  ResultTable_to_CSV(SubsetPlateMap,output_csv_file);
  % Save location of .csv to GoogleSpreadsheet
  TODO
end


%% Calculate new measurement
for i=1:size(filters,2)
  % Select experiment 
  SubsetPlateMap = filter_table(PlateMap, fliters(i))
  % Load experiment as .csv
  data_type = 'csvFile';
  ResultTable = load_dataset(SubsetPlateMap,data_type);
  % Calculate new measurement
  new_measurment(SubsetPlateMap,'output_csv_file');
end



%% Plot given datasets
clear filters; n=1;
filters(n).sort = 'SaddlePoint'; % mitotic
filters(n).last = 5;

filters(n).column = {
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