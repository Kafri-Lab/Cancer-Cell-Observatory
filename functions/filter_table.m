function Table = fun(Table, Filter, varargin)
  %% Handle Filter.columns
  if isfield(Filter,'column') && ~isempty(Filter.column)
    for ii=1:length(Filter.column)
      column_filter = char(Filter.column(ii));
      column_filter_arr = strsplit(column_filter, ';');
      column_name = char(column_filter_arr(1));
      operator = char(column_filter_arr(2));

      if ~any(ismember(Table.Properties.VariableNames,column_name))
        warning('[filter_table.m] Cannot filter on column name "%s" because it doesn''t exist', column_name)
        continue
      end

      eval(sprintf('%s = Table.%s;',column_name, column_name)); % create a variable (ex. NArea) to make possible filters like 'NArea > median(NArea)'
      do_filter = sprintf('Table(%s,:)', operator);
      fprintf('Doing filter: %s\n', operator)
      Table = eval(do_filter); % do filter
    end
  end
  
  %% Handle Filter.sort
  if isfield(Filter,'sort') && ~isempty(Filter.sort)
    Table = sortrows(Table,Filter.sort);
  end

  %% Handle Filter.first
  if isfield(Filter,'first') && ~isempty(Filter.first)
    FirstRows = Table(1:Filter.first,:);
  else
    FirstRows = table();
  end
  %% Handle Filter.last
  if isfield(Filter,'last') && ~isempty(Filter.last)
    LastRows = Table(end-Filter.last+1:end,:);
  else
    LastRows = table();
  end
  if (isfield(Filter,'first') && ~isempty(Filter.first)) | (isfield(Filter,'last') && ~isempty(Filter.last))
    Table = [FirstRows; LastRows];
  end

  % Sanity Check
  if height(Table) == 0
    error('Exiting... No rows found with given filter');
  end
end
