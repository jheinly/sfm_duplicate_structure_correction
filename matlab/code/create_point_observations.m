function [point_observations] = create_point_observations(camera_observations, num_points)

point_observations = cell(1,num_points);
for i = 1:num_points
    point_observations{i} = struct(...
        'num_observations', 0,...
        'camera_indices', [],...
        'feature_indices', [],...
        'locations_2d', []);
end

for cam_idx = 1:length(camera_observations)
    for i = 1:length(camera_observations{cam_idx}.point_indices)
        pt_idx = camera_observations{cam_idx}.point_indices(i);
        
        num = point_observations{pt_idx}.num_observations + 1;
        point_observations{pt_idx}.num_observations = num;
        
        point_observations{pt_idx}.camera_indices(num) = cam_idx;
        point_observations{pt_idx}.feature_indices(num) =...
            camera_observations{cam_idx}.feature_indices(i);
        point_observations{pt_idx}.locations_2d(:,num) =...
            camera_observations{cam_idx}.locations_2d(:,i);
    end
end

end % function
