disp(' ')
disp('Splitting...')

camera_tree_splitting_tasks = {};
camera_tree_splitting_tasks{end+1} = camera_tree;
split_camera_trees = {};
iteration_number = 1;

while ~isempty(camera_tree_splitting_tasks)
    current_camera_tree = camera_tree_splitting_tasks{end};
    camera_tree_splitting_tasks(end) = [];
    
    % --------------------------------------------------------------------------
    disp(' ')
    disp('Generating split camera tasks...')
    timer = tic;
    split_camera_tasks = generate_split_camera_tasks(...
        current_camera_tree, connected_camera_matrix, camera_data, point_data,...
        camera_observations, max_baseline_angle, max_split_cameras_per_edge);
    toc(timer)
    disp('Generating split camera tasks done')
    
    % --------------------------------------------------------------------------
    disp(' ')
    disp('Computing camera pair segments...')
    timer = tic;
    camera_pair_segments = compute_camera_pair_segments2(...
        split_camera_tasks, camera_data, point_data, camera_observations, segmentation_folder);
    toc(timer)
    disp('Computing camera pair segments done')
    
    % --------------------------------------------------------------------------
    disp(' ')
    disp('Computing spanning tree conflict...')
    timer = tic;
    edge_conflict = compute_spanning_tree_conflict2(...
        split_camera_tasks,...
        camera_observations, camera_observation_segments, camera_pair_segments,...
        visibility_matrix, image_folder, camera_data);
    toc(timer)
    disp('Computing spanning tree conflict done')
    
    [max_conflict_val, conflicting_edge_idx] = max(edge_conflict);
    [group_sizes, group_assignments] = split_camera_tree(current_camera_tree, conflicting_edge_idx, camera_data.num_cameras);
    
    extra = '';
    if max_conflict_val < conflict_threshold
        extra = '_done';
    end

    % --------------------------------------------------------------------------
    if enable_spanning_tree_visualization
        disp(' ')
        disp('Visualizing spanning tree conflict...')
        timer = tic;
        visualize_camera_tree(current_camera_tree, camera_data, model_name,...
            [figures_folder '/' model_name '_conflict_' num2str(iteration_number) extra],...
            {edge_label_conflict_class(current_camera_tree, edge_conflict)}, group_assignments,...
            [], graphviz_sfdp_exe);
        if enable_images_in_spanning_tree
            visualize_camera_tree(current_camera_tree, camera_data, model_name,...
                [figures_folder '/' model_name '_conflict_' num2str(iteration_number) extra],...
                {edge_label_conflict_class(current_camera_tree, edge_conflict)}, group_assignments,...
                thumbnail_folder, graphviz_sfdp_exe);
        end
        toc(timer)
        disp('Visualizing spanning tree conflict done')
    end
    
    % --------------------------------------------------------------------------
    disp(' ')
    disp(['Max Conflict: ' num2str(max_conflict_val)])
    
    if max_conflict_val >= conflict_threshold
        disp('Further splitting required...')
        
        [sorted_sizes, sorted_sizes_idx] = sort(group_sizes, 'descend');
        disp(['Group Sizes: ' num2str(sorted_sizes(1:2)')])

        group1_flags = group_assignments == sorted_sizes_idx(1);
        group2_flags = group_assignments == sorted_sizes_idx(2);

        camera_tree1 = current_camera_tree;
        camera_tree2 = current_camera_tree;

        camera_tree1(~group1_flags, :) = 0;
        camera_tree1(:, ~group1_flags) = 0;
        camera_tree2(~group2_flags, :) = 0;
        camera_tree2(:, ~group2_flags) = 0;
        
        camera_tree_splitting_tasks{end+1} = camera_tree1;
        camera_tree_splitting_tasks{end+1} = camera_tree2;
    else
        disp('Done splitting this tree.')
        split_camera_trees{end+1} = current_camera_tree;
    end
    
    iteration_number = iteration_number + 1;
end
