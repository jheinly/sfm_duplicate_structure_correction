function [conflicting_indices1, conflicting_indices2] = compute_conflicting_indices2(...
    camera_observations, camera_observation_segments,...
    camera_pair_segments, valid_flags1_to2, valid_flags2_to1, projected_points,...
    visibility_matrix, group_assignments, cam_idx1, cam_idx2, image_folder, camera_data)

group_idx1 = group_assignments(cam_idx1);
group_idx2 = group_assignments(cam_idx2);

group1_camera_flags = group_assignments == group_idx1;
group2_camera_flags = group_assignments == group_idx2;

group1_point_flags = any(visibility_matrix(group1_camera_flags,:), 1);
group2_point_flags = any(visibility_matrix(group2_camera_flags,:), 1);

group1_point_indices = find(group1_point_flags);
group2_point_indices = find(group2_point_flags);

camera1_point_indices = camera_observations{cam_idx1}.point_indices;
camera2_point_indices = camera_observations{cam_idx2}.point_indices;

% We assume that group1_point_indices and group2_point_indices are sorted
camera1_unique_point_flags = ~ismembc(double(camera1_point_indices), group2_point_indices);
camera2_unique_point_flags = ~ismembc(double(camera2_point_indices), group1_point_indices);
%camera1_unique_point_flags = ~ismember(camera1_point_indices, group2_point_indices);
%camera2_unique_point_flags = ~ismember(camera2_point_indices, group1_point_indices);

camera1_common_point_flags = ~camera1_unique_point_flags;
camera2_common_point_flags = ~camera2_unique_point_flags;

num_segmentations = length(camera_pair_segments);
num_segments1 = length(camera_observation_segments{cam_idx1}{1}.segment_indices);
num_segments2 = length(camera_observation_segments{cam_idx2}{1}.segment_indices);

segment_matches1_to2 = false(num_segments1, num_segments2);
segment_matches2_to1 = false(num_segments1, num_segments2);

segments_near_common1 = false(1, num_segments1);
segments_near_common2 = false(1, num_segments2);
segments_near_common1_to2 = false(1, num_segments1);
segments_near_common2_to1 = false(1, num_segments2);

for seg_idx = 1:num_segmentations
    segment_indices1 = camera_observation_segments{cam_idx1}{seg_idx}.segment_indices;
    segment_indices2 = camera_observation_segments{cam_idx2}{seg_idx}.segment_indices;
    segment_indices1_to2 = camera_pair_segments{seg_idx}.segment_indices1_to2;
    segment_indices2_to1 = camera_pair_segments{seg_idx}.segment_indices2_to1;
    
%     matches1_to2 = false(num_segments1, num_segments2);
%     matches2_to1 = false(num_segments1, num_segments2);
%     for i = 1:num_segments2
%         matches1_to2(:,i) = segment_indices1_to2 == segment_indices2(i);
%         matches2_to1(:,i) = segment_indices1 == segment_indices2_to1(i);
%     end
%     segment_matches1_to2 = segment_matches1_to2 | matches1_to2;
%     segment_matches2_to1 = segment_matches2_to1 | matches2_to1;

    common_segment_indices2 = segment_indices2(camera2_common_point_flags);
    common_segment_indices1 = segment_indices1(camera1_common_point_flags);
    
    [nearby_indices1_to2, near_common1_to2, near_common2] = find_nearby_indices(...
        segment_indices1_to2, segment_indices2,...
        camera_observation_segments{cam_idx2}{seg_idx}.max_num_segments,...
        num_segments1, common_segment_indices2);
    [nearby_indices2_to1, near_common1, near_common2_to1] = find_nearby_indices(...
        segment_indices1, segment_indices2_to1,...
        camera_observation_segments{cam_idx1}{seg_idx}.max_num_segments,...
        num_segments1, common_segment_indices1);
    
    %nearby_ind1_to2 = sub2ind(size(segment_matches1_to2),...
    %    nearby_indices1_to2(:,1), nearby_indices1_to2(:,2));
    %nearby_ind2_to1 = sub2ind(size(segment_matches2_to1),...
    %    nearby_indices2_to1(:,1), nearby_indices2_to1(:,2));
    
    segment_matches1_to2(nearby_indices1_to2) = true;
    segment_matches2_to1(nearby_indices2_to1) = true;
    
    %near_common1_to2 = ismember(segment_indices1_to2, common_segment_indices2);
    %near_common2 = ismember(segment_indices2, common_segment_indices2);
    %near_common1 = ismember(segment_indices1, common_segment_indices1);
    %near_common2_to1 = ismember(segment_indices2_to1, common_segment_indices1);
    
    segments_near_common1 = segments_near_common1 | near_common1;
    segments_near_common2 = segments_near_common2 | near_common2;
    segments_near_common1_to2 = segments_near_common1_to2 | near_common1_to2;
    segments_near_common2_to1 = segments_near_common2_to1 | near_common2_to1;
end

segment_matches1_to2(segments_near_common1_to2, :) = false;
segment_matches1_to2(:, segments_near_common2) = false;
segment_matches2_to1(segments_near_common1, :) = false;
segment_matches2_to1(:, segments_near_common2_to1) = false;

segment_matches1_to2(~camera1_unique_point_flags, :) = false;
segment_matches2_to1(~camera1_unique_point_flags, :) = false;
segment_matches1_to2(:, ~camera2_unique_point_flags) = false;
segment_matches2_to1(:, ~camera2_unique_point_flags) = false;

% The valid flags will be the same for all segmentations
segment_indices1_valid = camera_observation_segments{cam_idx1}{1}.valid_flags;
segment_indices2_valid = camera_observation_segments{cam_idx2}{1}.valid_flags;
segment_indices1_to2_valid = valid_flags1_to2;
segment_indices2_to1_valid = valid_flags2_to1;

segment_matches1_to2(~segment_indices1_to2_valid, :) = false;
segment_matches1_to2(:, ~segment_indices2_valid) = false;
segment_matches2_to1(~segment_indices1_valid, :) = false;
segment_matches1_to2(:, ~segment_indices2_to1_valid) = false;

camera1_point_indices1 = camera1_point_indices(any(segment_matches1_to2, 2));
camera1_point_indices2 = camera1_point_indices(any(segment_matches2_to1, 2));
camera2_point_indices1 = camera2_point_indices(any(segment_matches1_to2, 1));
camera2_point_indices2 = camera2_point_indices(any(segment_matches2_to1, 1));

% We can assume that camera1_point_indices2 and camera2_point_indices2 are sorted
conflicting_indices1 =...
    camera1_point_indices1(ismembc(camera1_point_indices1, camera1_point_indices2));
conflicting_indices2 =...
    camera2_point_indices1(ismembc(camera2_point_indices1, camera2_point_indices2));
%conflicting_indices1 = intersect(camera1_point_indices1, camera1_point_indices2);
%conflicting_indices2 = intersect(camera2_point_indices1, camera2_point_indices2);

if ~isempty(image_folder) && ~isempty(conflicting_indices1) && ~isempty(conflicting_indices2)
    img1 = rgb2gray(imread([image_folder '/' camera_data.names{cam_idx1} '.jpg']));
    img2 = rgb2gray(imread([image_folder '/' camera_data.names{cam_idx2} '.jpg']));
    
    [h1, w1] = size(img1);
    [h2, w2] = size(img2);
    
    new_h = min(h1, h2);
    
    scale1 = new_h / h1;
    scale2 = new_h / h2;
    
    new_w1 = round(scale1 * w1);
    new_w2 = round(scale2 * w2);
    
    if h1 ~= new_h
        img1 = imresize(img1, [new_h, new_w1]);
    end
    if h2 ~= new_h
        img2 = imresize(img2, [new_h, new_w2]);
    end
    
    new_img = [img1 img2];
    
    imshow(new_img);
    hold on
    
    title_text = sprintf('cams: %d - %d, num conflicting points: %d - %d',...
        cam_idx1, cam_idx2, length(conflicting_indices1), length(conflicting_indices2));
    title(title_text)
    
    % Plot common points
    common_flags1 = camera1_common_point_flags & segment_indices1_valid;
    common_flags2 = camera2_common_point_flags & segment_indices2_valid;
    common_locations1 = camera_observations{cam_idx1}.locations_2d(:,common_flags1);
    common_locations2 = camera_observations{cam_idx2}.locations_2d(:,common_flags2);
    plot(scale1 * common_locations1(1,:), scale1 * common_locations1(2,:), '.g');
    plot(new_w1 + scale2 * common_locations2(1,:), scale2 * common_locations2(2,:), '.g');
    
    % Plot camera 1's unique points
    unique_flags1 = camera1_unique_point_flags & ~segments_near_common1 & ~segments_near_common1_to2;
    unique_locations1 = camera_observations{cam_idx1}.locations_2d(:,unique_flags1);
    unique_locations1_2 = projected_points.points1_projected_to2(:,unique_flags1 & segment_indices1_to2_valid);
    plot(scale1 * unique_locations1(1,:), scale1 * unique_locations1(2,:), '.r');
    plot(new_w1 + scale2 * unique_locations1_2(1,:), scale2 * unique_locations1_2(2,:), '.r');
    val1 = sum(scale1 * unique_locations1(1,:) < -10);
    val2 = sum(scale2 * unique_locations1_2(1,:) < 10);
    if val1 > 0
        disp(['val1: ' num2str(val1)])
    end
    if val2 > 0
        disp(['val2: ' num2str(val2)])
    end
    
    % Plot camera 2's unique points
    unique_flags2 = camera2_unique_point_flags & ~segments_near_common2 & ~segments_near_common2_to1;
    unique_locations2 = camera_observations{cam_idx2}.locations_2d(:,unique_flags2);
    unique_locations2_1 = projected_points.points2_projected_to1(:,unique_flags2 & segment_indices2_to1_valid);
    plot(new_w1 + scale2 * unique_locations2(1,:), scale2 * unique_locations2(2,:), '.b');
    plot(scale1 * unique_locations2_1(1,:), scale1 * unique_locations2_1(2,:), '.b');
    val3 = sum(scale1 * unique_locations2(1,:) < -10);
    val4 = sum(scale2 * unique_locations2_1(1,:) < 10);
    if val3 > 0
        disp(['val3: ' num2str(val1)])
    end
    if val4 > 0
        disp(['val4: ' num2str(val2)])
    end
    
    hold off
    waitforbuttonpress
end

end % function
