function [surface_normal, azimuth, zenith] = get_normal_from_polarized_imgs(polar_imgs, ...
polar_angles, refractive_index, attenuation_index)

% Calculate azimuth and zenith from poalrized images
[height, width, channel] = size(polar_imgs);

deg_of_polar = zeros(height, width); % Degree of polarization for each pixel
azimuth = zeros(height, width);
zenith = zeros(height, width);

nx = zeros(height, width);
ny = zeros(height, width);
nz = zeros(height, width);
surface_normal = zeros(height, width, 3);


% Solve azimuth and zenith for each pixel point
for y = 1:height
    for x = 1:width
        
        A = zeros(channel, 3);
        b = zeros(1, channel);
        
        for i=1:channel
            b(1, i) = polar_imgs(y, x, i);
            A(i, :) = [1; cos(2*polar_angles(i)); sin(2*polar_angles(i))];
        end
        
        % Euclidean norm to check whether all zeros
        if (norm(b, 1) == 0)
            deg_of_polar(y, x) = 0;
            zenith(y,x) = 0;
            azimuth(y,x) = 0;
            continue;
        end
        
        % Solve with least squares
        sol = A \ b';
        
        deg_of_polar(y, x) = (2*((sol(2))^2 + (sol(3))^2)^(1/2)) / (sol(1) * 2);
        
        % Solve azimuth; Four cases for arc tangent
        azimuth(y, x) = atan2(sol(3), sol(2));
%         if (sol(2) > 0) && (sol(3) >= 0)
%             azimuth(y, x) = atan(sol(3)/sol(2))/2;
%         elseif (sol(2) < 0) && (sol(3) >= 0)
%             azimuth(y, x) = atan(sol(3)/sol(2))/2 + pi / 2;
%         elseif (sol(2) > 0) && (sol(3) <= 0)
%             azimuth(y, x) = atan(sol(3)/sol(2))/2;
%         elseif (sol(2) < 0) && (sol(3) <= 0)
%             azimuth(y, x) = atan(sol(3)/sol(2))/2 - pi / 2;
%         else
%             azimuth(y,x) = 0;
%         end
        
        % Solve zenith
        cur_ro = deg_of_polar(y, x);
        if (cur_ro > 0) && (cur_ro < 0.6) % Diffuse
            
            alpha = (refractive_index-1/refractive_index)^2 + cur_ro*(refractive_index+1/refractive_index)^2;
            bb = 4 * cur_ro * (refractive_index^2 + 1) * (alpha - 4 * cur_ro);
            discr = bb^2 + 16*(cur_ro)^2*(16*(cur_ro)^2-alpha^2)*(refractive_index^2-1)^2;
            temp = ((-bb - discr^(1/2))/(2*(16*(cur_ro)^2-alpha^2)))^(1/2);
            zenith(y,x) = asin(temp);
        else % Specular
            zenith(y,x) = 0;
        end
        
        % Get surface normals from azimuth and zenith
        nx(y,x) = cos(azimuth(y,x)) * sin(zenith(y,x));
        ny(y,x) = sin(azimuth(y,x)) * sin(zenith(y,x));
        nz(y,x) = cos(zenith(y,x));
        surface_normal(y,x,:) = [nx(y,x), ny(y,x), nz(y,x)];
    end
end

end
