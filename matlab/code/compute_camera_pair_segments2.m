function [camera_pair_segments] = compute_camera_pair_segments2(...
    split_camera_tasks, camera_data, point_data, camera_observations,...
    segmentation_folder)

num_split_camera_tasks = length(split_camera_tasks);
split_camera_pairs = [];
for i = 1:num_split_camera_tasks
    split_camera_pairs = [split_camera_pairs; split_camera_tasks{i}.camera_pairs];
end
split_camera_pairs = unique(split_camera_pairs, 'rows');
num_split_camera_pairs = size(split_camera_pairs, 1);

disp(['Reduced # split camera pairs: ' num2str(num_split_camera_pairs)])

if num_split_camera_pairs == 0
    camera_pair_segments = struct(...
        'num_camera_pairs', 0,...
        'camera_pairs', [],...
        'pair_data', [],...
        'valid_flags1_to2', [],...
        'valid_flags2_to1', [],...
        'projected_points', []);
    return
end

init_matlabpool(12);

num_superpixels = 100;
num_segmentations = 8;

num_cameras = camera_data.num_cameras;
camera_pair_segments_storage = cell(1, num_cameras);

progress = ParforProgMon('Camera Segments: ', num_cameras, 1, 300, 80);

parfor cam_idx = 1:num_cameras
    % Find split camera pairs that use cam_idx
    
    cam_in_pair_flags1 = split_camera_pairs(:,1) == cam_idx;
    cam_in_pair_flags2 = split_camera_pairs(:,2) == cam_idx;
    
    split_pair_indices1 = find(cam_in_pair_flags1);
    split_pair_indices2 = find(cam_in_pair_flags2);
    
    split_camera_indices1 = split_camera_pairs(cam_in_pair_flags1, 2);
    split_camera_indices2 = split_camera_pairs(cam_in_pair_flags2, 1);
    
    num_cam_in_pair1 = length(split_camera_indices1);
    num_cam_in_pair2 = length(split_camera_indices2);
    
    camera_pair_segments_storage{cam_idx} = struct(...
        'first_pair_indices', split_pair_indices1,...
        'second_pair_indices', split_pair_indices2,...
        'first_data', {cell(1,num_cam_in_pair1)},...
        'second_data', {cell(1,num_cam_in_pair2)});
    
    if num_cam_in_pair1 + num_cam_in_pair2 == 0
        progress.increment();
        continue
    end
    
    % Load segmentations
    
    segmentations = cell(1, num_segmentations);
    max_segments = zeros(1, num_segmentations);
    for seg_idx = 1:num_segmentations
        segmentation_png_name = [segmentation_folder '/' camera_data.names{cam_idx}...
            '_seg_' num2str(num_superpixels) '_' num2str(seg_idx) '.png'];
        segmentations{seg_idx} = imread(segmentation_png_name);
        max_segments(seg_idx) = double(max(max(segmentations{seg_idx}))) + 1;
    end
    
    % Iterate over split camera pairs that use cam_idx
    
    center_current = camera_data.centers(:,cam_idx);
    R_current = camera_data.orientations{cam_idx};
    R_current = R_current';
    width_current = camera_data.dimensions(1,cam_idx);
    height_current = camera_data.dimensions(2,cam_idx);
    focal_current = camera_data.focals(cam_idx);
    K_current = [focal_current, 0,             width_current / 2;
                 0,             focal_current, height_current / 2;
                 0,             0,             1];
    
    % This loop is almost the same as the following one
    for idx = 1:num_cam_in_pair1
        cam_idx2 = split_camera_indices1(idx);
        
        point_indices = camera_observations{cam_idx2}.point_indices;
        points = point_data.xyzs(:,point_indices);
        
        points_projected = points;
        points_projected(1,:) = points_projected(1,:) - center_current(1);
        points_projected(2,:) = points_projected(2,:) - center_current(2);
        points_projected(3,:) = points_projected(3,:) - center_current(3);
        points_projected = R_current * points_projected;
        points_projected_in_front = points_projected(3,:) > 0;
        points_projected(1,:) = points_projected(1,:) ./ points_projected(3,:);
        points_projected(2,:) = points_projected(2,:) ./ points_projected(3,:);
        points_projected(3,:) = 1;
        points_projected = K_current * points_projected;
        
        points_projected = int32(round(points_projected(1:2,:) + 1));
        points_projected_in_bounds =...
            points_projected(1,:) >= 1 & points_projected(1,:) <= width_current &...
            points_projected(2,:) >= 1 & points_projected(2,:) <= height_current;
        
        valid_flags = points_projected_in_front & points_projected_in_bounds;
        num_points = size(points, 2);
        
        points_projected_valid = points_projected(:,valid_flags);
        indices = sub2ind([height_current, width_current],...
            points_projected_valid(2,:), points_projected_valid(1,:));
        
        camera_pair_segments_storage{cam_idx}.first_data{idx} = struct(...
            'valid_flags', valid_flags,...
            'projected_points', int16(points_projected),...
            'segment_indices', {cell(1,num_segmentations)},...
            'max_num_segments', max_segments);
        
        for seg_idx = 1:num_segmentations
            segments = segmentations{seg_idx}(indices);
            segments_final = -ones(1, num_points, 'int32');
            segments_final(valid_flags) = segments;
            segments_final = int8(segments_final);
            
            camera_pair_segments_storage{cam_idx}.first_data{idx}.segment_indices{seg_idx} = segments_final;
        end
    end
    
    % This loop is almost the same as the previous one
    for idx = 1:num_cam_in_pair2
        cam_idx1 = split_camera_indices2(idx);
        
        point_indices = camera_observations{cam_idx1}.point_indices;
        points = point_data.xyzs(:,point_indices);
        
        points_projected = points;
        points_projected(1,:) = points_projected(1,:) - center_current(1);
        points_projected(2,:) = points_projected(2,:) - center_current(2);
        points_projected(3,:) = points_projected(3,:) - center_current(3);
        points_projected = R_current * points_projected;
        points_projected_in_front = points_projected(3,:) > 0;
        points_projected(1,:) = points_projected(1,:) ./ points_projected(3,:);
        points_projected(2,:) = points_projected(2,:) ./ points_projected(3,:);
        points_projected(3,:) = 1;
        points_projected = K_current * points_projected;
        
        points_projected = int32(round(points_projected(1:2,:) + 1));
        points_projected_in_bounds =...
            points_projected(1,:) >= 1 & points_projected(1,:) <= width_current &...
            points_projected(2,:) >= 1 & points_projected(2,:) <= height_current;
        
        valid_flags = points_projected_in_front & points_projected_in_bounds;
        num_points = size(points, 2);
        
        points_projected_valid = points_projected(:,valid_flags);
        indices = sub2ind([height_current, width_current],...
            points_projected_valid(2,:), points_projected_valid(1,:));
        
        camera_pair_segments_storage{cam_idx}.second_data{idx} = struct(...
            'valid_flags', valid_flags,...
            'projected_points', int16(points_projected),...
            'segment_indices', {cell(1,num_segmentations)},...
            'max_num_segments', max_segments);
        
        for seg_idx = 1:num_segmentations
            segments = segmentations{seg_idx}(indices);
            segments_final = -ones(1, num_points, 'int32');
            segments_final(valid_flags) = segments;
            segments_final = int8(segments_final);
            
            camera_pair_segments_storage{cam_idx}.second_data{idx}.segment_indices{seg_idx} = segments_final;
        end
    end
    
    progress.increment();
end

progress.delete();

% Construct the camera_pair_segments object
disp('Constructing camera_pair_segments object...')
tic

camera_pair_segments = struct(...
    'num_camera_pairs', num_split_camera_pairs,...
    'camera_pairs', split_camera_pairs,...
    'pair_data', {cell(1,num_split_camera_pairs)},...
    'valid_flags1_to2', {cell(1,num_split_camera_pairs)},...
    'valid_flags2_to1', {cell(1,num_split_camera_pairs)},...
    'projected_points', {cell(1,num_split_camera_pairs)});

for pair_idx = 1:num_split_camera_pairs
    camera_pair_segments.pair_data{pair_idx} = cell(1, num_segmentations);
    
    for seg_idx = 1:num_segmentations
        camera_pair_segments.pair_data{pair_idx}{seg_idx} = struct(...
            'segment_indices1_to2', [],...
            'max_num_segments1_to2', 0,...
            'segment_indices2_to1', [],...
            'max_num_segments2_to1', 0);
    end
    
    camera_pair_segments.projected_points{pair_idx} = struct(...
        'points1_projected_to2', [],...
        'points2_projected_to1', []);
end

for cam_idx = 1:num_cameras
    first_pair_indices = camera_pair_segments_storage{cam_idx}.first_pair_indices;
    second_pair_indices = camera_pair_segments_storage{cam_idx}.second_pair_indices;
    
    num_first_pair_indices = length(first_pair_indices);
    num_second_pair_indices = length(second_pair_indices);
    
    for idx = 1:num_first_pair_indices
        pair_idx = first_pair_indices(idx);
        
        for seg_idx = 1:num_segmentations
            camera_pair_segments.pair_data{pair_idx}{seg_idx}.segment_indices2_to1 =...
                camera_pair_segments_storage{cam_idx}.first_data{idx}.segment_indices{seg_idx};
            camera_pair_segments.pair_data{pair_idx}{seg_idx}.max_num_segments2_to1 =...
                camera_pair_segments_storage{cam_idx}.first_data{idx}.max_num_segments(seg_idx);
        end
        
        camera_pair_segments.projected_points{pair_idx}.points2_projected_to1 =...
            camera_pair_segments_storage{cam_idx}.first_data{idx}.projected_points;
        
        camera_pair_segments.valid_flags2_to1{pair_idx} =...
            camera_pair_segments_storage{cam_idx}.first_data{idx}.valid_flags;
    end
    
    for idx = 1:num_second_pair_indices
        pair_idx = second_pair_indices(idx);
        
        for seg_idx = 1:num_segmentations
            camera_pair_segments.pair_data{pair_idx}{seg_idx}.segment_indices1_to2 =...
                camera_pair_segments_storage{cam_idx}.second_data{idx}.segment_indices{seg_idx};
            camera_pair_segments.pair_data{pair_idx}{seg_idx}.max_num_segments1_to2 =...
                camera_pair_segments_storage{cam_idx}.second_data{idx}.max_num_segments(seg_idx);
        end
        
        camera_pair_segments.projected_points{pair_idx}.points1_projected_to2 =...
            camera_pair_segments_storage{cam_idx}.second_data{idx}.projected_points;
        
        camera_pair_segments.valid_flags1_to2{pair_idx} =...
            camera_pair_segments_storage{cam_idx}.second_data{idx}.valid_flags;
    end
end

toc
disp('Constructing camera_pair_segments object done')

end % function
