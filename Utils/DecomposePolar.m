function [rho, phi,Iun] = DecomposePolar(images, angles, mask,method)
%DECOMPOSEPOLAR Decompose polarimetric images to polarisation image
%   Inputs:
%      images - rows by cols by nimages matrix of input images    rows x cols x nimages
%      angles - vector of polariser angles, length nimages        length nimages
%      mask   - binary foreground mask (true for foreground)      rows x cols
%      method - either 'linear' or 'nonlinear'         
%      n      - refractive index
%   Outputs:
%      rho    - rows by cols matrix containing degree of polarisation
%      phi    - rows by cols matrix containing phase angle
%      Iun    - rows by cols matrix containing unpolarised intensity

[rows,cols,nimages] = size(images);

if nargin<4
    % Default to linear method
    method = 'linear';
end

if nargin>2
    % A mask has been provided so select only foreground pixels
    for i=1:nimages
        im = images(:,:,i);
        I(:,i)=im(mask);
    end
else
    % No mask - use all pixels
    I = reshape(images,rows*cols,nimages);
end

%% choose method to calculate
if strcmp(method,'nonlinear')
    % For each pixel solve a nonlinear optimisation problem 
    % Warning - slow (displays percentage progress)
    Iun = zeros(size(I,1),1);
    rho = zeros(size(I,1),1);
    phi = zeros(size(I,1),1);
    
    fprintf('The calculation begins---------------------------------------\n ');
    for i=1:size(I,1)
        [ Iun(i,1),rho(i,1),phi(i,1) ] = TRS_fit( angles,I(i,:) );
        fprintf('\b\b\b\b\b\b%05.2f%%',i/size(I,1)*100);
    end
    fprintf('The calculation ends---------------------------------------\n ');
    phi = mod(phi,pi);
    
elseif strcmp(method,'linear')
    % Fast linear method - this seems to produce almost identical results
    % to the nonlinear method but is much faster
    A = [ones(nimages,1) cos(2.*angles') sin(2.*angles')];
    x = A\(I');
    x = x';
    Imax = x(:,1)+sqrt(x(:,2).^2+x(:,3).^2);
    Imin = x(:,1)-sqrt(x(:,2).^2+x(:,3).^2);
    Iun = (Imin+Imax)./2;
    rho = (Imax-Imin)./(Imax+Imin);
    phi = 0.5*atan2(x(:,3),x(:,2));
    phi = mod(phi,pi);
end


%% output the result
if nargin>2
    % We have a mask so need to reshape the estimated quantities to the
    % masked pixels only
    phi2 = nan(rows,cols);
    phi2(mask) = phi;
    phi = phi2;
    rho2 = nan(rows,cols);
    rho2(mask) = rho;
    rho = rho2;
    Iun2 = nan(rows,cols);
    Iun2(mask) = Iun;
    Iun = Iun2;
else
    phi = reshape(phi,rows,cols);
    rho = reshape(rho,rows,cols);
    Iun = reshape(Iun,rows,cols);
end



