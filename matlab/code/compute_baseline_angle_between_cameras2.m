function [angle] = compute_baseline_angle_between_cameras2(...
    cam_idx1, cam_idx2, camera_data, point_data, camera_observations)

points1 = camera_observations{cam_idx1}.point_indices;
points2 = camera_observations{cam_idx2}.point_indices;

% We assume that camera_observations.point_indices is sorted so we can use ismembc
common_point_indices = points1(ismembc(points1, points2));
%common_point_indices = intersect(points1, points2);

if isempty(common_point_indices)
    disp(['ERROR: compute_baseline_angle_between_cameras2, cameras have no points in common: '...
        num2str(cam_idx1) ', ' num2str(cam_idx2)])
    angle = -1;
    return
end

common_points = point_data.xyzs(:,common_point_indices);
mean_point = mean(common_points, 2);

vector1 = camera_data.centers(:,cam_idx1) - mean_point;
vector2 = camera_data.centers(:,cam_idx2) - mean_point;

vector1 = vector1 ./ norm(vector1);
vector2 = vector2 ./ norm(vector2);

angle = rad2deg(acos(dot(vector1, vector2)));

end
