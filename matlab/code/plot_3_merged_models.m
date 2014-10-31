function [] = plot_3_merged_models(camera_data, point_data, visibility_matrix,...
    group_assignments, group1_idx, group2_idx, group3_idx,...
    group1_transform, group2_transform)%,...
    %inlier_point_indices)

%inlier_point_indices = inlier_point_indices(:);
%inlier_point_flags = false(1, point_data.num_points);
%inlier_point_flags(inlier_point_indices) = true;

camera_flags1 = group_assignments == group1_idx;
camera_flags2 = group_assignments == group2_idx;
camera_flags3 = group_assignments == group3_idx;

point_flags1 = any(visibility_matrix(camera_flags1, :), 1);% & ~inlier_point_flags;
point_flags2 = any(visibility_matrix(camera_flags2, :), 1);% & ~inlier_point_flags;
point_flags3 = any(visibility_matrix(camera_flags3, :), 1);% & ~inlier_point_flags;

points1 = point_data.xyzs(:,point_flags1);
points2 = point_data.xyzs(:,point_flags2);
points3 = point_data.xyzs(:,point_flags3);
%inliers = point_data.xyzs(:,inlier_point_flags);

cameras1 = camera_data.centers(:,camera_flags1);
cameras2 = camera_data.centers(:,camera_flags2);
cameras3 = camera_data.centers(:,camera_flags3);

points1 = group1_transform * [points1; ones(1, size(points1, 2))];
points2 = group2_transform * [points2; ones(1, size(points2, 2))];

cameras1 = group1_transform * [cameras1; ones(1, size(cameras1, 2))];
cameras2 = group2_transform * [cameras2; ones(1, size(cameras2, 2))];

figure;
plot3(points1(1,:), points1(2,:), points1(3,:), '.r', 'MarkerSize', 1);
hold on
plot3(points2(1,:), points2(2,:), points2(3,:), '.b', 'MarkerSize', 1);
plot3(points3(1,:), points3(2,:), points3(3,:), '.g', 'MarkerSize', 1);
plot3(cameras1(1,:), cameras1(2,:), cameras1(3,:), 'vr', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
plot3(cameras2(1,:), cameras2(2,:), cameras2(3,:), 'vb', 'MarkerSize', 3, 'MarkerFaceColor', 'b');
plot3(cameras3(1,:), cameras3(2,:), cameras3(3,:), 'vg', 'MarkerSize', 3, 'MarkerFaceColor', 'g');
axis equal
axis vis3d
title('3 Merged Models');
hold off

end % function
