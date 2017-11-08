function Table = fun()
  % Download input data from master Google spreadsheet
  spreadsheet = GetGoogleSpreadsheet('1COtziAPVm6KSsk52dbrGlVAGaK4hh2Rj5Z9x0zqZkPo');
  spreadsheet_subset = spreadsheet(2:end,:); % exclude first column (column names)
  Table = cell2table(spreadsheet_subset);
  spreadsheet_column_names = spreadsheet(1,:); % names from google spreadsheet

  % %% Map names from Google Sheet to allowed names in Matlab tables
  % name_map = containers.Map;
  % name_map('Email Address') = 'Email';
  % for i=1:length(spreadsheet_column_names)
  %   table_column_names{i} = name_map(spreadsheet_column_names{i});
  % end
  % Table.Properties.VariableNames = table_column_names; % set proper column names
  
  Table.Properties.VariableNames = spreadsheet_column_names; % set proper column names

  % Set string columns that should be numeric to double type
  numeric_columns = {'Plate','Row','Column','PlateSize','Magnification'};
  for i=1:length(numeric_columns)
    temp = array2table(str2double(Table{:,numeric_columns(i)}));
    Table(:,numeric_columns(i)) = [];
    Table(:,numeric_columns(i)) = temp;
  end
end