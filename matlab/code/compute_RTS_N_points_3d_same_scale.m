function [M] = compute_RTS_N_points_3d_same_scale(left_points, right_points)

    % left_points  should be 3xN, where each column is a point and N > 3
    % right_points should be 3xN, where each column is a point and N > 3
    
    N = size(left_points, 2);
    
    left_mean = mean(left_points, 2);
    right_mean = mean(right_points, 2);
    
    left_normed = left_points - repmat(left_mean, 1, N);
    right_normed = right_points - repmat(right_mean, 1, N);
    
    %S = sqrt(sum(sum(right_normed .^ 2, 1)) / sum(sum(left_normed .^ 2, 1)));
    
    %left_normed = S .* left_normed;
    %left_mean = S .* left_mean;
    
    Smat = left_normed * right_normed';
    Sxx = Smat(1,1);
    Sxy = Smat(1,2);
    Sxz = Smat(1,3);
    Syx = Smat(2,1);
    Syy = Smat(2,2);
    Syz = Smat(2,3);
    Szx = Smat(3,1);
    Szy = Smat(3,2);
    Szz = Smat(3,3);
    
    Qmat = [Sxx + Syy + Szz, Syz - Szy,        Szx - Sxz,        Sxy - Syx;
            Syz - Szy,       Sxx - Syy - Szz,  Sxy + Syx,        Szx + Sxz;
            Szx - Sxz,       Sxy + Syx,       -Sxx + Syy - Szz,  Syz + Szy;
            Sxy - Syx,       Szx + Sxz,        Syz + Szy,       -Sxx - Syy + Szz];
    
    if any(any(isnan(Qmat))) || any(any(isinf(Qmat)))
        M = [];
        return
    end
    
    % columns are eigenvectors
    [vectors, values] = eig(Qmat);
    [val, idx] = max(diag(values));

    Q = vectors(:,idx);
    Q = Q / norm(Q);
    
    R = quaternion_to_matrix(Q);
    
    left_mean = R * left_mean;
    
    T = right_mean - left_mean;
    
    %M = [R * S, T];
    M = [R, T];

end
