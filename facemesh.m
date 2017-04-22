function facemesh(disparmap,rgbmap)

[W,H] = size(disparmap);
[X,Y] = meshgrid(1:H,1:W);

figure
% surf(X,Y,disparmap,'EdgeColor','none')

% Gathering point data
xyzPoints = [X(:) Y(:) 5*disparmap(:)];
rmap = rgbmap(:,:,1);
gmap = rgbmap(:,:,2);
bmap = rgbmap(:,:,3);
rgbPoints = [rmap(:) gmap(:) bmap(:)];

% Construct point cloud
ptCloud = pointCloud(xyzPoints,'Color',rgbPoints);
pcshow(ptCloud);
camproj('perspective')
