clear all;
% -------------------------------------------------------------------------
%   Description:
%       Script to demo LapSRN for one image
%
%   Citation: 
%       Deep Laplacian Pyramid Networks for Fast and Accurate Super-Resolution
%       Wei-Sheng Lai, Jia-Bin Huang, Narendra Ahuja, and Ming-Hsuan Yang
%       IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2017
%
%   Contact:
%       Wei-Sheng Lai
%       wlai24@ucmerced.edu
%       University of California, Merced
% -------------------------------------------------------------------------

img_filename = 'emma.jpg';

%% parameters
opts.scale  = 4; % SR upsampling scale
opts.gpu    = 1; % GPU ID

%% setup paths
addpath(genpath('utils'));
addpath(fullfile(pwd, 'matconvnet-1.0-beta24/matlab'));
vl_setupnn;

%% Load pretrained odel
model_filename = fullfile('pretrained_models', sprintf('LapSRN_x%d.mat', opts.scale));

fprintf('Load %s\n', model_filename);
net = load(model_filename);
net = dagnn.DagNN.loadobj(net.net);
net.mode = 'test' ;

if( opts.gpu ~= 0 )
    gpuDevice(opts.gpu)
    net.move('gpu');
end


%% Load GT image
fprintf('Load %s\n', img_filename);
img_GT = im2double(imread(img_filename));
img_GT = mod_crop(img_GT, opts.scale);

%% Generate LR image
img_LR = imresize(img_GT, 1/opts.scale);

%% apply LapSRN
fprintf('Apply LapSRN for %dx SR\n', opts.scale);
img_HR = SR_LapSRN(img_LR, net, opts);

%% show results
img_LR = imresize(img_LR, opts.scale);
figure, imshow(cat(2, img_LR, img_HR, img_GT));
title(sprintf('Bicubic %dx    |    LapSRN %dx    |    Ground Truth', opts.scale, opts.scale));

