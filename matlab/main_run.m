%% -----------------------------------------------------------------------------

total_timer = tic;

%% -----------------------------------------------------------------------------

disp(' ')
disp('Computing camera spanning tree...')
timer = tic;
camera_tree = compute_camera_spanning_tree(camera_observations);
toc(timer)
disp('Computing camera spanning tree done')

%% -----------------------------------------------------------------------------

if enable_spanning_tree_visualization
    disp(' ')
    disp('Visualizing camera spanning tree...')
    timer = tic;
    visualize_camera_tree(camera_tree, camera_data, model_name,...
        [figures_folder '/' model_name '_spanning_tree'],...
        {edge_label_baseline_angle_class(camera_data, point_data, visibility_matrix)}, [],...
        '', graphviz_sfdp_exe);
    if enable_images_in_spanning_tree
        visualize_camera_tree(camera_tree, camera_data, model_name,...
            [figures_folder '/' model_name '_spanning_tree'],...
            {edge_label_baseline_angle_class(camera_data, point_data, visibility_matrix)}, [],...
            thumbnail_folder, graphviz_sfdp_exe);
    end
    toc(timer)
    disp('Visualizing camera spanning tree done')
end

%% -----------------------------------------------------------------------------

disp(' ')
disp('Enforcing n-view points...')
timer = tic;
if isempty(inlier_matches_path)
    [point_data, point_observations, visibility_matrix,...
        camera_observations] = enforce_n_view_points_no_inliers(...
        point_data, point_observations, visibility_matrix,...
        camera_observations, min_views_per_point);
else
    [point_data, point_observations, visibility_matrix,...
        camera_observations, inlier_matches] = enforce_n_view_points(...
        point_data, point_observations, visibility_matrix,...
        camera_observations, inlier_matches, min_views_per_point);
end
toc(timer)
disp('Enforcing n-view points done')

%% -----------------------------------------------------------------------------

disp(' ')
disp('Computing connected camera matrix...')
timer = tic;
connected_camera_matrix = compute_connected_camera_matrix2(...
    camera_observations, min_common_points_for_connection);
toc(timer)
disp('Computing connected camera matrix done')

%% -----------------------------------------------------------------------------

disp(' ')
disp('Computing camera observation segments...')
timer = tic;
camera_observation_segments = compute_camera_observation_segments2(...
    camera_observations, camera_data, segmentation_folder);
toc(timer)
disp('Computing camera observation segments done')

%% -----------------------------------------------------------------------------

disp(' ')
disp('Main splitting...')
disp(' ')
splitting_timer = tic;

main_run_splitting2

toc(splitting_timer)
disp('Main splitting done')
disp(' ')

%% -----------------------------------------------------------------------------

disp(' ')
disp('Main merging...')
disp(' ')
merging_timer = tic;

main_run_merging2

toc(merging_timer)
disp('Main merging done')
disp(' ')

%% -----------------------------------------------------------------------------

disp(' ')
disp('Process merging...')
disp(' ')
merging_timer = tic;

main_process_merging_result

toc(merging_timer)
disp('Process merging done')
disp(' ')

%% -----------------------------------------------------------------------------

disp('TOTAL TIME')
toc(total_timer)

%% -----------------------------------------------------------------------------

% Create a new NVM file with the merged result. This is still exerimental, and
% may not work for all datasets.

%new_point_observations = create_point_observations(new_camera_observations, new_point_data.num_points);
%write_merged_nvm('merged.nvm', new_camera_data, new_point_data, new_point_observations);
