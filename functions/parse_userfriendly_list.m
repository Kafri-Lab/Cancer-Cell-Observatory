function list = fun(Cell)
  % Consolidate userfriendly format of {'1','1,2','1-3','*'} into a list [1 2 3].
  if any(strcmp(Cell,'*'))
    return '*'
  end

  list = [];
  for i=1:length(Cell) % eg. {'1','1,2','1-3','*'}
    item = Cell(i); % eg. '1,3,1-3'
    items = strsplit(item,'-'); % eg. {'1,3', '1-3'}
    for ii=1:length(items)
    if 

      item
    end
  end

end