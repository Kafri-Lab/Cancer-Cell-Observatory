function fun(PlateMap,filters)
  CuratedTableFull = table();
  for i=1:size(filters,2)
    % Select relevant experiments
    SubsetPlateMap = filter_table(PlateMap, filters(i));

    fprintf('[curate_cells.m] Load data\n');
    ResultTable = load_dataset(SubsetPlateMap);

    % Select relevant data
    SubsetTable = filter_table(ResultTable, filters(i));

    fprintf('[curate_cells.m] Load images\n');
    img_stack = load_image_stack(SubsetTable);
    
    fprintf('[curate_cells.m] Display cell movie\n');
    f = figure; imshow3D(img_stack,[]);
    imgs_to_gif(img_stack);

    fprintf('[curate_cells.m] Display colorized cell movie\n');
    overlay = overlay_cyto_on_cyto(SubsetTable,img_stack); % slow
    f = figure; imshow3D(overlay, []);
    colour_imgs_to_gif(overlay);

    choice = input('What kind of data would you like to curate? Typically "Trace" or "CellID"\n','s');

    fprintf('[curate_cells.m] Get labelled image stack where each pixel is set to the TraceID for that cell.\n');
    labelled_stack = overlay_data_on_cyto(SubsetTable,img_stack,choice); % slow

    fprintf('[curate_cells.m] User input with mouse to select which cell traces to keep\n');
    user_selected_cells = curate_image_stack(labelled_stack,f);

    fprintf('[curate_cells.m] Filter data down to only cells with curated TraceIDs\n');
    Filter.column = {sprintf('%s; ismember(%s,varargin{1})',choice,choice)}; % varargin{1} will map to user_selected_cells in the filter_table function.
    CuratedTable = filter_table(SubsetTable, Filter, user_selected_cells);

    fprintf('[curate_cells.m] Save movie of curated cells\n');
    curated_overlay = overlay_cyto_on_cyto(CuratedTable,img_stack);
    colour_imgs_to_gif(curated_overlay);

    CuratedTableFull = [CuratedTableFull; CuratedTable];
  end

  date_str = datestr(now,'yyyymmddTHHMMSS');
  filename = [date_str '_curated.csv'];
  fprintf('[curate_cells.m] Save curated cells to file: %s\n', filename);
  writetable(CuratedTableFull,filename);
end