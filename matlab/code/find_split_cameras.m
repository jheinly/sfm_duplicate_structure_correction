function [camera_pair_indices] = find_split_cameras(camera_pairs,...
    group_assignments, group_sizes, group_idx1, group_idx2)

%num_camera_pairs = size(camera_pairs, 1);
%camera_pair_flags = false(num_camera_pairs, 1);

group_assignments(group_sizes < 2) = -1;
camera_pair_assignments = group_assignments(camera_pairs);

valid_flags1 =...
    camera_pair_assignments(:,1) ~= -1 &...
    camera_pair_assignments(:,2) ~= -1;
valid_flags2 =...
    camera_pair_assignments(:,1) ~= camera_pair_assignments(:,2);
valid_flags3 =...
    any(camera_pair_assignments == group_idx1, 2);
valid_flags4 =...
    any(camera_pair_assignments == group_idx2, 2);

camera_pair_flags = valid_flags1 & valid_flags2 & valid_flags3 & valid_flags4;

% for i = 1:num_camera_pairs
%     cam1 = camera_pairs(i,1);
%     cam2 = camera_pairs(i,2);
%     
%     group1 = group_assignments(cam1);
%     group2 = group_assignments(cam2);
%     
%     if group1 == group2
%         continue
%     end
%     
%     if group_sizes(group1) < 2 || group_sizes(group2) < 2
%         continue
%     end
%     
%     if ~any(group1 == [group_idx1, group_idx2]) ||...
%             ~any(group2 == [group_idx1, group_idx2])
%         continue
%     end
%     
%     camera_pair_flags(i) = true;
% end

camera_pair_indices = find(camera_pair_flags);

end % function
