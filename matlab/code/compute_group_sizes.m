function [group_sizes] = compute_group_sizes(group_assignments)

    num_groups = max(group_assignments);
    group_sizes = zeros(num_groups, 1);
    for i = 1:num_groups
        group_sizes(i) = sum(group_assignments == i);
    end

end
