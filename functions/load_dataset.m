function ResultTableAll = fun(PlateMap)
  unique_datasets = unique(PlateMap.Dataset);
  unique_datasets(strcmp(unique_datasets,'')) = []; % remove empty string

  ResultTableAll = table();
  
  % For each dataset load the specified rows and columns
  for i=1:length(unique_datasets)
    data_name = char(unique_datasets(i));
    fprintf('[load_dataset.m] Loading data set: %s\n', data_name)
    row_filter = '';
    column_filter = '';

    % Get entries in PlateMap for just this dataset
    DatasetMap = PlateMap(strcmp(PlateMap.Dataset,data_name),:);

    % Find data file on disk
    data_file = char(DatasetMap.SegResultFile(1));
    [filepath,filename,data_type] = fileparts(data_file);
    if ~exist(data_file)
      error('Cannot load dataset because cannot find file: %s .', data_file)
    end

    % Load dataset
    if strcmp(data_type,'.mat')
      ResultTable = load(data_file);
      % ResultTable = ResultTable.ResultTable;
      ResultTable = ResultTable.SubsetTable;
      %ResultTable = ResultTable_to_CSV(ResultTable);
    elseif strcmp(data_type,'.csv')
      %data_file = sprintf('%s/%s.csv',filepath,filename);
      ResultTable = readtable(data_file);
    else
      error('Cannot load dataset because specified data_type "%s" is unknown.', data_type)
    end

    % Consolidate userfriendly filter format of '1','1,2', or '1,2,1:3','*' into a list [1 2 3]. Used for row and column filters in Daniel's Plate Map for Everything (GoogleSpreadsheet)
    select_data = parse_userfriendly_selector(DatasetMap,ResultTable);
    % Filter data down just to the selected rows and columns
    ResultTable = ResultTable(select_data,:);


    if height(ResultTable) == 0
      warning('No cells found in well with ID(s) "%s"',strjoin(DatasetMap.WellID));
      continue
    end

    % Add meta information (if not present) from PlateMap to each row in the ResultTable
    for col_name=PlateMap.Properties.VariableNames
      % Skip if ResultTable already has this column
      if any(ismember(ResultTable.Properties.VariableNames,char(col_name)))
        continue
      end
      fprintf('[load_dataset.m] Adding metadata "%s" to dataset: %s\n', col_name, data_name)
      % For each of the wells given in the PlateMap add the PlateMap metadata to all the cells,
      % but since the info can be different per well, apply it well by well differently
      for ii=1:height(DatasetMap)
        DatasetPart = DatasetMap(ii,:);
        % Consolidate userfriendly filter format of '1','1,2', or '1,2,1:3','*' into a list [1 2 3]. Used for row and column filters in Daniel's Plate Map for Everything (GoogleSpreadsheet)
        select_data = parse_userfriendly_selector(DatasetPart,ResultTable);
        if ~any(select_data)
            continue
        end
        col_value = DatasetPart{:,col_name}; % should should be a single value, since it is accessing a table w/ 1 value
        ResultTable(select_data,col_name) = {col_value}; % Do add metada to the correct rows
      end
    end
    
    % Add uuid for each cell (if needed)
    if ~any(ismember(ResultTable.Properties.VariableNames,'CellID'))
      fprintf('[load_dataset.m] Adding Cell UUIDs to dataset: %s\n', data_name)
      ResultTable.CellID = uuid_array(height(ResultTable))';
    end

    if isempty(ResultTableAll)
      ResultTableAll = ResultTable;
    else
      ResultTableAll = outerjoin(ResultTableAll,ResultTable,'MergeKeys',true);
    end


    % new_cols = setdiff(ResultTable.Properties.VariableNames, ResultTableAll.Properties.VariableNames)
    % for col_name=new_cols
    %   % Get a sample data point
    %   col_name
    %   col_value = ResultTable{1,col_name}
    %   % Handle the strange case where the col_value is a cell with one empty array in it. Set it to an empty string
    %   if strcmp(class(col_value),'cell')
    %     col_value = {};
    %   end
    %   % if strcmp(class(col_value),'cell') && length(col_value) == 1 && isempty(col_value{1})
    %   %   col_value = '';
    %   % end
    %   % Set the new column to be entirely equal to the sample data point, this setups the correct data class
    %   ResultTableAll(:,col_name)={col_value}

    %   % Change the sample data point to be a standard missing value, such as '' or NaN, depending on the class
    %   %if ~strcmp(class(col_value),'cell')
    %   %  ResultTableAll(:,col_name) = {standardizeMissing(ResultTableAll{:,col_name},col_value)};
    %   %end
    % end
    % ResultTableAll = [ResultTableAll; ResultTable];
  end
  if height(ResultTableAll) == 0
    error('No cells found in well with ID(s) "%s"',strjoin(PlateMap.WellID));
  end
end