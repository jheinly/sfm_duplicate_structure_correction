function [] = create_thumbnails(camera_data, image_folder, thumbnail_folder, thumbnail_size)

    if ~exist(thumbnail_folder, 'dir')
        mkdir(thumbnail_folder);
    end
    
    for i = 1:camera_data.num_cameras
        thumbnail_path = [thumbnail_folder '/' camera_data.names{i} '.jpg'];
        if ~exist(thumbnail_path, 'file')
            img = imread([image_folder '/' camera_data.names{i} '.jpg']);
            scale = thumbnail_size / max(size(img,1), size(img,2));
            thumbnail = imresize(img, scale);
            imwrite(thumbnail, thumbnail_path);
        end
    end

end
