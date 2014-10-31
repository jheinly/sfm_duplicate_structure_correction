function [camera_observation_segments] = compute_camera_observation_segments2(...
    camera_observations, camera_data, segmentation_folder)

num_cameras = camera_data.num_cameras;
camera_observation_segments = cell(1, num_cameras);

num_superpixels = 100;
num_segmentations = 8;

init_matlabpool(12);

progress = ParforProgMon('Camera Segments: ', num_cameras, 1, 300, 80);

parfor cam_idx = 1:num_cameras
    %width = size(image_segmentations{cam_idx}{1}.segmentation, 2);
    %height = size(image_segmentations{cam_idx}{1}.segmentation, 1);
    width = camera_data.dimensions(1,cam_idx);
    height = camera_data.dimensions(2,cam_idx);

    locations_2d = round(camera_observations{cam_idx}.locations_2d + 1);
    valid_flags =...
        locations_2d(1,:) >= 1 & locations_2d(1,:) <= width &...
        locations_2d(2,:) >= 1 & locations_2d(2,:) <= height;
    num_points = length(valid_flags);
    locations_2d_valid = locations_2d(:,valid_flags);
    indices = sub2ind(...
        [height, width],...
        locations_2d_valid(2,:), locations_2d_valid(1,:));
    
    camera_observation_segments{cam_idx} = cell(1, num_segmentations);
    
    for seg_idx = 1:num_segmentations
        segment_indices = -ones(1, num_points);
        
        % Load segmentation
        segmentation_png_name = [segmentation_folder '/' camera_data.names{cam_idx}...
            '_seg_' num2str(num_superpixels) '_' num2str(seg_idx) '.png'];
        segmentation = imread(segmentation_png_name);
        
        %segments = image_segmentations{cam_idx}{seg_idx}.segmentation(indices);
        segments = segmentation(indices);
        
        segment_indices(valid_flags) = segments;
        
%         for i = 1:num_points
%             if valid_flags(i)
%                 x = locations_2d(1,i);
%                 y = locations_2d(2,i);
%                 segment_indices(i) =...
%                     image_segmentations{cam_idx}{seg_idx}.segmentation(y, x);
%             end
%         end
        
        camera_observation_segments{cam_idx}{seg_idx} = struct(...
            'segment_indices', int8(segment_indices),...
            'valid_flags', valid_flags,...
            'max_num_segments', double(max(max(segmentation))) + 1);
    end
    
    progress.increment();
end

progress.delete();

end % function
