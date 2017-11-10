function ResultTableAll = fun(PlateMap,data_type)
  unique_datasets = unique(PlateMap.Dataset);
  unique_datasets(strcmp(unique_datasets,'')) = []; % remove empty string

  ResultTableAll = table();
  
  % For each dataset load the specified rows and columns
  for i=1:length(unique_datasets)
    row_filter = '';
    column_filter = '';

    % Get entries in PlateMap for just this dataset
    DatasetMap = PlateMap(strcmp(PlateMap.Dataset,unique_datasets(i)),:);

    % Consolidate userfriendly format and possibly redunof '1','1,2','1:3','*' into a list [1 2 3]
    select_rows = unique(str2num(strjoin(DatasetMap.Row,',')));
    select_columns = unique(str2num(strjoin(DatasetMap.Column,',')));

    % Load dataset
    if strcmp(data_type,'SegResultFile')
      ResultTable = load(char(DatasetMap.SegResultFile(1)));
      ResultTable = ResultTable.ResultTable;
    elseif strcmp(data_type,'csvFile')
      data_file = char(DatasetMap.SegResultFile(1));
      [filepath,filename,ext] = fileparts(data_file)
      data_file = sprintf('%s/%s.csv',filepath,filename);
      ResultTable = readtable(data_file);
    else
      error('Cannot load datasen because specified data_type "%s" us known.', data_type)
    end

    % Filter data down just to the selected rows and columns
    if ~strcmp(select_rows,'*') % skip filter if *
      data_filter = ismember(ResultTable.Row,select_rows);
      ResultTable = ResultTable(data_filter,:);
    end
    if ~strcmp(select_columns,'*') % skip filter if *
      data_filter = ismember(ResultTable.Column,select_columns);
      ResultTable = ResultTable(data_filter,:);
    end


    if height(ResultTable) == 0
      warning('No cells found in well with ID(s) "%s"',strjoin(DatasetMap.WellID));
      continue
    end

    % Add meta information (if not present) from PlateMap to each row in the ResultTable
    for col_name=PlateMap.Properties.VariableNames
      % Skip if ResultTable already has this column
      if any(ismember(ResultTable.Properties.VariableNames,col_name))
        continue
      end
      % For each of the wells given in the PlateMap add the column information,
      % but since the info can be different per well, apply it well by well correctly
      for ii=1:height(DatasetMap)
        DatasetPart = DatasetMap(ii,:);
        rows = ismember(ResultTable.Row,unique(str2num(char(DatasetPart.Row)))) & ...
               ismember(ResultTable.Column,unique(str2num(char(DatasetPart.Column))));
        if ~any(rows)
            continue
        end
        col_value = DatasetPart{:,col_name}; % should should be a single value, since it is accessing a table w/ 1 value
        ResultTable(rows,col_name) = {col_value};
      end
    end
    
    % Add uuid for each cell (if not present)
    ResultTable.CellID = uuid_array(height(ResultTable))';

    if isempty(ResultTableAll)
      ResultTableAll = ResultTable;
    else
      ResultTableAll = outerjoin(ResultTableAll,ResultTable,'MergeKeys',true);
    end


    % % Initialize columns that are new to ResultTableAll as found in ResultTable 
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
    error('Exiting... No cells found at the given combination of row, column, (time and field)');
  end
end