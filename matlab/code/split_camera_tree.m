function [group_sizes, group_assignments, cam_idx1, cam_idx2] = split_camera_tree(...
    camera_tree, edge_index, num_cameras)

    [cams1, cams2] = find(camera_tree);
    
    cam_idx1 = cams1(edge_index);
    cam_idx2 = cams2(edge_index);

    cams1(edge_index) = [];
    cams2(edge_index) = [];

    new_tree = sparse([cams1; cams2], [cams2; cams1], 1, num_cameras, num_cameras);

    [num_groups, group_assignments] = graphconncomp(new_tree, 'Directed', false);
    group_sizes = zeros(num_groups, 1);
    for i = 1:num_groups
        group_sizes(i) = sum(group_assignments == i);
    end

end
