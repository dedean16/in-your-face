function disparmap = mapDisparity(im1, im2)
% Calculate the disparity map between two RGB images
% Disparity is calculated for each color separately
visualise = true;

for rgb = 1:3                               % Loop over RGB index (1, 2 or 3)
    img1 = im1(:,:,rgb);
    img2 = im2(:,:,rgb);

    % Calculate disparity map
    disparRange = [0 640];
    disparmap(:,:,rgb) = disparity(img1, img2,...
        'BlockSize', 5, 'DisparityRange', disparRange);
    disparmap(disparmap<0) = NaN;
    
    disparmap(disparmap<200 | disparmap>400) = NaN;       % remove other stuff
end

%% Visualisation
if visualise
    figure
    
    % Show disparity map
    subplot(1,2,1)
    imshow((disparmap-200)/200);
    title('Disparity map');
    
    % Show histogram
    subplot(1,2,2)
    hist(disparmap(:),40)
end
