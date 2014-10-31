function [M, inliers] = ransac_3d_similarity(matching_points, threshold)

    [M, inliers] = ransac(matching_points, @compute_M, @compute_similarity_inliers, @is_valid_data, 3, threshold, 0, 1000, 30000);
    
    if length(inliers) > 3
        M = refine_M(matching_points(:,inliers));
        [inliers, M] = compute_similarity_inliers(M, matching_points, threshold);
        M = refine_M(matching_points(:,inliers));
        [inliers, M] = compute_similarity_inliers(M, matching_points, threshold);
    end
    
    num_inliers = length(inliers);
    
    display(['Inliers = ' num2str(num_inliers) ' / ' num2str(size(matching_points, 2))])

end

function [M] = compute_M(data)

    if size(data, 2) ~= 3
        disp('compute_M expected 3 points')
    end
    
    left_points = data(1:3, :);
    right_points = data(4:6, :);
    
    M = compute_RTS_3_points_3d_same_scale(left_points, right_points);

end

function [M] = refine_M(data)

    left_points = data(1:3, :);
    right_points = data(4:6, :);
    
    M = compute_RTS_N_points_3d_same_scale(left_points, right_points);

end

% function [inliers, M] = compute_inliers(M, data, threshold)
% 
%     if isempty(M)
%         inliers = false(1, size(data, 2));
%         return
%     end
%     
%     left_points = data(1:3, :);
%     right_points = data(4:6, :);
%     
%     N = size(left_points, 2);
%     
%     new_left_points = M * [left_points; ones(1, N)];
%     
%     diff = right_points - new_left_points;
%     diff = diff .^ 2;
%     diff = sum(diff, 1);
%     diff = sqrt(diff);
%     
%     inliers = find(diff <= threshold);
% 
% end

function [r] = is_valid_data(data)

    % Return 1 if the data is degenerate
    % Return 0 if the data is not degenerate
    
    if size(data, 2) ~= 3
        disp('is_valid_data expected 3 points')
    end
    
    left_points = data(1:3, :);
    right_points = data(4:6, :);
    
    l1 = left_points(:,1);
    l2 = left_points(:,2);
    l3 = left_points(:,3);
    
    r1 = right_points(:,1);
    r2 = right_points(:,2);
    r3 = right_points(:,3);
    
    % Check if 2 of the points are close to each other
    if norm(l2 - l1) < 0.0001 ||...
       norm(l3 - l1) < 0.0001 ||...
       norm(l3 - l2) < 0.0001
       
        r = 1;
        return
    end
    if norm(r2 - r1) < 0.0001 ||...
       norm(r3 - r1) < 0.0001 ||...
       norm(r3 - r2) < 0.0001
       
        r = 1;
        return
    end
    
    l_diff1 = l2 - l1;
    l_diff2 = l3 - l1;
    l_diff1 = l_diff1 ./ norm(l_diff1);
    l_diff2 = l_diff2 ./ norm(l_diff2);
    if acos(dot(l_diff1, l_diff2)) < 0.01
        r = 1;
        return
    end
    
    r_diff1 = r2 - r1;
    r_diff2 = r3 - r1;
    r_diff1 = r_diff1 ./ norm(r_diff1);
    r_diff2 = r_diff2 ./ norm(r_diff2);
    if acos(dot(r_diff1, r_diff2)) < 0.01
        r = 1;
        return
    end
    
    r = 0;

end
