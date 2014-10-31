function [visibility_matrix] = create_visibility_matrix(...
    point_observations, camera_data, point_data)

visibility_matrix = false(camera_data.num_cameras, point_data.num_points);

for point_idx = 1:length(point_observations)
    camera_indices = point_observations{point_idx}.camera_indices;
    visibility_matrix(camera_indices, point_idx) = true;
end

end % function
