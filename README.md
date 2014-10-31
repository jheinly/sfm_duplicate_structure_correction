sfm_duplicate_structure_correction
==================================

This is the code that corresponds to the paper:
  J. Heinly, E. Dunn, and J.M. Frahm, "Correcting for Duplicate Scene Structure in Sparse 3D Reconstruction", ECCV 2014.

Website:
  http://jheinly.web.unc.edu/research/sfm-duplicate-structure-correction/

Setup
-----
Before using this code, several things will need to be done:

1. Compile the SLICO Superpixels executable. In order to do this, run CMake 3.0 (http://www.cmake.org/download/) on the included SLICO-Superpixels/ folder. Then, run the resulting build scripts to generate an executable. For ease of use, a precompiled version of the Windows executable is available in SLICO-Superpixels/precompiled_bin/.

2. Make sure that your MATLAB instance is properly set up to generate MEX files. If you are unsure, execute the "mex -setup" command within MATLAB, and follow the instructions to choose your default C/C++ compiler. The main MATLAB script (main.m) will automatically attempt to compile the necessary MEX file, but if this fails for some reason, a precompiled version of the file is available in matlab/precompiled_mex/.

3. If you want to visualize the camera spanning tree, download the Graphviz package (http://www.graphviz.org/Download..php).

Datasets
--------
Links to datasets available for download are provided at:
http://jheinly.web.unc.edu/research/sfm-duplicate-structure-correction/datasets/

Execution
---------
In order to execute the code, point MATLAB to the included matlab/ folder, and follow the steps below:

1. Open main_settings.m and modify its values.
   - Change the paths of the SLICO executable, Graphviz executable, and dataset folder to reflect the paths on your system.
   - Change the name of the dataset you want to execute by modifying the model_name variable. Valid options for dataset names can be found in main_load_data.m.
   - Enable/disable spanning tree visualization by setting the spanning tree flags to true/false.
   - This file also contains method parameters which can be tuned, but these can be left at their default values as they have proved to be robust.

2. Execute main.m.

3. If spanning tree visualization was enabled, the images will be saved in the matlab/figures/ folder.

4. Near the end of the method, as it starts attempting to merge sub-models, a new MATLAB figure will be opened for each merge attempt. This allows the user to view both successful and failed merge operations.

Execution on New Dataset
------------------------
Currently, this code only supports VisualSFM file formats (http://ccwu.me/vsfm/). When you have finished executing VisualSFM on your images, save the following files:

1. SfM -> Save NView Match, this will save a *.nvm file which contains the camera poses, 3D point locations, and 2D point observations.

2. SfM -> Pairwise Matching -> Export F-Matrix Matches, this will save a *.txt file which contains the inlier match data for each pair of images that was matched.

After saving these files, modify the main_settings.m file to reflect the location of these files and your data.

Troubleshooting
---------------
If your MATLAB instance does not support 12 matlabpool threads, find all calls to init_matlabpool(12) and replace the argument with a smaller number.

On the largest datasets (e.g. Berliner Dom) your machine may run out of memory when executing parfor loops. If this is the case, modify the init_matlabpool(12) call directly before the offending parfor loop and change it to a smaller value.

SLICO Superpixels
-----------------
Code obtained from:
  http://ivrg.epfl.ch/research/superpixels#SLICO

ParforProgMon
-------------
Code obtained from:
  http://www.mathworks.com/matlabcentral/fileexchange/31673-parfor-progress-monitor-v2
