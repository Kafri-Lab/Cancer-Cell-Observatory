function fun(SubsetTable)
  %% Do work on filtered data
  for cell_id=1:height(SubsetTable)
    Cell = SubsetTable(cell_id,:);
    % Load the image that the cell is found in
    if strcmp(Cell.ImageNamingScheme, 'Operetta')
      filename = char(Cell.FileName);
      filename(16) = char(Cell.CellCh);
    end
    filepath = sprintf('%s%s', char(Cell.ImageDir), filename);
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