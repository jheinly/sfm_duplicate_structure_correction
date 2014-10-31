function [M] = compute_RTS_3_points_3d_same_scale(left_points, right_points)

    % left_points  should be 3x3, where each column is a point
    % right_points should be 3x3, where each column is a point
    
    left_mean = mean(left_points, 2);
    right_mean = mean(right_points, 2);
    
    left_normed = left_points - repmat(left_mean, 1, 3);
    right_normed = right_points - repmat(right_mean, 1, 3);
    
    %S = sqrt(sum(sum(right_normed .^ 2, 1)) / sum(sum(left_normed .^ 2, 1)));
    
    %left_normed = S .* left_normed;
    %left_mean = S .* left_mean;
    
    left_plane_norm = cross(left_normed(:,2) - left_normed(:,1),...
                            left_normed(:,3) - left_normed(:,1));
    left_plane_norm = left_plane_norm ./ norm(left_plane_norm);
    
    right_plane_norm = cross(right_normed(:,2) - right_normed(:,1),...
                             right_normed(:,3) - right_normed(:,1));
    right_plane_norm = right_plane_norm ./ norm(right_plane_norm);
    
    plane_axis = cross(left_plane_norm, right_plane_norm);
    plane_axis = plane_axis ./ norm(plane_axis);
    
    plane_angle = acos(dot(left_plane_norm, right_plane_norm));
    
    if plane_angle < 0.00000001
        plane_axis = [0 0 1]';
    end
    
    plane_R = axis_angle_to_matrix(plane_axis, plane_angle);
    
    left_normed = plane_R * left_normed;
    
    cos_dots = dot(left_normed, right_normed, 1);
    cos_sum = sum(cos_dots);
    
    sin_crosses = cross(left_normed, right_normed, 1);
    sum_sin_crosses = sum(sin_crosses, 2);
    sin_sum = dot(sum_sin_crosses, right_plane_norm);
    
    theta = asin(sin_sum / sqrt(sin_sum ^ 2 + cos_sum ^ 2));
    
    inplane_R = axis_angle_to_matrix(right_plane_norm, theta);
    
    R = inplane_R * plane_R;
    
    left_mean = R * left_mean;
    
    T = right_mean - left_mean;
    
    %M = [R * S, T];
    M = [R, T];

end
