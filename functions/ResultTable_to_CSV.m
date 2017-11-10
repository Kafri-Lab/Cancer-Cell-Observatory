function NewTable = fun(Table, output_csv_file)
  NewTable = Table;

  % not needed
  % matlab.net.base64encode(strjoin(string(cell2mat(Table.cyto_boundaries(2))))) % convert to base64

  % Actions to be taken on columns of the ResultTable before saving to CSV
  cell_to_string = {'nuc_boundaries', 'cyto_boundaries'};
  del = {'Color','Compound','Concentration','Cell_Type','Cell_Count'};


  % Handle column deletes
  fprintf('Deleting columns\n');
  for i=1:length(del)
    eval(sprintf('NewTable.%s = [];',char(del(i))));
  end

  % Handle columns that will be converted from cell arrays to a space delimited string
  fprintf('Converting cell arrays to a space delimited string\n');
  for i=1:length(cell_to_string)
    eval(sprintf('NewTable.%s = [];',char(cell_to_string(i))));
    for n=1:height(Table)
      eval(sprintf('NewTable.%s(n) = strjoin(string(cell2mat(Table.%s(n))));',char(cell_to_string(i)), char(cell_to_string(i))));
    end
  end

  % Save CSV
  if strcmp(output_csv_file,'none')
    return;
  end
  fprintf('Saving CSV\n');
  writetable(NewTable,output_csv_file);

end