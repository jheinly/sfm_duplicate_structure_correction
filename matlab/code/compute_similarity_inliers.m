function [inliers, similarity] = compute_similarity_inliers(similarity, data, threshold)

    if isempty(similarity)
        inliers = false(1, size(data, 2));
        return
    end
    
    left_points = data(1:3, :);
    right_points = data(4:6, :);
    
    N = size(left_points, 2);
    
    new_left_points = similarity * [left_points; ones(1, N)];
    
    diff = right_points - new_left_points;
    diff = diff .^ 2;
    diff = sum(diff, 1);
    diff = sqrt(diff);
    
    inliers = find(diff <= threshold);

end
