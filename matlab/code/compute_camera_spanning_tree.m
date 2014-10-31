function [camera_tree] = compute_camera_spanning_tree(...
    camera_observations)

num_cameras = length(camera_observations);
weights = zeros(num_cameras, num_cameras);

init_matlabpool(12);
%init_matlabpool(6);

num_tasks = (num_cameras * (num_cameras - 1)) / 2;
linear_weights = zeros(num_tasks, 1);
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
    
    size1 = length(points1);
    size2 = length(points2);
    % We assume that points_indices1 and point_indices2 are sorted.
    intersect_size = sum(ismembc(points1, points2));
    union_size = size1 + size2 - intersect_size;
    linear_weights(task_idx) = 1 - intersect_size / union_size;
end

idx = 1;
for cam_idx1 = 1:num_cameras-1
    for cam_idx2 = cam_idx1+1:num_cameras
        weight = linear_weights(idx);
        weights(cam_idx1, cam_idx2) = weight;
        weights(cam_idx2, cam_idx1) = weight;
        idx = idx + 1;
    end
end

% for cam_idx1 = 1:num_cameras-1
%     for cam_idx2 = cam_idx1+1:num_cameras
%         point_indices1 = camera_observations{cam_idx1}.point_indices;
%         point_indices2 = camera_observations{cam_idx2}.point_indices;
%         
%         size1 = length(point_indices1);
%         size2 = length(point_indices2);
%         % We assume that points_indices1 and point_indices2 are sorted.
%         intersect_size = sum(ismembc(point_indices1, point_indices2));
%         union_size = size1 + size2 - intersect_size;
%         weight = -intersect_size / union_size;
%         %weight = length(intersect(point_indices1, point_indices2)) /...
%         %         length(union(point_indices1, point_indices2));
%         %weight = -weight;
%         
%         weights(cam_idx1, cam_idx2) = weight;
%         weights(cam_idx2, cam_idx1) = weight;
%     end
% end

[camera_tree, ~] = graphminspantree(sparse(weights), 'Method', 'Kruskal');

end % function
