function fun(PlateMap,filters)
  for i=1:size(filters,2)
    % Select experiment 
    SubsetPlateMap = filter_table(PlateMap, filters(i));
    if length(unique(SubsetPlateMap.Dataset)) > 1
        error('Cannot save experiment to csv because I am expecting only one experiment here.')
    end
    SubsetPlateMap(:,{'Row','Column'})={'*'}; % Load ALL data for this experiment, not just some wells
    data_file = char(SubsetPlateMap.SegResultFile(1));
    [filepath,filename,ext] = fileparts(data_file);
    if strcmp(ext,'csv')
      error('[convert_mat_to_csv.m] Cannot convert to csv because it is already csv: %s',data_file)
    end
    ResultTable = load_dataset(SubsetPlateMap);
    % Save experiment as .csv
    output_csv_file = sprintf('%s/%s.csv',filepath,filename);
    NewTable = ResultTable_to_CSV(ResultTable);
    % Save CSV
    fprintf('[convert_mat_to_csv.m] Saving CSV to file: %s\n', char(output_csv_file));
    writetable(NewTable,output_csv_file);
  end
end