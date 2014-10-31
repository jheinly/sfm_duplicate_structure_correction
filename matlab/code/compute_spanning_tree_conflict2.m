function [edge_conflict] = compute_spanning_tree_conflict2(...
    split_camera_tasks, camera_observations, camera_observation_segments,...
    camera_pair_segments, visibility_matrix, image_folder, camera_data)

num_edges = length(split_camera_tasks);
edge_conflict = zeros(num_edges, 1);

num_cameras = length(camera_observation_segments);

init_matlabpool(12);
%init_matlabpool(6);

progress = ParforProgMon('Conflict: ', num_edges, 1, 300, 80);

%debug_edge_idx = 7;%find_edge_index(camera_tree, 6, 15);
%debug_overlap = true;
debug_overlap = false;

parfor edge_idx = 1:num_edges
%for edge_idx = debug_edge_idx
    
    if debug_overlap
        conflict = compute_edge_conflict2(...
            split_camera_tasks{edge_idx}, camera_observations, camera_observation_segments,...
            camera_pair_segments, visibility_matrix, image_folder, camera_data);
        edge_conflict(edge_idx) = conflict;
    else
        conflict = compute_edge_conflict2(...
            split_camera_tasks{edge_idx}, camera_observations, camera_observation_segments,...
            camera_pair_segments, visibility_matrix);
        edge_conflict(edge_idx) = conflict;
    end
    
    progress.increment();
end

progress.delete()

end % function
