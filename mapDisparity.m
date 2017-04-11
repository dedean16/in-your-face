function disparmap = mapDisparity(im_Mr_rec, im_R_rec)
% Calculate the disparity map between two RGB images
% Disparity is calculated for each color separately
visualise = true;

im_Mr_rec_g = rgb2gray(im_Mr_rec);
im_R_rec_g = rgb2gray(im_R_rec);

% Calculate disparity map
disparityRange = [200 360];
disparmap = disparity(im_Mr_rec_g, im_R_rec_g,...
    'BlockSize', 5, 'DisparityRange', disparityRange);

% Visualisation
if visualise
    figure(3); clf;
    imshow(disparmap,disparityRange);
    title('Disparity Map');
    colormap jet
    colorbar
end
