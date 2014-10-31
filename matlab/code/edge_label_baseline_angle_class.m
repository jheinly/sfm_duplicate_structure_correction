classdef edge_label_baseline_angle_class
    
    % Properties
    properties(SetAccess = private)
        camera_data = 0;
        point_data = 0;
        visibility_matrix = 0;
    end
    
    % Methods
    methods
        function [obj] = edge_label_baseline_angle_class(camera_data, point_data, visibility_matrix)
            obj.camera_data = camera_data;
            obj.point_data = point_data;
            obj.visibility_matrix = visibility_matrix;
        end
        
        function [str, important] = label(obj, cam_idx1, cam_idx2)
            angle = compute_baseline_angle_between_cameras(...
                cam_idx1, cam_idx2, obj.camera_data, obj.point_data, obj.visibility_matrix);
            str = sprintf('angle: %.1f', angle);
            important = false;
        end
    end
    
end
