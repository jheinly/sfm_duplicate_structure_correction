%model_name = 'street';
%model_name = 'cereal';
%model_name = 'indoor';
%model_name = 'brandenburg_gate';
%model_name = 'church_on_spilled_blood';
%model_name = 'radcliffe_camera';
%model_name = 'arc_de_triomphe';
%model_name = 'alexander_nevsky_cathedral';
%model_name = 'berliner_dom';
model_name = 'big_ben';

conflict_threshold = 7.0;
min_common_points_for_connection = 8;
max_baseline_angle = 20; % degrees
max_split_cameras_per_edge = 100;
ransac_distance_percentage = 0.015;
max_num_merge_tries = 100;
min_views_per_point = 3;

enable_spanning_tree_visualization = true;
enable_images_in_spanning_tree = true;

dataset_folder = './sfm_duplicate_structure_correction_datasets';
segmentation_exe = './sfm_duplicate_structure_correction/SLICO-Superpixels/precompiled_bin/SLICO.exe';
graphviz_sfdp_exe = './graphviz-2.34/release/bin/sfdp.exe';
