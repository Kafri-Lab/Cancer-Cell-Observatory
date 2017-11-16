clear
set(0,'DefaultFigureWindowStyle','docked')
addpath(genpath('functions'));

%% Load platemap
PlateMap = load_plate_map_from_google_spreadsheet();

%% Example filter usage
clear filters; n=1;
filters(n).column = { ...
            'SaddlePoint; SaddlePoint < 50', ... % not mitotic
            'NArea; NArea > median(NArea)', ...
            'NArea; NArea < prctile(NArea,99.9)' , ...
            'Row; Row == 1 ' , ...
            'Column; Column == 1 ' , ...
            'Field; Field == 10 ' , ...
            'Time; Time >= 1 ' , ...
            'Time; Time <= 10 ' , ...
}; 
filters(n).sort = 'Solidity'; % not mitotic
filters(n).first = 5;
filters(n).last = 5;
n=n+1;


%% Curate Ron's cells
clear filters; n=1;
filters(n).column = {
    'Dataset;  strcmp(Dataset,''20171103_RB_LFS__2017-11-03T17_30_39-Measurement1'')', ...
    'Row; Row == 5 ' , ...
    'Column; Column == 2 ' , ... % LFS
    'Field; Field == 19 ' , ...
    'Time; Time == 193 ' , ...
};
n=n+1;
filters(n).column = {
    'Dataset;  strcmp(Dataset,''20171103_RB_LFS__2017-11-03T17_30_39-Measurement1'')', ...
    'Row; Row == 5 ' , ...
    'Column; Column == 7 ' , ... % WT
    'Field; Field == 19 ' , ...
    'Time; Time == 193 ' , ...
};
curate_cells(PlateMap,filters)


clear filters; n=1;
filters(n).column = {
    'Dataset;  strcmp(Dataset,''20171103_RB_LFS__2017-11-03T17_30_39-Measurement1'')', ...
    'Field; Field == 19 ' , ...
    'Time; Time == 193 ' , ...
};

%% Major functions
convert_mat_to_csv(PlateMap,filters) % create csv files
calculate_new_measurement(PlateMap,filters) % add measurments to table
curate_cells(PlateMap,filters)
SubsetTable = load_filtered_data(PlateMap,filters(i));

%% Plot given datasets
for i=1:size(filters,2)
  SubsetTable = filter_table(DataTable, filters(i));
  display_single_cell(SubsetTable);
end

% Combine tables
csv_file = 'ResultTable - 1 wells, 1 fields, thresh 160_with_Traces_full_curated WT.csv';
T1 = readtable(csv_file);
csv_file = 'ResultTable - 1 wells, 1 fields, thresh 160_with_Traces_full_curated LFS.csv';
T2 = readtable(csv_file);
T_Full = [T1; T2];
output_csv_file = sprintf('ResultTable_curated_t193.csv');
writetable(T_Full,output_csv_file);