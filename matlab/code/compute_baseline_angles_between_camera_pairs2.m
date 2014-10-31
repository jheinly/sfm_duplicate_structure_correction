function [angles] = compute_baseline_angles_between_camera_pairs2(...
    camera_pairs, camera_data, point_data, camera_observations)

num_pairs = size(camera_pairs, 1);
angles = zeros(num_pairs, 1);

init_matlabpool(12);
    
parfor i = 1:num_pairs
    cam_idx1 = camera_pairs(i,1);
    cam_idx2 = camera_pairs(i,2);

    angles(i) = compute_baseline_angle_between_cameras2(cam_idx1, cam_idx2,...
        camera_data, point_data, camera_observations);
end

% for i = 1:num_pairs
%     cam_idx1 = camera_pairs(i,1);
%     cam_idx2 = camera_pairs(i,2);
% 
%     angles(i) = compute_baseline_angle_between_cameras2(cam_idx1, cam_idx2,...
%         camera_data, point_data, camera_observations);
% end

end % function
