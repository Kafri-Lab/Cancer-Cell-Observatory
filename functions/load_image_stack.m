function img_stack = fun(SubsetTable)
  % Load images
  count=1;
  well = SubsetTable.FileName{1}(1:12); % eg. r05c02f19p01
  channel = SubsetTable.CellCh(1); % eg. 1
  img_dir = SubsetTable.ImageDir{1};
  for t=sort(unique(SubsetTable.Time))'
    img_file = sprintf('%s/%s-ch%dsk%dfk1fl1.tiff',img_dir,well,channel,t);
    fprintf('Loading image file "%s"\n',img_file);
    img = imread(img_file);
    if ~exist('img_stack')
      img_stack = zeros(size(img,1),size(img,2),length(unique(SubsetTable.Time)));
    end
    img_stack(:,:,count)=img;
    count=count+1;
  end
end