function fun(PlateMap,filters)
  %% Calculate new measurement
  for i=1:size(filters,2)
    % Select experiment 
    SubsetPlateMap = filter_table(PlateMap, filters(i))
    % Load experiment as .csv
    ResultTable = load_dataset(SubsetPlateMap);
    % Calculate new measurement
    new_measurment(SubsetPlateMap,'output_csv_file'); % INCOMPLETE
  end
end