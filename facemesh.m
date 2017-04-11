function facemesh(disparmap)

[W,H] = size(disparmap);
[X,Y] = meshgrid(1:H,1:W);

figure
surf(X,Y,disparmap,'EdgeColor','none')

