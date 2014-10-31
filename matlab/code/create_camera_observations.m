function [camera_observations] = create_camera_observations(...
    point_observations, visibility_matrix)

num_cameras = size(visibility_matrix, 1);

camera_observations = cell(1, num_cameras);

num_observations_per_camera = sum(visibility_matrix, 2);

for cam_idx = 1:num_cameras
    num_observations = num_observations_per_camera(cam_idx);
    camera_observations{cam_idx} = struct(...
        'num_observations', 0,...
        'point_indices', zeros(1, num_observations, 'int32'),...
        'feature_indices', zeros(1, num_observations, 'int32'),...
        'locations_2d', zeros(2, num_observations, 'single'));
end

for point_idx = 1:length(point_observations)
    for observe_idx = 1:point_observations{point_idx}.num_observations
        cam_idx = point_observations{point_idx}.camera_indices(observe_idx);
        feature_idx = point_observations{point_idx}.feature_indices(observe_idx);
        location_2d = point_observations{point_idx}.locations_2d(:, observe_idx);
        
        % We have found a new observation for this camera, so increment the
        % number of observations found so far for this camera (this count starts
        % at 0).
        num_observations = camera_observations{cam_idx}.num_observations + 1;
        camera_observations{cam_idx}.num_observations = num_observations;
        
        camera_observations{cam_idx}.point_indices(num_observations) = point_idx;
        camera_observations{cam_idx}.feature_indices(num_observations) = feature_idx;
        camera_observations{cam_idx}.locations_2d(:,num_observations) = location_2d;
    end
end

for cam_idx = 1:num_cameras
    if length(camera_observations{cam_idx}.point_indices) ~=...
            camera_observations{cam_idx}.num_observations
        disp('ERROR: num_observations does not agree')
    end
end

end % function
