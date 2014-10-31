if dataset_folder(end) ~= '/' && dataset_folder(end) ~= '\'
    dataset_folder = [dataset_folder '/'];
end

switch model_name
    case 'street'
        nvm_path =            [dataset_folder 'street/model.nvm'];
        image_folder =        [dataset_folder 'street/images'];
        segmentation_folder = [dataset_folder 'street/segmentations'];
        thumbnail_folder =    [dataset_folder 'street/thumbnails'];
        inlier_matches_path = [dataset_folder 'street/inlier_matches.txt'];
    case 'cereal'
        nvm_path =            [dataset_folder 'cereal/model.nvm'];
        image_folder =        [dataset_folder 'cereal/images'];
        segmentation_folder = [dataset_folder 'cereal/segmentations'];
        thumbnail_folder =    [dataset_folder 'cereal/thumbnails'];
        inlier_matches_path = [dataset_folder 'cereal/inlier_matches.txt'];
    case 'indoor'
        nvm_path =            [dataset_folder 'indoor/model.nvm'];
        image_folder =        [dataset_folder 'indoor/images'];
        segmentation_folder = [dataset_folder 'indoor/segmentations'];
        thumbnail_folder =    [dataset_folder 'indoor/thumbnails'];
        inlier_matches_path = [dataset_folder 'indoor/inlier_matches.txt'];
    case 'brandenburg_gate'
        nvm_path =            [dataset_folder 'brandenburg_gate/model.nvm'];
        image_folder =        [dataset_folder 'brandenburg_gate/images'];
        segmentation_folder = [dataset_folder 'brandenburg_gate/segmentations'];
        thumbnail_folder =    [dataset_folder 'brandenburg_gate/thumbnails'];
        inlier_matches_path = [dataset_folder 'brandenburg_gate/inlier_matches.txt'];
    case 'church_on_spilled_blood'
        nvm_path =            [dataset_folder 'church_on_spilled_blood/model.nvm'];
        image_folder =        [dataset_folder 'church_on_spilled_blood/images'];
        segmentation_folder = [dataset_folder 'church_on_spilled_blood/segmentations'];
        thumbnail_folder =    [dataset_folder 'church_on_spilled_blood/thumbnails'];
        inlier_matches_path = [dataset_folder 'church_on_spilled_blood/inlier_matches.txt'];
    case 'radcliffe_camera'
        nvm_path =            [dataset_folder 'radcliffe_camera/model.nvm'];
        image_folder =        [dataset_folder 'radcliffe_camera/images'];
        segmentation_folder = [dataset_folder 'radcliffe_camera/segmentations'];
        thumbnail_folder =    [dataset_folder 'radcliffe_camera/thumbnails'];
        inlier_matches_path = [dataset_folder 'radcliffe_camera/inlier_matches.txt'];
    case 'arc_de_triomphe'
        nvm_path =            [dataset_folder 'arc_de_triomphe/model.nvm'];
        image_folder =        [dataset_folder 'arc_de_triomphe/images'];
        segmentation_folder = [dataset_folder 'arc_de_triomphe/segmentations'];
        thumbnail_folder =    [dataset_folder 'arc_de_triomphe/thumbnails'];
        inlier_matches_path = [dataset_folder 'arc_de_triomphe/inlier_matches.txt'];
    case 'alexander_nevsky_cathedral'
        nvm_path =            [dataset_folder 'alexander_nevsky_cathedral/model.nvm'];
        image_folder =        [dataset_folder 'alexander_nevsky_cathedral/images'];
        segmentation_folder = [dataset_folder 'alexander_nevsky_cathedral/segmentations'];
        thumbnail_folder =    [dataset_folder 'alexander_nevsky_cathedral/thumbnails'];
        inlier_matches_path = [dataset_folder 'alexander_nevsky_cathedral/inlier_matches.txt'];
    case 'berliner_dom'
        nvm_path =            [dataset_folder 'berliner_dom/model.nvm'];
        image_folder =        [dataset_folder 'berliner_dom/images'];
        segmentation_folder = [dataset_folder 'berliner_dom/segmentations'];
        thumbnail_folder =    [dataset_folder 'berliner_dom/thumbnails'];
        inlier_matches_path = [dataset_folder 'berliner_dom/inlier_matches.txt'];
    case 'big_ben'
        nvm_path =            [dataset_folder 'big_ben/model_iconics.nvm'];
        image_folder =        [dataset_folder 'big_ben/images'];
        segmentation_folder = [dataset_folder 'big_ben/segmentations'];
        thumbnail_folder =    [dataset_folder 'big_ben/thumbnails'];
        inlier_matches_path = [dataset_folder 'big_ben/inlier_matches_iconics.txt'];
    otherwise
        disp('ERROR: model_name not found in main_init.m')
end

disp(['Model: ' model_name])

figures_folder = ['figures/' model_name];
if ~exist(figures_folder, 'dir')
    mkdir(figures_folder)
end

[camera_data, point_data, point_observations] =...
    read_nvm_and_image_dimensions(nvm_path, image_folder);
visibility_matrix = create_visibility_matrix(...
    point_observations, camera_data, point_data);
camera_observations = create_camera_observations(...
    point_observations, visibility_matrix);
inlier_matches = read_inlier_matches(...
    inlier_matches_path, camera_data, camera_observations);
[all_inlier_matches, all_inlier_matches_camera_indices] = read_all_inlier_matches(...
    inlier_matches_path, camera_data);

disp(['# Cameras: ' num2str(camera_data.num_cameras)])
disp(['# Points:  ' num2str(point_data.num_points)])
