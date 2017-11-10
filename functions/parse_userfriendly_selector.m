function select_data = fun(PlateMap,ResultTable)
  % Consolidate userfriendly filter format of '1','1,2', or '1,2,1:3','*' into a list [1 2 3]
 % Used for row and column filters in Daniel's Plate Map for Everything (GoogleSpreadsheet)
  select_rows = unique(str2num(strjoin(PlateMap.Row,',')));
  select_columns = unique(str2num(strjoin(PlateMap.Column,',')));
  if any(ismember(PlateMap.Row,'*')) % skip filter if *
    select_rows = unique(ResultTable.Row);
  end
  if any(ismember(PlateMap.Column,'*')) % skip filter if *
    select_columns = unique(ResultTable.Column);
  end
  select_data = ismember(ResultTable.Row,select_rows) & ismember(ResultTable.Column,select_columns);
end