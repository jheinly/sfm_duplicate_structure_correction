function [inlier_matches] = read_inlier_matches(filename, camera_data, camera_observations)

inlier_matches = {};

file = fopen(filename, 'r');
while ~feof(file)
    line = strtrim(fgets(file));
    if isempty(line)
        continue
    end
    if line(1) == '#'
        continue
    end

    space = strfind(line, ' ');
    camera_name1 = trim_filename(line(space+1 : end));
    cam_idx1 = find(strcmp(camera_name1, camera_data.names));
    
    % If the cameras for the inlier images didn't end up in the final NVM
    % model then their indices will be empty matrices.
    if isempty(cam_idx1)
        continue
    end

    line = strtrim(fgets(file));
    space = strfind(line, ' ');
    camera_name2 = trim_filename(line(space+1 : end));
    cam_idx2 = find(strcmp(camera_name2, camera_data.names));
    
    if isempty(cam_idx2)
        continue
    end

    line = strtrim(fgets(file));
    num_inliers = str2double(line);

    data = fscanf(file, '%d %f %f %d %f %f', [6, num_inliers]);
    data = data';
    feature_indices = int32(data(:, logical([1 0 0 1 0 0])));
    feature_indices = feature_indices + 1;
    feature_indices = feature_indices';
    locations_2d = single(data(:, logical([0 1 1 0 1 1])));
    locations_2d = locations_2d';
    
    % Determine which features turned into 3D points
    [flags1, indices1] = ismember(...
        feature_indices(1,:), camera_observations{cam_idx1}.feature_indices);
    [flags2, indices2] = ismember(...
        feature_indices(2,:), camera_observations{cam_idx2}.feature_indices);
    
    valid_flags = flags1 & flags2;
    
    if ~any(valid_flags)
        continue
    end
    
    indices1 = indices1(valid_flags);
    indices2 = indices2(valid_flags);
    
    point_indices1 = camera_observations{cam_idx1}.point_indices(indices1);
    point_indices2 = camera_observations{cam_idx2}.point_indices(indices2);
    
    % Later on we will only care about inliers that turned into different
    % points, so discard extra data now.
    different_points_flags = point_indices1 ~= point_indices2;
    
    if ~any(different_points_flags)
        continue
    end
    
    feature_indices = feature_indices(:, valid_flags);
    locations_2d = locations_2d(:, valid_flags);
    
    point_indices1 = point_indices1(different_points_flags);
    point_indices2 = point_indices2(different_points_flags);
    feature_indices = feature_indices(:, different_points_flags);
    locations_2d = locations_2d(:, different_points_flags);

    inlier_matches{end+1} = struct(...
        'camera_indices', [cam_idx1 cam_idx2],...
        'num_matches', sum(different_points_flags),...
        'feature_indices', feature_indices,...
        'point_indices', [point_indices1; point_indices2],...
        'locations_2d', locations_2d);
end
fclose(file);

end % function
