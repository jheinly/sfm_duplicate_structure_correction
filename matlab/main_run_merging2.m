num_split_trees = length(split_camera_trees);

if num_split_trees == 1
    disp(' ')
    disp('Done, no need to do merging')
    return
end

disp(' ')
disp('Merging...')

group_assignments = compute_split_group_assignments(split_camera_trees);
group_sizes = compute_group_sizes(group_assignments);

disconnected_inliers = find_disconnected_inliers(...
    inlier_matches, camera_observations, camera_data);

distance_threshold_3d =...
    compute_distance_threshold_3d(camera_data, point_data, ransac_distance_percentage);

merged_num_inliers = zeros(num_split_trees, num_split_trees);
merged_inlier_indices = cell(num_split_trees, num_split_trees);
merged_similarities = cell(num_split_trees, num_split_trees);

for group_idx1 = 1:num_split_trees - 1
    for group_idx2 = group_idx1+1:num_split_trees
        
        % Find disconnected inliers between these two camera groups
        common_point_flags = identify_common_points_between_groups(...
            visibility_matrix, group_assignments, group_idx1, group_idx2);
        [disconnected_inlier_point_indices, all_disconnected_inlier_point_indices] =...
            find_disconnected_inlier_point_indices(...
            disconnected_inliers, common_point_flags, group_assignments,...
            group_idx1, group_idx2);
        
        if isempty(disconnected_inlier_point_indices)
            disp(' ')
            disp('No disconnected inliers')
            break
        end
        
        all_disconnected_inlier_points1 =...
            point_data.xyzs(:,all_disconnected_inlier_point_indices(1,:));
        all_disconnected_inlier_points2 =...
            point_data.xyzs(:,all_disconnected_inlier_point_indices(2,:));
        
        all_disconnected_inlier_points = [all_disconnected_inlier_points1; all_disconnected_inlier_points2];
        
        disconnected_inlier_points1 =...
            point_data.xyzs(:,disconnected_inlier_point_indices(1,:));
        disconnected_inlier_points2 =...
            point_data.xyzs(:,disconnected_inlier_point_indices(2,:));
        
        disconnected_inlier_points = [disconnected_inlier_points1; disconnected_inlier_points2];
        
        merge_attempt_idx = 0;
        while true
            merge_attempt_idx = merge_attempt_idx + 1;
            
            if merge_attempt_idx > max_num_merge_tries
                disp(' ')
                disp('Merging failed, exceeded maximum number of merge attempts')
                break
            end
            
            if size(disconnected_inlier_points, 2) < min_common_points_for_connection
                disp(' ')
                disp(['Merging failed, not enough points: ' num2str(size(disconnected_inlier_points, 2))])
                break
            end
            
            % ------------------------------------------------------------------
            % Attempt to find a similarity transform
            disp(' ')
            disp('Running RANSAC...')
            timer = tic;
            [similarity, similarity_inliers] = ransac_3d_similarity(...
                disconnected_inlier_points, distance_threshold_3d);
            toc(timer)
            disp('Running RANSAC done')
            
            if isempty(similarity)
                disp('Merging failed, empty similarity')
                break
            end
            
            fprintf('%.8f, %.8f, %.8f, %.8f;\n%.8f, %.8f, %.8f, %.8f;\n%.8f, %.8f, %.8f, %.8f;\n',...
                similarity(1,1), similarity(1,2), similarity(1,3), similarity(1,4),...
                similarity(2,1), similarity(2,2), similarity(2,3), similarity(2,4),...
                similarity(3,1), similarity(3,2), similarity(3,3), similarity(3,4));
            
            all_similarity_inliers = compute_similarity_inliers(...
                similarity, all_disconnected_inlier_points, distance_threshold_3d);
            
            num_inliers = length(all_similarity_inliers);
            
            disp(' ')
            disp(['Expanded inliers: ' num2str(num_inliers) ' / ' num2str(size(all_disconnected_inlier_point_indices,2))])
            
            % Merging failed, not enough inliers, stop merging attempts
            if num_inliers < min_common_points_for_connection
                disp(['Merging failed, not enough inliers: ' num2str(num_inliers)])
                break
            end
            
            % ------------------------------------------------------------------
            disp(' ')
            disp('Transforming camera group...')
            timer = tic;
            [new_camera_data, new_point_data, new_visibility_matrix,...
                new_connected_camera_matrix, new_camera_observations] =...
                transform_camera_group(camera_data, point_data,...
                visibility_matrix, camera_observations, group_assignments,...
                group_idx1, group_idx2, similarity,...
                all_disconnected_inlier_point_indices(:,all_similarity_inliers),...
                common_point_flags, min_common_points_for_connection);
            toc(timer)
            disp('Transforming camera group done')
            
            %% -----------------------------------------------------------------

            disp(' ')
            disp('Computing camera observation segments...')
            timer = tic;
            new_camera_observation_segments = compute_camera_observation_segments2(...
                new_camera_observations, new_camera_data, segmentation_folder);
            toc(timer)
            disp('Computing camera observation segments done')
            
            % ------------------------------------------------------------------
            disp(' ')
            disp('Generating split camera tasks...')
            timer = tic;
            split_camera_tasks = generate_split_camera_tasks_single_edge(...
                new_connected_camera_matrix, new_camera_data, new_point_data,...
                new_visibility_matrix, max_baseline_angle, max_split_cameras_per_edge,...
                group_assignments, group_sizes, group_idx1, group_idx2);
            toc(timer)
            disp('Generating split camera tasks done')

            % ------------------------------------------------------------------
            disp(' ')
            disp('Computing camera pair segments...')
            timer = tic;
            new_camera_pair_segments = compute_camera_pair_segments2(...
                split_camera_tasks, new_camera_data, new_point_data,...
                new_camera_observations, segmentation_folder);
            toc(timer)
            disp('Computing camera pair segments done')
            
            % ------------------------------------------------------------------
            disp(' ')
            disp('Computing edge conflict...')
            timer = tic;
            [conflict, num_split_cameras] = compute_edge_conflict2_merging(...
                split_camera_tasks{1}, new_camera_observations,...
                new_camera_observation_segments, new_camera_pair_segments,...
                new_visibility_matrix, all_inlier_matches, all_inlier_matches_camera_indices,...
                segmentation_folder, camera_data);%, image_folder);
            toc(timer)
            disp('Computing edge conflict done')

            % ------------------------------------------------------------------
            % Merging failed, too much conflict, try to merge again
            if conflict >= conflict_threshold
                disp(' ')
                disp(['Merging failed, too much conflict: ' num2str(conflict)])
                plot_merged_model_inliers(new_camera_data, new_point_data, new_visibility_matrix,...
                    group_assignments, group_idx1, group_idx2,...
                    all_disconnected_inlier_point_indices(:,all_similarity_inliers));
                title(['Too much conflict: ' num2str(conflict) ', inliers = '...
                    num2str(length(similarity_inliers)) ' / ' num2str(size(disconnected_inlier_points,2))])
                disconnected_inlier_point_indices(:,similarity_inliers) = [];
                disconnected_inlier_points(:,similarity_inliers) = [];
                continue
            end
            
            % ------------------------------------------------------------------
            % Merging failed, no overlapping cameras, try to merge again
            if num_split_cameras == 0
                disp(' ')
                disp('Merging failed, no overlapping cameras')
                plot_merged_model_inliers(new_camera_data, new_point_data, new_visibility_matrix,...
                    group_assignments, group_idx1, group_idx2,...
                    all_disconnected_inlier_point_indices(:,all_similarity_inliers));
                title(['No overlapping cameras, inliers = '...
                    num2str(length(similarity_inliers)) ' / ' num2str(size(disconnected_inlier_points,2))])
                disconnected_inlier_point_indices(:,similarity_inliers) = [];
                disconnected_inlier_points(:,similarity_inliers) = [];
                continue
            end
            
            % ------------------------------------------------------------------
            % Merging succeeded
            disp(' ')
            disp(['Merging succeeded, inliers = ' num2str(num_inliers) ', conflict = ' num2str(conflict)])
            plot_merged_model_inliers(new_camera_data, new_point_data, new_visibility_matrix,...
                group_assignments, group_idx1, group_idx2,...
                all_disconnected_inlier_point_indices(:,all_similarity_inliers));
            title(['Merging succeeded, inliers = ' num2str(num_inliers) ', conflict = ' num2str(conflict)])
            merged_num_inliers(group_idx1, group_idx2) = num_inliers;
            merged_num_inliers(group_idx2, group_idx1) = num_inliers;
            merged_inlier_indices{group_idx1, group_idx2} = all_disconnected_inlier_point_indices(:,all_similarity_inliers);
            merged_inlier_indices{group_idx2, group_idx1} = all_disconnected_inlier_point_indices(:,all_similarity_inliers);
            merged_similarities{group_idx1, group_idx2} = similarity;
            merged_similarities{group_idx2, group_idx1} = similarity;
            break
        end
    end
end
