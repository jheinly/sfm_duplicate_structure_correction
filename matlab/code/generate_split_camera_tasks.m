function [split_camera_tasks] = generate_split_camera_tasks(...
    camera_tree, connected_camera_matrix, camera_data, point_data,...
    camera_observations, max_baseline_angle, max_split_cameras_per_edge)

init_matlabpool(12);

[cams1, cams2] = find(triu(connected_camera_matrix, 1));
camera_pairs = [cams1, cams2];
baseline_angles = compute_baseline_angles_between_camera_pairs2(...
    camera_pairs, camera_data, point_data, camera_observations);

valid_flags = baseline_angles < max_baseline_angle;
camera_pairs = camera_pairs(valid_flags, :);
baseline_angles = baseline_angles(valid_flags);

disp(['Original # camera pairs: ' num2str(length(baseline_angles))])

num_edges = get_num_edges_in_tree(camera_tree);
num_cameras = camera_data.num_cameras;

split_camera_tasks = cell(1, num_edges);

parfor edge_idx = 1:num_edges
    [group_sizes, group_assignments, cam_idx1, cam_idx2] = split_camera_tree(...
        camera_tree, edge_idx, num_cameras);
    group_idx1 = group_assignments(cam_idx1);
    group_idx2 = group_assignments(cam_idx2);
    split_camera_tasks{edge_idx} = generate_split_camera_tasks_helper(...
        camera_pairs, group_assignments, group_sizes, group_idx1, group_idx2,...
        baseline_angles, max_split_cameras_per_edge);
end

end % function
