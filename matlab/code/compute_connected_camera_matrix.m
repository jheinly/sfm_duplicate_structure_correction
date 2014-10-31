function [connected_camera_matrix] = compute_connected_camera_matrix(...
    visibility_matrix, min_common_points_for_connection)

num_cameras = size(visibility_matrix, 1);

connected_camera_matrix = false(num_cameras, num_cameras);

for cam_idx1 = 1:num_cameras-1
    for cam_idx2 = cam_idx1+1:num_cameras
        visible_points1 = visibility_matrix(cam_idx1, :);
        visible_points2 = visibility_matrix(cam_idx2, :);
        
        if sum(visible_points1 & visible_points2) >= min_common_points_for_connection
            connected_camera_matrix(cam_idx1, cam_idx2) = true;
            connected_camera_matrix(cam_idx2, cam_idx1) = true;
        end
    end
    %disp(cam_idx1)
end

end
