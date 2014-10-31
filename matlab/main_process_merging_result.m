% Handle cases where there are 3 or more merged models

if num_split_trees == 1
    disp(' ')
    disp('Done, no need to process merging result')
    return
end

[num_groups, group_assignments] = graphconncomp(sparse(merged_num_inliers), 'Directed', false);
group_sizes = compute_group_sizes(group_assignments);

if max(group_sizes) == 3 && num_groups == 1
    merged_success = merged_num_inliers > 0;
    [~, middle_group] = max(sum(merged_success));
    groups = setdiff([1 2 3], middle_group);
    first_group = groups(1);
    second_group = groups(2);
    
    group_assignments = compute_split_group_assignments(split_camera_trees);
    
    first_group_transform = merged_similarities{first_group, middle_group};
    second_group_transform = merged_similarities{second_group, middle_group};
    
    if middle_group < first_group
        first_group_transform = inv([first_group_transform; [0 0 0 1]]);
        first_group_transform = first_group_transform(1:3, :);
    end
    if middle_group < second_group
        second_group_transform = inv([second_group_transform; [0 0 0 1]]);
        second_group_transform = second_group_transform(1:3, :);
    end
    
    plot_3_merged_models(camera_data, point_data, visibility_matrix, group_assignments,...
        first_group, second_group, middle_group,...
        first_group_transform, second_group_transform);
end
