% http://en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_from_axis_and_angle

function [R] = axis_angle_to_matrix(axis, angle)

    x = axis(1);
    y = axis(2);
    z = axis(3);
    s = sin(angle);
    c = cos(angle);

    c1 = 1 - c;
    xc1 = x * c1;
    yc1 = y * c1;
    zc1 = z * c1;
    xyc1 = x * yc1;
    xzc1 = x * zc1;
    yzc1 = y * zc1;
    xs = x * s;
    ys = y * s;
    zs = z * s;

    R = [c + x*xc1, xyc1 - zs, xzc1 + ys;...
         xyc1 + zs, c + y*yc1, yzc1 - xs;...
         xzc1 - ys, yzc1 + xs, c + z*zc1];

end
