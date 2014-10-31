function [new_group_assignments] = normalize_group_assignments(group_assignments)

group_sizes = compute_group_sizes(group_assignments);
[sorted_sizes, sorted_sizes_idx] = sort(group_sizes, 'descend');
num_groups = length(group_sizes);

new_group_assignments = group_assignments;

for i = 1:num_groups
    flags = group_assignments == sorted_sizes_idx(i);
    if sorted_sizes(i) > 1
        new_group_assignments(flags) = i;
    else
        new_group_assignments(flags) = 0;
    end
end

end % function
