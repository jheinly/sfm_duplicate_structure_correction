function [edge_conflict, num_split_cameras] = compute_edge_conflict2(...
    split_camera_task, camera_observations, camera_observation_segments, camera_pair_segments,...
    visibility_matrix, image_folder, camera_data)

if ~exist('image_folder', 'var')
    image_folder = '';
    camera_data = [];
end

split_camera_pairs = split_camera_task.camera_pairs;
group_assignments = split_camera_task.group_assignments;

num_split_camera_pairs = size(split_camera_pairs, 1);

num_split_cameras = num_split_camera_pairs;
if num_split_camera_pairs == 0
    edge_conflict = 0;
    return
end

split_cameras_conflict = zeros(num_split_camera_pairs, 1);

for pair_idx = 1:num_split_camera_pairs
    cam_idx1 = split_camera_pairs(pair_idx, 1);
    cam_idx2 = split_camera_pairs(pair_idx, 2);
    
    index = find(...
        camera_pair_segments.camera_pairs(:,1) == cam_idx1 &...
        camera_pair_segments.camera_pairs(:,2) == cam_idx2);
    
    [conflicting_indices1, conflicting_indices2] = compute_conflicting_indices2(...
        camera_observations, camera_observation_segments,...
        camera_pair_segments.pair_data{index},...
        camera_pair_segments.valid_flags1_to2{index},...
        camera_pair_segments.valid_flags2_to1{index},...
        camera_pair_segments.projected_points{index}, visibility_matrix,...
        group_assignments, cam_idx1, cam_idx2, image_folder, camera_data);
    
    %split_cameras_conflict(i) =...
    %    length(conflicting_indices1) + length(conflicting_indices2);
    split_cameras_conflict(pair_idx) =...
        min(length(conflicting_indices1), length(conflicting_indices2));
end

edge_conflict = mean(split_cameras_conflict);

end % function
