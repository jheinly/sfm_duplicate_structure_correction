function [camera_data, point_data, point_observations] =...
    read_nvm_and_image_dimensions(nvm_name, image_folder)

    file = fopen(nvm_name, 'r');
    line = strtrim(fgets(file));
    if ~strcmp(line, 'NVM_V3')
        disp('ERROR: expected NVM_V3 as first line of file')
        fclose(file);
        return
    end
    
    num_cameras = fscanf(file, '%d', 1);
    raw_camera_data = textscan(file, '%s %f %f %f %f %f %f %f %f %f %f', num_cameras);
    
    camera_names    = raw_camera_data{1}';
    camera_focals   = raw_camera_data{2}';
    camera_quats    = [raw_camera_data{3}'; raw_camera_data{4}'; raw_camera_data{5}'; raw_camera_data{6}'];
    camera_centers  = [raw_camera_data{7}'; raw_camera_data{8}'; raw_camera_data{9}'];
    camera_distorts = [raw_camera_data{10}'; raw_camera_data{11}'];
    
    image_dimensions = zeros(2, num_cameras);
    
    camera_orientations = cell(1, num_cameras);
    
    for i = 1:num_cameras
        camera_names{i} = trim_filename(camera_names{i});
        
        camera_orientations{i} = quaternion_to_matrix(camera_quats(:,i));
        camera_orientations{i} = camera_orientations{i}';
        
        filename = [image_folder '/' camera_names{i} '.jpg'];
        info = imfinfo(filename);
        width = info.Width;
        height = info.Height;
        image_dimensions(:,i) = [width; height];
    end
    
    camera_data = struct(...
        'num_cameras', num_cameras,...
        'names', {camera_names},...
        'focals', camera_focals,...
        'centers', camera_centers,...
        'orientations', {camera_orientations},...
        'dimensions', image_dimensions);
    
    num_points = fscanf(file, '%d', 1);
    
    point_xyzs = zeros(3, num_points);
    point_rgbs = zeros(3, num_points);
    point_observations = cell(1, num_points);
    
    for point_idx = 1:num_points
        file_data = fscanf(file, '%f %f %f %d %d %d %d', 7);
        xyz = file_data(1:3);
        rgb = file_data(4:6);
        num_observations = int32(file_data(7));
        
        file_data = fscanf(file, '%d %d %f %f', [4, num_observations]);
        
        camera_indices = int32(file_data(1,:) + 1);
        feature_indices = int32(file_data(2,:) + 1);
        locations_2d = single(...
            file_data(3:4,:) + (image_dimensions(:,camera_indices) ./ 2) + 1);
        
        point_xyzs(:,point_idx) = xyz;
        point_rgbs(:,point_idx) = rgb ./ 255;
        
        point_observations{point_idx} = struct(...
            'num_observations', num_observations,...
            'camera_indices', camera_indices,...
            'feature_indices', feature_indices,...
            'locations_2d', locations_2d);
    end
    
    point_data = struct(...
        'num_points', num_points,...
        'xyzs', point_xyzs,...
        'rgbs', point_rgbs);
    
    fclose(file);
end % function
