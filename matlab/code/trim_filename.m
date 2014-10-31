function [name] = trim_filename(filename)

    slashes = strfind(filename, '\');
    if ~isempty(slashes)
        filename = filename(slashes(end)+1:end);
    end
    
    slashes = strfind(filename, '/');
    if ~isempty(slashes)
        filename = filename(slashes(end)+1:end);
    end
    
    dots = strfind(filename, '.');
    if ~isempty(dots)
        filename = filename(1:dots(end)-1);
    end
    
    name = filename;

end
