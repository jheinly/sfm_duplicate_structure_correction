function [split_group_assignments] = compute_split_group_assignments(...
    split_camera_trees)

split_group_assignments = zeros(1, size(split_camera_trees{1},1));

num_trees = length(split_camera_trees);
for tree_idx = 1:num_trees
    [num_groups, group_assignments] = graphconncomp(...
        split_camera_trees{tree_idx}, 'Directed', false);
    group_sizes = compute_group_sizes(group_assignments);
    if sum(group_sizes > 1) > 1
        disp('ERROR: more than one group with size greater than 1.')
        return
    end
    [max_group_size, max_group_idx] = max(group_sizes);
    if max_group_size == 1
        disp('Warning: group of size 1.')
    end
    valid_cameras = group_assignments == max_group_idx;
    if any(valid_cameras & (split_group_assignments > 0))
        disp('ERROR: assigning camera to 2 or more groups')
        return
    end
    split_group_assignments(valid_cameras) = tree_idx;
end

if any(split_group_assignments == 0)
    disp('ERROR: 1 or more cameras not assigned to a group')
end

end % function
