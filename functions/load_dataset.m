function ResultTableAll = fun(PlateMap)
  unique_datafiles = unique(PlateMap.SegResultFile);
  unique_datafiles(strcmp(unique_datafiles,'')) = []; % remove empty string

  ResultTableAll = table();
  
  % For each dataset load the specified rows and columns
  for i=1:length(unique_datafiles)
    data_filename = char(unique_datafiles(i));
    fprintf('[load_dataset.m] Loading data file: %s\n', data_filename)

    % Find data file on disk
    [filepath,filename,data_type] = fileparts(data_filename);
    if ~exist(data_filename)
      error('Cannot load dataset because cannot find file: %s .', data_filename)
    end
    
    % Load dataset
    if strcmp(data_type,'.mat')
      ResultTable = load(data_filename);
      % ResultTable = ResultTable.ResultTable;
      ResultTable = ResultTable.SubsetTable;
      ResultTable = ResultTable_to_CSV(ResultTable);
    elseif strcmp(data_type,'.csv')
      ResultTable = readtable(data_filename);
    else
      error('Cannot load dataset because data_type "%s" is unknown.', data_type)
    end

    % Get well entries in PlateMap for just this dataset file
    SubsetPlateMap = PlateMap(strcmp(PlateMap.SegResultFile,data_filename),:);
    
    % For each well, add columns if needed
    for ii=1:height(SubsetPlateMap)
      WellInfo = SubsetPlateMap(ii,:);

      % Get data only in this well
      Filter.column = { ...
          sprintf('Row; Row == %d',WellInfo.Row) , ...
          sprintf('Column; Column == %d',WellInfo.Column) , ...
      };
      SubsetTable = filter_table(ResultTable,Filter);

      if height(SubsetTable) == 0
        warning('No cells found in well with ID(s) "%s"',strjoin(SubsetPlateMap.WellID));
        continue
      end

      % Add meta information (if not present) from PlateMap to each row in the SubsetTable
      for col_name=PlateMap.Properties.VariableNames
        % Skip if SubsetTable already has this column
        if any(ismember(SubsetTable.Properties.VariableNames,char(col_name)))
          continue
        end
        fprintf('[load_dataset.m] Adding metadata "%s" to dataset: %s\n', char(col_name), data_filename)
        col_value = WellInfo{:,col_name}; % should should be a single value, since it is accessing a table w/ 1 value
        SubsetTable(:,col_name) = {col_value}; % Add metada
      end
      
      % Add uuid for each cell (if needed)
      if ~any(ismember(SubsetTable.Properties.VariableNames,'CellID'))
        fprintf('[load_dataset.m] Adding Cell UUIDs to dataset: %s\n', data_filename)
        SubsetTable.CellID = uuid_array(height(SubsetTable))';
      end

      if isempty(ResultTableAll)
        ResultTableAll = SubsetTable;
      else
        ResultTableAll = outerjoin(ResultTableAll,SubsetTable,'MergeKeys',true);
      end
  end
  if height(ResultTableAll) == 0
    error('No cells found in well with ID(s) "%s"',strjoin(PlateMap.WellID));
  end
end