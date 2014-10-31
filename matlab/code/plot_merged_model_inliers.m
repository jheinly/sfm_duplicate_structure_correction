function [] = plot_merged_model_inliers(camera_data, point_data, visibility_matrix,...
    group_assignments, group_idx1, group_idx2, inlier_point_indices)

inlier_point_indices = inlier_point_indices(:);
inlier_point_flags = false(1, point_data.num_points);
inlier_point_flags(inlier_point_indices) = true;

camera_flags1 = group_assignments == group_idx1;
camera_flags2 = group_assignments == group_idx2;

camera_indices1 = find(camera_flags1);
camera_indices2 = find(camera_flags2);

cameras1 = camera_data.centers(:,camera_flags1);
cameras2 = camera_data.centers(:,camera_flags2);

lookats1 = zeros(3, length(camera_indices1));
lookats2 = zeros(3, length(camera_indices2));

dist = compute_distance_threshold_3d(camera_data, point_data, 0.05);

for i = 1:length(camera_indices1)
    cam_idx = camera_indices1(i);
    lookat = camera_data.orientations{cam_idx} * [0 0 dist]';
    lookats1(:,i) = camera_data.centers(:,cam_idx) + lookat;
end

for i = 1:length(camera_indices2)
    cam_idx = camera_indices2(i);
    lookat = camera_data.orientations{cam_idx} * [0 0 dist]';
    lookats2(:,i) = camera_data.centers(:,cam_idx) + lookat;
end

point_flags1 = any(visibility_matrix(camera_flags1, :), 1) & ~inlier_point_flags;
point_flags2 = any(visibility_matrix(camera_flags2, :), 1) & ~inlier_point_flags;

points1 = point_data.xyzs(:,point_flags1);
points2 = point_data.xyzs(:,point_flags2);
inlier_points = point_data.xyzs(:,inlier_point_flags);

figure;
plot3(inlier_points(1,:), inlier_points(2,:), inlier_points(3,:), 'og', 'MarkerSize', 3, 'MarkerFaceColor', 'g')
hold on
plot3(points1(1,:), points1(2,:), points1(3,:), '.r', 'MarkerSize', 1)
plot3(points2(1,:), points2(2,:), points2(3,:), '.b', 'MarkerSize', 1)
plot3(cameras1(1,:), cameras1(2,:), cameras1(3,:), 'vr', 'MarkerSize', 3, 'MarkerFaceColor', 'r')
plot3(cameras2(1,:), cameras2(2,:), cameras2(3,:), 'vb', 'MarkerSize', 3, 'MarkerFaceColor', 'b')
plot3(...
    [cameras1(1,:); lookats1(1,:)],...
    [cameras1(2,:); lookats1(2,:)],...
    [cameras1(3,:); lookats1(3,:)],...
    '-r')
plot3(...
    [cameras2(1,:); lookats2(1,:)],...
    [cameras2(2,:); lookats2(2,:)],...
    [cameras2(3,:); lookats2(3,:)],...
    '-b')
axis equal
axis vis3d

% for i = 1:length(camera_indices1)
%     cam_idx = camera_indices1(i);
%     text(cameras1(1,i), cameras1(2,i), cameras1(3,i), [' ' num2str(cam_idx)], 'FontSize', 8)
% end
% for i = 1:length(camera_indices2)
%     cam_idx = camera_indices2(i);
%     text(cameras2(1,i), cameras2(2,i), cameras2(3,i), [' ' num2str(cam_idx)], 'FontSize', 8)
% end

hold off

end % function
