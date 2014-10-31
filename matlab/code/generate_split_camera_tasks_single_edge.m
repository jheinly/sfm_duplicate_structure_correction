function [split_camera_tasks] = generate_split_camera_tasks_single_edge(...
    connected_camera_matrix, camera_data, point_data,...
    visibility_matrix, max_baseline_angle, max_split_cameras_per_edge,...
    group_assignments, group_sizes, group_idx1, group_idx2)

[cams1, cams2] = find(triu(connected_camera_matrix, 1));
camera_pairs = [cams1, cams2];
% Use the slower baseline angle method because it uses the visibility matrix
% which is up-to-date after the merge whereas the camera observations are
% missing the inlier point indices.
baseline_angles = compute_baseline_angles_between_camera_pairs(...
    camera_pairs, camera_data, point_data, visibility_matrix);
%baseline_angles = compute_baseline_angles_between_camera_pairs2(...
%    camera_pairs, camera_data, point_data, camera_observations);

valid_flags = baseline_angles < max_baseline_angle;
camera_pairs = camera_pairs(valid_flags, :);
baseline_angles = baseline_angles(valid_flags);

split_camera_tasks = cell(1, 1);
split_camera_tasks{1} = generate_split_camera_tasks_helper(...
    camera_pairs, group_assignments, group_sizes, group_idx1, group_idx2,...
    baseline_angles, max_split_cameras_per_edge);

end % function
