function [common_point_flags] = identify_common_points_between_groups(...
    visibility_matrix, group_assignments, group_idx1, group_idx2)

group_point_flags1 = visibility_matrix(group_assignments == group_idx1, :);
group_point_flags2 = visibility_matrix(group_assignments == group_idx2, :);

group_point_flags1 = any(group_point_flags1, 1);
group_point_flags2 = any(group_point_flags2, 1);

common_point_flags = group_point_flags1 & group_point_flags2;

end % function
