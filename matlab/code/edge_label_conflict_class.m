classdef edge_label_conflict_class

    % Properties
    properties(SetAccess = private)
        camera_tree = [];
        edge_conflict = [];
        sorted_conflict_indices = [];
    end % properties
    
    % Methods
    methods
        function [obj] = edge_label_conflict_class(camera_tree, edge_conflict)
            obj.camera_tree = camera_tree;
            obj.edge_conflict = edge_conflict;
            [~, obj.sorted_conflict_indices] = sort(edge_conflict, 'descend');
        end
        
        function [str, important] = label(obj, cam_idx1, cam_idx2)
            edge_idx = find_edge_index(obj.camera_tree, cam_idx1, cam_idx2);
            conflict = obj.edge_conflict(edge_idx);
            if conflict == 0
                str = '';
            else
                str = sprintf('conflict: %.2f', conflict);
            end
            if length(obj.sorted_conflict_indices) > 5
                important = any(obj.sorted_conflict_indices(1:5) == edge_idx);
            else
                important = obj.sorted_conflict_indices(1) == edge_idx;
            end
        end
    end % methods
    
end % class
