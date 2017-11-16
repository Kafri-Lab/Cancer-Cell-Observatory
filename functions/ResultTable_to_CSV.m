function NewTable = fun(Table)
  fprintf('[ResultTable_to_CSV.m] Converting table format with %d rows.\n', height(Table))

  NewTable = Table;

  % Actions to be taken on columns of the ResultTable before saving to CSV
  cell_to_string = {'nuc_boundaries', 'cyto_boundaries'};
  del = {'Color','Compound','Concentration','Cell_Type','Cell_Count'};

  % Handle column deletes
  for i=1:length(del)
    if ~ismember(NewTable.Properties.VariableNames,del(i))
      continue
    end
    eval(sprintf('NewTable.%s = [];',char(del(i))));
  end

  % Handle columns that will be converted from cell arrays to a space delimited string
  for i=1:length(cell_to_string)
    if ~ismember(NewTable.Properties.VariableNames,cell_to_string(i))
      continue
    end
    fprintf('[ResultTable_to_CSV.m] Adding column "%s" to csv.\n', char(cell_to_string(i)))

    eval(sprintf('NewTable.%s = [];',char(cell_to_string(i))));
    for n=1:height(Table)
      eval(sprintf('NewTable.%s(n) = strjoin(string(cell2mat(Table.%s(n))));',char(cell_to_string(i)), char(cell_to_string(i))));
    end
  end

end