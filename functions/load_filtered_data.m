function SubsetTable = fun(PlateMap, Filter)
  % Select relevant experiments
  SubsetPlateMap = filter_table(PlateMap, Filter);
  % Load data
  ResultTable = load_dataset(SubsetPlateMap);
  % Select relevant data
  SubsetTable = filter_table(ResultTable, Filter);
end