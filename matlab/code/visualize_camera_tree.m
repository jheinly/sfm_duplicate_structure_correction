function [] = visualize_camera_tree(...
    camera_tree, camera_data, model_name, filename, edge_label_objs, group_assignments, image_folder, graphviz_sfdp_exe)

[cams1, cams2] = find(camera_tree);
num_edges = length(cams1);

cameras_with_edges = unique([cams1; cams2]);

node_names = cell(camera_data.num_cameras, 1);
for i = 1:camera_data.num_cameras
    node_names{i} = ['"' num2str(i) '"'];
end    

if isempty(group_assignments)
    num_groups = 0;
else
    group_assignments = normalize_group_assignments(group_assignments);
    num_groups = max(group_assignments);
end

graphviz_name = [filename '.graphviz'];
output = fopen(graphviz_name, 'w');
fprintf(output, 'graph G {\n');
if isempty(image_folder)
    fprintf(output, 'graph [overlap=false, sep="+8"];\n');
else
    fprintf(output, 'graph [overlap=false, sep="+20"];\n');
end

if isempty(image_folder)
    fprintf(output, 'node [ style=filled ];\n');
else
    %fprintf(output, 'node [ shape=box, fixedsize=true, height=2, width=3, style=filled ];\n');
    fprintf(output, 'node [ shape=box, style=filled ];\n');
    %fprintf(output, 'node [ shape=box ];\n');
    %fprintf(output, 'edge [len=4];\n');
    fprintf(output, ['imagepath="' image_folder '/";\n']);
end

for i = 1:camera_data.num_cameras
    if any(i == cameras_with_edges)
        fprintf(output, [node_names{i} ' [']);

        if num_groups > 0
            if group_assignments(i) ~= 0
                if isempty(image_folder)
                    fprintf(output, ' fillcolor=');
                else
                    fprintf(output, ' color=');
                end

                h = group_assignments(i) / (num_groups + 1);
                s = 0.7;
                v = 1;
                fprintf(output, '"%f %f %f"', h, s, v);
                
                if ~isempty(image_folder)
                    fprintf(output, ', penwidth=30');
                end
            end
        end

        if ~isempty(image_folder)
            fprintf(output, [' image="' camera_data.names{i} '.jpg"']);
            fprintf(output, ', imagescale=true, labelloc=b');
        end

        fprintf(output, '];\n');
    end
end

for i = 1:num_edges
    cam1 = cams1(i);
    cam2 = cams2(i);
    
    fprintf(output, [node_names{cam1} ' -- ' node_names{cam2}]);
    
    num_labels = length(edge_label_objs);
    label_text = '';
    label_important = false;
    for j = 1:num_labels
        [label, important] = edge_label_objs{j}.label(cam1, cam2);
        if ~isempty(label_text) && ~isempty(label)
            label_text = [label_text '\n'];
        end
        label_text = [label_text label];
        label_important = label_important || important;
    end
    
    if isempty(image_folder)
        if isempty(label_text)
            % No-op
        else
            if label_important
                fprintf(output, [' [ label="' label_text '", fontsize=14, fontcolor=red, penwidth=4, color=red ]']);
            else
                fprintf(output, [' [ label="' label_text '", fontsize=10 ]']);
            end
        end
    else
        if isempty(label_text)
            fprintf(output, [' [ penwidth=4 ]']);
        else
            if label_important
                fprintf(output, [' [ label="' label_text '", fontsize=14, fontcolor=red, penwidth=15, color=red ]']);
            else
                fprintf(output, [' [ label="' label_text '", fontsize=10, penwidth=4 ]']);
            end
        end
    end
    
    fprintf(output, ';\n');
end

fprintf(output, '}\n');
fclose(output);

% neato
% dot
% fdp
% sfdp
if isempty(image_folder)
    png_name = [filename '.png'];
    system([graphviz_sfdp_exe ' ' graphviz_name ' -o' png_name ' -Tpng']);
else
    jpg_name = [filename '.jpg'];
    system([graphviz_sfdp_exe ' ' graphviz_name ' -o' jpg_name ' -Tjpg']);
end

delete(graphviz_name)

end % function
