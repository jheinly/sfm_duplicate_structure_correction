function [angle] = compute_baseline_angle_between_cameras(...
    cam_idx1, cam_idx2, camera_data, point_data, visibility_matrix)

common_point_flags = visibility_matrix(cam_idx1,:) &...
    visibility_matrix(cam_idx2,:);

if ~any(common_point_flags)
    disp(['ERROR: compute_baseline_angle_between_cameras, cameras have no points in common: '...
        num2str(cam_idx1) ', ' num2str(cam_idx2)])
    angle = -1;
    return
end

common_points = point_data.xyzs(:,common_point_flags);
mean_point = mean(common_points, 2);

vector1 = camera_data.centers(:,cam_idx1) - mean_point;
vector2 = camera_data.centers(:,cam_idx2) - mean_point;

vector1 = vector1 ./ norm(vector1);
vector2 = vector2 ./ norm(vector2);

angle = rad2deg(acos(dot(vector1, vector2)));

end
