% demonstrates sparse stereo
% disp('===========================');
% clear all; dbstop error; close all;
for i = 1:309
% read images from file
Ileft1 = imread(sprintf('/home/twangcat/Desktop/libviso2/101N_sacramento/101N_a2_%d.png', i));
Iright1 = imread(sprintf('/home/twangcat/Desktop/libviso2/101N_sacramento/101N_a1_%d.png', i));

% Ileft2 = imread(sprintf('/home/twangcat/Desktop/libviso2/101N_sacramento/101N_a2_%d.png', i+1));
% Iright2 = imread(sprintf('/home/twangcat/Desktop/libviso2/101N_sacramento/101N_a1_%d.png', i+1));

I = imresize(cat(2, Ileft1, Iright1),1);
imshow(I);
pause()
end