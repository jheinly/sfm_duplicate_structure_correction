function [disconnected_inlier_point_indices, all_disconnected_inlier_point_indices] =...
    find_disconnected_inlier_point_indices(...
    disconnected_inliers, common_point_flags, group_assignments,...
    group_idx1, group_idx2)

    disconnected_inlier_point_indices = [];
    all_disconnected_inlier_point_indices = [];
    common_point_indices = find(common_point_flags);
    
    num_disconnected_inliers = length(disconnected_inliers);
    for idx = 1:num_disconnected_inliers
        cam_idx1 = disconnected_inliers{idx}.camera_indices(1);
        cam_idx2 = disconnected_inliers{idx}.camera_indices(2);
        
        assignment1 = group_assignments(cam_idx1);
        assignment2 = group_assignments(cam_idx2);
        
        if assignment1 == assignment2
            continue
        end
        
        if ~all([assignment1, assignment2] == [group_idx1, group_idx2]) &&...
           ~all([assignment1, assignment2] == [group_idx2, group_idx1])
            continue
        end
        
        inlier_point_indices1 = disconnected_inliers{idx}.inlier_point_indices1;
        inlier_point_indices2 = disconnected_inliers{idx}.inlier_point_indices2;
        
        if assignment1 == group_idx1
            all_disconnected_inlier_point_indices =...
                [all_disconnected_inlier_point_indices [inlier_point_indices1; inlier_point_indices2]];
        elseif assignment2 == group_idx1
            all_disconnected_inlier_point_indices =...
                [all_disconnected_inlier_point_indices [inlier_point_indices2; inlier_point_indices1]];
        else
            disp('ERROR')
        end
        
        flags1 = ismember(inlier_point_indices1, common_point_indices);
        flags2 = ismember(inlier_point_indices2, common_point_indices);
        
        valid_flags = (~flags1) & (~flags2);
        
        if ~any(valid_flags)
            continue
        end
        
        inlier_point_indices1 = inlier_point_indices1(valid_flags);
        inlier_point_indices2 = inlier_point_indices2(valid_flags);
        
        if assignment1 == group_idx1
            disconnected_inlier_point_indices =...
                [disconnected_inlier_point_indices [inlier_point_indices1; inlier_point_indices2]];
        elseif assignment2 == group_idx1
            disconnected_inlier_point_indices =...
                [disconnected_inlier_point_indices [inlier_point_indices2; inlier_point_indices1]];
        else
            disp('ERROR')
        end
    end
    
    disconnected_inlier_point_indices = unique(disconnected_inlier_point_indices', 'rows');
    disconnected_inlier_point_indices = disconnected_inlier_point_indices';
    
    all_disconnected_inlier_point_indices = unique(all_disconnected_inlier_point_indices', 'rows');
    all_disconnected_inlier_point_indices = all_disconnected_inlier_point_indices';

end % function
