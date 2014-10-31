function [edge_index] = find_edge_index(camera_tree, cam_idx1, cam_idx2)

    [cams1, cams2] = find(camera_tree);
    
    edge_index = find(...
        (cams1 == cam_idx1 | cams1 == cam_idx2) &...
        (cams2 == cam_idx1 | cams2 == cam_idx2));

end
