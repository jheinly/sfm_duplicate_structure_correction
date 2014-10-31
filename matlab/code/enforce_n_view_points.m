function [new_point_data, new_point_observations, new_visibility_matrix,...
    new_camera_observations, new_inlier_matches] = enforce_n_view_points(...
    point_data, point_observations, visibility_matrix,...
    camera_observations, inlier_matches, min_views_per_point)

init_matlabpool(12);

view_counts = sum(visibility_matrix, 1);
valid_point_flags = view_counts >= min_views_per_point;
valid_point_indices = int32(find(valid_point_flags));

old_num_points = length(view_counts);
new_num_points = length(valid_point_indices);

disp(['# Points: ' num2str(old_num_points) ' -> '...
    num2str(new_num_points)])

if old_num_points == new_num_points
    new_point_data = point_data;
    new_point_observations = point_observations;
    new_visibility_matrix = visibility_matrix;
    new_camera_observations = camera_observations;
    new_inlier_matches = inlier_matches;
    return
end

new_visibility_matrix = visibility_matrix(:, valid_point_flags);

new_point_data = point_data;
new_point_data.num_points = sum(valid_point_flags);
new_point_data.xyzs = new_point_data.xyzs(:, valid_point_flags);
new_point_data.rgbs = new_point_data.rgbs(:, valid_point_flags);

new_point_observations = point_observations(valid_point_flags);

new_camera_observations = camera_observations;
parfor cam_idx = 1:length(new_camera_observations)
    % valid_point_indices is sorted so we can use ismembc and ismembc2
    
    flags = ismembc(new_camera_observations{cam_idx}.point_indices, valid_point_indices);
    indices = ismembc2(new_camera_observations{cam_idx}.point_indices, valid_point_indices);
    
    %[flags, indices] = ismember(...
    %    new_camera_observations{cam_idx}.point_indices, valid_point_indices);
    
    indices = indices(flags);
    
    new_camera_observations{cam_idx}.num_observations = length(indices);
    new_camera_observations{cam_idx}.point_indices = indices;
    new_camera_observations{cam_idx}.feature_indices =...
        new_camera_observations{cam_idx}.feature_indices(flags);
    new_camera_observations{cam_idx}.locations_2d =...
        new_camera_observations{cam_idx}.locations_2d(:,flags);
end

old_num_inlier_matches = length(inlier_matches);
new_inlier_matches = cell(1,old_num_inlier_matches);
valid_inlier_matches_flags = false(1,old_num_inlier_matches);

parfor idx = 1:old_num_inlier_matches
    % valid_point_indices is sorted so we can use ismembc and ismembc2
    
    flags1 = ismembc(inlier_matches{idx}.point_indices(1,:), valid_point_indices);
    flags2 = ismembc(inlier_matches{idx}.point_indices(2,:), valid_point_indices);
    
%     [flags1, indices1] = ismember(...
%         inlier_matches{idx}.point_indices(1,:), valid_point_indices);
%     [flags2, indices2] = ismember(...
%         inlier_matches{idx}.point_indices(2,:), valid_point_indices);
    
    % Find inlier matches that had both observations turn into 3-view points
    flags = flags1 & flags2;
    if ~any(flags)
        continue
    end
    
    valid_inlier_matches_flags(idx) = true;
    
    indices1 = ismembc2(inlier_matches{idx}.point_indices(1,:), valid_point_indices);
    indices2 = ismembc2(inlier_matches{idx}.point_indices(2,:), valid_point_indices);
    
    indices1 = indices1(flags);
    indices2 = indices2(flags);
    
    new_inlier_matches{idx} = struct(...
        'camera_indices', inlier_matches{idx}.camera_indices,...
        'num_matches', length(indices1),...
        'feature_indices', inlier_matches{idx}.feature_indices(:,flags),...
        'point_indices', [indices1; indices2],...
        'locations_2d', inlier_matches{idx}.locations_2d(:,flags));
end

new_inlier_matches = new_inlier_matches(valid_inlier_matches_flags);

end % function
