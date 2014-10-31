%% -----------------------------------------------------------------------------

addpath('code')
if ~exist('code/find_nearby_indices.mexw64', 'file')
    mex code/find_nearby_indices.cpp -outdir code
end

%% -----------------------------------------------------------------------------

clear
clc

main_settings

%% -----------------------------------------------------------------------------

disp(' ')
disp('Loading data...')
timer = tic;
main_load_data
toc(timer)
disp('Loading data done')

%% -----------------------------------------------------------------------------

if enable_images_in_spanning_tree
    disp(' ')
    disp('Creating thumbnails...')
    timer = tic;
    create_thumbnails(camera_data, image_folder, thumbnail_folder, 120);
    toc(timer)
    disp('Creating thumbnails done')
end

%% -----------------------------------------------------------------------------

disp(' ')
disp('Computing segmentations...')
timer = tic;
compute_image_segmentations(camera_data, image_folder,...
    segmentation_folder, segmentation_exe);
toc(timer)
disp('Computing segmentations done')

%% -----------------------------------------------------------------------------

main_run

%% -----------------------------------------------------------------------------
