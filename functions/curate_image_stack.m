function labels = fun(labelled_stack,fig)
  % MUST BE USED WITH IMSHOW3D
  fprintf('[curate_image_stack.m] Infinite curation loop started. Press "q" to quit.\n')
  labels={};
  while true
    [x,y,button] = ginput(1);
    if x<1 | y<1 % skip if click is outside of image
        continue
    end
    x=round(x);
    y=round(y);
    if length(size(labelled_stack))==2
      clicked_label=labelled_stack{y,x};
      z = NaN;
    else
      z = fig.Children(8).Value;
      clicked_label=labelled_stack{y,x,z};
    end
    if clicked_label
      labels{length(labels)+1}=clicked_label;
    end
    fprintf('Selected at x->%d, y->%d, z->%d, TraceID->%s. Total selected %d.\n',x,y,z,char(clicked_label),length(labels));
    key = waitforbuttonpress;
    if key == 1 % "q" was pressed so quit
      return
    end
  end
end