function disparmap = mapDisparity(im1, im2)
% Calculate the disparity map between two RGB images
% Disparity is calculated for each color separately
visualise = true;

% [W,H] = size(im1);                      % Get image size
% disparmap = zeros(W,H,3);               % Initialize disparity map

for rgb = 1:3                           % Loop over RGB index (1, 2 or 3)
    img1 = im1(:,:,rgb);
    img2 = im2(:,:,rgb);

    % Calculate disparity map
    disparRange = [200 360];
    disparmap(:,:,rgb) = disparity(img1, img2,...
        'BlockSize', 5, 'DisparityRange', disparRange);
end

% Visualisation
if visualise
    figure
    imshow(disparmap,disparRange);
    title('Disparity Map');
end
