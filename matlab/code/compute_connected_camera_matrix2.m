function [connected_camera_matrix] = compute_connected_camera_matrix2(...
    camera_observations, min_common_points_for_connection)

num_cameras = length(camera_observations);
connected_camera_matrix = false(num_cameras, num_cameras);

init_matlabpool(12);

num_tasks = (num_cameras * (num_cameras - 1)) / 2;
linear_valid_connections = false(num_tasks, 1);
camera_indices = zeros(num_tasks, 2);

idx = 1;
for cam_idx1 = 1:num_cameras-1
    for cam_idx2 = cam_idx1+1:num_cameras
        camera_indices(idx,:) = [cam_idx1, cam_idx2];
        idx = idx + 1;
    end
end

parfor task_idx = 1:num_tasks
    cam1 = camera_indices(task_idx, 1);
    cam2 = camera_indices(task_idx, 2);
    
    points1 = camera_observations{cam1}.point_indices;
    points2 = camera_observations{cam2}.point_indices;
    
    % We assume that points_indices1 and point_indices2 are sorted.
    intersect_size = sum(ismembc(points1, points2));
    
    linear_valid_connections(task_idx) = intersect_size >= min_common_points_for_connection;
end

idx = 1;
for cam_idx1 = 1:num_cameras-1
    for cam_idx2 = cam_idx1+1:num_cameras
        if linear_valid_connections(idx)
            connected_camera_matrix(cam_idx1, cam_idx2) = true;
            connected_camera_matrix(cam_idx2, cam_idx1) = true;
        end
        idx = idx + 1;
    end
end

% for cam_idx1 = 1:num_cameras-1
%     for cam_idx2 = cam_idx1+1:num_cameras
%         points1 = camera_observations{cam_idx1}.point_indices;
%         points2 = camera_observations{cam_idx2}.point_indices;
%         
%         %intersect_size = length(intersect(points1, points2));
%         
%         % We assume that points1 and points2 are sorted
%         intersect_size = sum(ismembc(points1, points2));
%         
%         if intersect_size >= min_common_points_for_connection
%             connected_camera_matrix(cam_idx1, cam_idx2) = true;
%             connected_camera_matrix(cam_idx2, cam_idx1) = true;
%         end
%     end
% end

end
