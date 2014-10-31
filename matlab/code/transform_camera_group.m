function [new_camera_data, new_point_data, new_visibility_matrix,...
    new_connected_camera_matrix, new_camera_observations] =...
    transform_camera_group(camera_data, point_data,...
    visibility_matrix, camera_observations, group_assignments,...
    group_idx1, group_idx2, similarity,...
    disconnected_inlier_point_indices, common_point_flags,...
    min_common_points_for_connection)

% GOAL: Transform camera group 1 (group_idx1) so that it aligns with camera group 2.

new_camera_data = camera_data;
new_point_data = point_data;
new_visibility_matrix = visibility_matrix;
new_camera_observations = camera_observations;

% ----------------------------------------
% Update camera positions and orientations

for cam_idx = 1:camera_data.num_cameras
    if group_assignments(cam_idx) ~= group_idx1
        continue
    end
    
    center = camera_data.centers(:,cam_idx);
    new_camera_data.centers(:,cam_idx) = similarity * [center; 1];
    
    R = camera_data.orientations{cam_idx};
    new_camera_data.orientations{cam_idx} = similarity(:,1:3) * R;
end

% ----------------------
% Update point positions

common_point_indices = find(common_point_flags);
num_common_points = length(common_point_indices);

old_num_points = size(point_data.xyzs, 2);
new_num_points = old_num_points + num_common_points;

new_common_point_indices = old_num_points + [1:num_common_points];

% Transform the points unique to camera group 1
camera_flags1 = group_assignments == group_idx1;
point_flags1 = any(visibility_matrix(camera_flags1, :), 1);
point_flags1 = point_flags1 & ~common_point_flags;
points1 = point_data.xyzs(:, point_flags1);
points1 = [points1; ones(1, size(points1, 2))];
points1 = similarity * points1;
new_point_data.xyzs(:, point_flags1) = points1;

common_points = point_data.xyzs(:, common_point_flags);
common_points = [common_points; ones(1, size(common_points, 2))];
common_points = similarity * common_points;
new_point_data.xyzs = [new_point_data.xyzs common_points];
new_point_data.num_points = new_num_points;

% ------------------------------
% Update point visibility matrix

new_visibility_matrix =...
    [new_visibility_matrix false(camera_data.num_cameras, num_common_points)];

for cam_idx = 1:camera_data.num_cameras
    if group_assignments(cam_idx) ~= group_idx1
        continue
    end
    
    % Move observations of the common points in the first camera group to the
    % newly duplicated points.
    flags = new_visibility_matrix(cam_idx, common_point_indices);
    new_visibility_matrix(cam_idx, common_point_indices) = false;
    new_visibility_matrix(cam_idx, old_num_points+1:new_num_points) = flags;
end

% Inlier points should be made visible in both images
for i = 1:size(disconnected_inlier_point_indices, 2)
    idx1 = disconnected_inlier_point_indices(1,i);
    idx2 = disconnected_inlier_point_indices(2,i);
    
    cameras_seeing1 = new_visibility_matrix(:,idx1);
    cameras_seeing2 = new_visibility_matrix(:,idx2);
    
    new_visibility_matrix(cameras_seeing1, idx2) = true;
    new_visibility_matrix(cameras_seeing2, idx1) = true;
end

% Remove any cameras that aren't in either of the two groups under consideration
current_camera_flags = (group_assignments == group_idx1) | (group_assignments == group_idx2);
new_visibility_matrix(~current_camera_flags, :) = false;

% ------------------------------
% Update connected camera matrix

new_connected_camera_matrix = compute_connected_camera_matrix(...
    new_visibility_matrix, min_common_points_for_connection);

% --------------------------
% Update camera observations

parfor cam_idx = 1:camera_data.num_cameras
    if group_assignments(cam_idx) ~= group_idx1
        continue
    end
    
    % Replace point indices
    % We assume that common_point_indices is sorted so that we can use
    % ismembc and ismembc2
    flags = ismembc(camera_observations{cam_idx}.point_indices, common_point_indices);
    indices = ismembc2(camera_observations{cam_idx}.point_indices, common_point_indices);
    indices = indices(flags);
    %[flags, indices] = ismember(...
    %    camera_observations{cam_idx}.point_indices, common_point_indices);
    %indices = indices(flags);
    new_camera_observations{cam_idx}.point_indices(flags) = new_common_point_indices(indices);
    
    % We need to keep the point indices in sorted order.
    [vals, sorted_indices] = sort(new_camera_observations{cam_idx}.point_indices, 'ascend');
    new_camera_observations{cam_idx}.point_indices = vals;
    new_camera_observations{cam_idx}.feature_indices =...
        new_camera_observations{cam_idx}.feature_indices(sorted_indices);
    new_camera_observations{cam_idx}.locations_2d =...
        new_camera_observations{cam_idx}.locations_2d(:,sorted_indices);
end

end % function
