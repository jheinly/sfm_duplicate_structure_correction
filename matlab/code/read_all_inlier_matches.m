function [all_inlier_matches, all_inlier_matches_camera_indices] = read_all_inlier_matches(filename, camera_data)

all_inlier_matches = {};
all_inlier_matches_camera_indices = [];

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
    locations_2d = locations_2d + 1;

    all_inlier_matches{end+1} = struct(...
        'camera_indices', [cam_idx1 cam_idx2],...
        'num_matches', num_inliers,...
        'feature_indices', feature_indices,...
        'locations_2d', locations_2d);
    all_inlier_matches_camera_indices =...
        [all_inlier_matches_camera_indices; [cam_idx1 cam_idx2]];
end
fclose(file);

end % function
