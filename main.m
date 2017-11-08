clear
set(0,'DefaultFigureWindowStyle','docked')
addpath(genpath('functions'));

PlateMap = load_plate_map_from_google_spreadsheet();

%% Get single cell data for well
Well = PlateMap(strcmp(PlateMap.ID,'90da1cef'),:) % Heather's cells for tracking
load(char(Well.SegResultFile));
% Filter data down just to this well
rows = ResultTable.Row==Well.Row & ResultTable.Column==Well.Column;
% field = 10;
% min_time = 1;
% max_time = 20;
% rows = ResultTable.Row==Well.Row & ResultTable.Column==Well.Column & ResultTable.Field==field & ResultTable.Time<=max_time & ResultTable.Time>=min_time;
WellTable = ResultTable(rows,:);
if height(WellTable) == 0
    error('Exiting... No cells found at the given combination of row, column, (time and field)');
end


n=1;
% Filters sets
filters(n).sort = 'SaddlePoint'; % mitotic
filters(n).last = 5;

filters(n).column = {
            'SaddlePoint < 50', ... % not mitotic
            'NArea > median(NArea)', ...
            'NArea < prctile(NArea,99.9)' ...
}; 
filters(n).sort = 'Solidity'; % not mitotic
filters(n).first = 5;
filters(n).last = 5;
n=n+1;

filters(n).sort = 'Eccentricity';
filters(n).first = 5;
filters(n).last = 5;
n=n+1;

%% Do filtering and work on filtered data
for i=1:size(filters,2)
   Filter = filters(i);
   Table = WellTable;


  if isfield(Filter,'column') && ~isempty(Filter.column)
    %% Handle Filter.columns
    for ii=1:length(Filter.column)
      column_filter = char(Filter.column(ii));
      column_filter_arr = strsplit(column_filter);
      column_name = char(column_filter_arr(1));
      operator = char(column_filter_arr(2));
      operand = char(column_filter_arr(3));

      eval(sprintf('%s = Table.%s;',column_name, column_name)); % create a variable (ex. NArea) to make possible filters like 'NArea > median(NArea)'
      do_filter = sprintf('Table(%s %s %s,:)', column_name, operator, operand);
      fprintf('Doing filter: %s\n', do_filter)
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

  %% Do work on filtered data
  for cell_id=1:height(Table)
    Cell = Table(cell_id,:);
    % Load the image that the cell is found in
    if strcmp(Well.ImageNamingScheme, 'Operetta')
      filename = char(Cell.FileName);
      filename(16) = char(Well.CellCh);
    end
    filepath = sprintf('%s%s', char(Well.ImageDir), filename);
    cyto = imread(filepath);

    % Build mask of cell boundries
    cell_mask = zeros(size(cyto,1), size(cyto,2));
    cell_mask(cell2mat(Cell.cyto_boundaries)) = 1;

    % Build mask of nuclear boundries

    % Display image with overlayed boundries
    figure(1)
    imshow(uint8(normalize0to1(double(cyto))*255),[]);
    hold on
    % Display color overlay
    labelled_cyto_rgb = label2rgb(cell_mask, 'jet', [1 1 1], 'shuffle');
    himage = imshow(labelled_cyto_rgb,[]);
    himage.AlphaData = cell_mask*.3;
    plot(Cell.Ycoord,Cell.Xcoord,'or','markersize',2,'markerfacecolor','g','markeredgecolor','g')
    pause
  end
end

