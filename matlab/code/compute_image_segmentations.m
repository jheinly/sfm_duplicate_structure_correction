function [] = compute_image_segmentations(...
    camera_data, image_folder, segmentation_folder, segmentation_exe)

if ~exist(segmentation_folder, 'dir')
    mkdir(segmentation_folder)
end

init_matlabpool(12);

progress = ParforProgMon('Segmentation: ', camera_data.num_cameras, 1, 300, 80);

num_superpixels = 100;
num_transforms = 8;

parfor cam_idx = 1:camera_data.num_cameras
    width = camera_data.dimensions(1, cam_idx);
    height = camera_data.dimensions(2, cam_idx);
    img = imread([image_folder '/' camera_data.names{cam_idx} '.jpg']);
    if size(img, 3) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end
    
    for trans_idx = 1:num_transforms
        
        segmentation_png_name = [segmentation_folder '/' camera_data.names{cam_idx}...
            '_seg_' num2str(num_superpixels) '_' num2str(trans_idx) '.png'];
        
        if ~exist(segmentation_png_name, 'file')
            transformed_img = transform_image(img, trans_idx);
            image_path = [segmentation_folder '/' camera_data.names{cam_idx} '_trans.jpg'];
            imwrite(transformed_img, image_path);
            
            system([segmentation_exe ' ' image_path ' ' num2str(num_superpixels)]);

            trans_width = size(transformed_img, 2);
            trans_height = size(transformed_img, 1);
            
            dat_path = [segmentation_folder '/' camera_data.names{cam_idx} '_trans.dat'];
            file = fopen(dat_path, 'r');
            segmentation = fread(file, trans_width * trans_height, 'int');
            fclose(file);
            delete(dat_path);
            delete(image_path);

            segmentation = reshape(segmentation, trans_width, trans_height)';
            segmentation = undo_transform_image(segmentation, trans_idx);
            segmentation = uint8(segmentation);
            
            imwrite(segmentation, segmentation_png_name);
            
            subset = segmentation(2:height-1, 2:width-1);
            boundary = false(height, width);
            boundary(2:height-1, 2:width-1) = boundary(2:height-1, 2:width-1) |...
                subset ~= segmentation(1:height-2, 2:width-1);
            boundary(2:height-1, 2:width-1) = boundary(2:height-1, 2:width-1) |...
                subset ~= segmentation(3:height, 2:width-1);
            boundary(2:height-1, 2:width-1) = boundary(2:height-1, 2:width-1) |...
                subset ~= segmentation(2:height-1, 1:width-2);
            boundary(2:height-1, 2:width-1) = boundary(2:height-1, 2:width-1) |...
                subset ~= segmentation(2:height-1, 3:width);

            img_copy = gray;
            img_copy(boundary) = 255;
            imwrite(img_copy, [segmentation_folder '/' camera_data.names{cam_idx}...
                '_seg_' num2str(num_superpixels) '_' num2str(trans_idx) '.jpg']);
        end
    end
    
    progress.increment();
end
progress.delete();

end % function

function [img] = transform_image(img, transform_num)
    if size(img,3) == 3
        img1 = transform_image(img(:,:,1), transform_num);
        img2 = transform_image(img(:,:,2), transform_num);
        img3 = transform_image(img(:,:,3), transform_num);
        img = cat(3, img1, img2, img3);
        return
    end
    
    switch transform_num
        case 1
            return
        case 2
            img = rot90(img);
        case 3
            img = rot90(img, 2);
        case 4
            img = rot90(img, 3);
        case 5
            img = fliplr(img);
        case 6
            img = rot90(img);
            img = fliplr(img);
        case 7
            img = rot90(img, 2);
            img = fliplr(img);
        case 8
            img = rot90(img, 3);
            img = fliplr(img);
        otherwise
            disp('ERROR: invalid transform num')
    end
end % function

function [img] = undo_transform_image(img, transform_num)
    switch transform_num
        case 1
            return
        case 2
            img = rot90(img, 3);
        case 3
            img = rot90(img, 2);
        case 4
            img = rot90(img);
        case 5
            img = fliplr(img);
        case 6
            img = fliplr(img);
            img = rot90(img, 3);
        case 7
            img = fliplr(img);
            img = rot90(img, 2);
        case 8
            img = fliplr(img);
            img = rot90(img);
        otherwise
            disp('ERROR: invalid transform num')
    end
end % function
