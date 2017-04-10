%% convert a video
clear variables
close all

inputname = 'input\_name.mp4';
outputname = 'output\_name.mp4';
profile = 'MPEG-4';
framerate = 25;
quality = 75;

resize = 1;     % resizing needed?
width = 640;    % if so, this the new width
height = 480;   % and this is the new height
crop = 0;       % cropping needed?
croprect = [ 142        36       563       672];

obj = VideoReader(inputname);
nFrames = obj.NumberOfFrames;
wobj = VideoWriter(outputname,profile);
wobj.FrameRate = framerate;
wobj.Quality = quality;
open(wobj);

% Read and write one frame at a time.
hwait = waitbar(0);
k = 1;
while hasFrame(obj)
    im = readframe(obj);
    if crop                         \% crop if wanted
        im = imcrop(im,croprect);
    end
    if resize                       \% resize if wanted
        im = imresize(im,[height width]);
    end
    writeVideo(wobj,im);
    if~mod(k,10)==1,waitbar(k/nFrames,hwait);end
    k = k+1;
end
delete(hwait);
close(wobj)
