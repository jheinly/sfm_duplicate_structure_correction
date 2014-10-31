function [disconnected_inliers] = find_disconnected_inliers(...
    inlier_matches, camera_observations, camera_data, image_folder)

if ~exist('image_folder', 'var')
    image_folder = '';
end

num_inlier_matches = length(inlier_matches);
num_cameras = length(camera_observations);

disconnected_inliers = {};

for inlier_match_idx = 1:num_inlier_matches
    cam_idx1 = inlier_matches{inlier_match_idx}.camera_indices(1);
    cam_idx2 = inlier_matches{inlier_match_idx}.camera_indices(2);

    if cam_idx1 > num_cameras || cam_idx2 > num_cameras
        continue
    end
    
    % Get the indices of the features that were inlier matches
    inlier_feature_indices1 = inlier_matches{inlier_match_idx}.feature_indices(1,:);
    inlier_feature_indices2 = inlier_matches{inlier_match_idx}.feature_indices(2,:);
    
    % Get the feature indices of the 3d points observed in each camera
    point_feature_indices1 = camera_observations{cam_idx1}.feature_indices;
    point_feature_indices2 = camera_observations{cam_idx2}.feature_indices;
    
    % Get the indices of the 3d points observed in each camera
    point_indices1 = camera_observations{cam_idx1}.point_indices;
    point_indices2 = camera_observations{cam_idx2}.point_indices;
    
    % Determine which inlier features turned into 3d points
    [inlier_flags1, inlier_indices1] = ismember(inlier_feature_indices1, point_feature_indices1);
    [inlier_flags2, inlier_indices2] = ismember(inlier_feature_indices2, point_feature_indices2);
    
    % Determine which inliers had both observations turn into 3d points
    inlier_flags = inlier_flags1 & inlier_flags2;
    
    if ~any(inlier_flags)
        continue
    end
    
    % Get the observation indices (index into the point_observation lists for a camera)
    % that were part of an inlier that had both observations turn into 3d points
    inlier_indices1 = inlier_indices1(inlier_flags);
    inlier_indices2 = inlier_indices2(inlier_flags);
    
    % Get the 3d point indices that belong to the inlier matches
    inlier_point_indices1 = point_indices1(inlier_indices1);
    inlier_point_indices2 = point_indices2(inlier_indices2);
    
    % Find inlier matches where the observations turned into separate 3d points
    not_equal_flags = inlier_point_indices1 ~= inlier_point_indices2;
    
    if ~any(not_equal_flags)
        continue
    end
    
    inlier_point_indices1 = inlier_point_indices1(not_equal_flags);
    inlier_point_indices2 = inlier_point_indices2(not_equal_flags);
    
    disconnected_inliers{end+1} = struct(...
        'camera_indices', [cam_idx1 cam_idx2],...
        'inlier_point_indices1', inlier_point_indices1,...
        'inlier_point_indices2', inlier_point_indices2);
    
    if ~isempty(image_folder)
        img1 = rgb2gray(imread([image_folder '/' camera_data.names{cam_idx1} '.jpg']));
        img2 = rgb2gray(imread([image_folder '/' camera_data.names{cam_idx2} '.jpg']));
        
        locations1 = camera_observations{cam_idx1}.locations_2d;
        locations2 = camera_observations{cam_idx2}.locations_2d;
        
        flags1 = ismember(point_indices1, inlier_point_indices1);
        flags2 = ismember(point_indices2, inlier_point_indices2);
        
        locations1 = locations1(:,flags1);
        locations2 = locations2(:,flags2);
        
        subplot(2,1,1)
        imshow(img1)
        hold on
        plot(locations1(1,:), locations1(2,:), 'or', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
        hold off
        
        subplot(2,1,2)
        imshow(img2)
        hold on
        plot(locations2(1,:), locations2(2,:), 'or', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
        hold off
        
        waitforbuttonpress
    end
end

end % function
