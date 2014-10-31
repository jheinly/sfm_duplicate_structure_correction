function [distance_threshold_3d] = compute_distance_threshold_3d(...
    camera_data, point_data, percentage)
    
    points = [camera_data.centers point_data.xyzs];
    mean_point = mean(points, 2);
    
    num_points = size(points, 2);
    
    diff = points - repmat(mean_point, 1, num_points);
    diff = diff .^ 2;
    diff = sum(diff, 1);
    diff = sqrt(diff);
    
    val = prctile(diff, 90);
    
    distance_threshold_3d = val * percentage;

end
