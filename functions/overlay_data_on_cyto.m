function labelled_with_trace = overlay_data_on_cyto(CellsTable, imgs, col_name)
    labelled_with_trace = cell(size(imgs)); % cell matrix
    timepoints = unique(CellsTable.Time);
    for ii=length(timepoints)
        time=timepoints(ii);
        fprintf('[overlay_data_on_cyto.m] Visualizing frame %d\n',time)
        CellsInFrame = CellsTable(CellsTable.Time==time,:);
        boundaries_cyto = CellsInFrame.cyto_boundaries;
        if strcmp(class(boundaries_cyto),'cell')
          boundaries_cyto_new = cell(size(boundaries_cyto));
          for i=1:height(CellsInFrame)
            boundaries_cyto_new{i} = str2num(boundaries_cyto{i}); % boundaries are stored as space seperated char in CSVs
          end
          boundaries_cyto = boundaries_cyto_new;
        end
        point_in_time_traces = cell(size(imgs,1), size(imgs,2));
        
        % colour cyto
        for i=1:height(CellsInFrame)
          point_in_time = zeros(size(imgs,1), size(imgs,2));
          % label id
          point_in_time(boundaries_cyto{i}) = i;
          % fill in perimeter of nucleus
          point_in_time = imfill(point_in_time,'holes');
          % label trace
          point_in_time_traces(find(point_in_time)) = CellsInFrame{i,col_name};
        end
        labelled_with_trace(:,:,ii) = point_in_time_traces;
    end
end
