function [] = write_merged_nvm(output_path,...
    camera_data, point_data, point_observations)

file = fopen(output_path, 'w');
fprintf(file, 'NVM_V3\n');
fprintf(file, '\n');
fprintf(file, '%d\n', camera_data.num_cameras);

for i = 1:camera_data.num_cameras
    fprintf(file, 'iconic_images\\%s.jpg ', camera_data.names{i});
    fprintf(file, '%f ', camera_data.focals(i));
    quat = matrix_to_quaternion(camera_data.orientations{i}');
    fprintf(file, '%f %f %f %f ', quat(1), quat(2), quat(3), quat(4));
    center = camera_data.centers(:,i);
    fprintf(file, '%f %f %f ', center(1), center(2), center(3));
    fprintf(file, '0 0\n');
end

fprintf(file, '\n');
fprintf(file, '%d\n', length(point_observations));

for i = 1:length(point_observations)
    xyz = point_data.xyzs(:,i);
    fprintf(file, '%f %f %f ', xyz(1), xyz(2), xyz(3));
    fprintf(file, '0 0 0 ');
    num_obs = point_observations{i}.num_observations;
    fprintf(file, '%d ', num_obs);
    for j = 1:num_obs
        cam_idx = point_observations{i}.camera_indices(j);
        fprintf(file, '%d ', cam_idx - 1);
        fprintf(file, '%d ', point_observations{i}.feature_indices(j) - 1);
        loc = point_observations{i}.locations_2d(:,j);
        loc = loc - (camera_data.dimensions(:,cam_idx) ./ 2) - 1;
        fprintf(file, '%f %f ', loc(1), loc(2));
    end
    fprintf(file, '\n');
end

fclose(file);

end % function
