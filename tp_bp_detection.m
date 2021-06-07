clc; clear all; close all;

load 3d_vol % '3d_vol' contains a 3D data named 'skl'. It is a binary image.

% Uncomment if the 3D data is not skeletonized yet.
% skl = bwskel(logical(skl)); 

%% Get connected components
cc = bwconncomp(skl,26);
lbl = labelmatrix(cc);

%% Get terminal and branch points
tp_st_all_cell = {}; % stores terminal  points for each connected component in cell formal
bp_st_all_cell = {}; % stores branch  points for each connected component in cell formal
all_tp = []; % stores all terminal points
all_bp = []; % stores all branch points

for i = 1:cc.NumObjects
    c = find(lbl==i);
    [rw,cl,dp] = ind2sub(size(skl),c);
    dim_matrix = [rw, cl, dp];
    tp = terminals(skl, dim_matrix); % get terminal points
    bp = branches(skl, dim_matrix); % get branch points
    tp_st_all_cell{i} = tp; % store terminal points in cell format
    bp_st_all_cell{i} = bp; % store branch points in cell format
    all_tp = [all_tp; tp];
    all_bp = [all_bp; bp]; 
end

% Remove duplicates
all_tp = unique(all_tp, 'rows');
all_bp = unique(all_bp, 'rows');

%% Visualization
v = zeros(size(skl));
if ~isempty(all_tp)
    v(sub2ind(size(skl), all_tp(:,1), all_tp(:,2), all_tp(:,3))) = 1;
end
if ~isempty(all_bp)
    v(sub2ind(size(skl), all_bp(:,1), all_bp(:,2), all_bp(:,3))) = 3;
end

volumeViewer(skl,v)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate terminal points
function tp = terminals(vol, dim_matrix)
    tp = []; %stores terminal points
    for i = 1: height(dim_matrix)
        curr_dim = dim_matrix(i,:);
        r = curr_dim(1); c = curr_dim(2); d = curr_dim(3);
        % Get cropped volume that contains its neigbors
        cropped_vol = vol_crop(vol, r, c, d); % cropped_vol size: 3x3x3 
        % A voxel is a terminal point if the summation of its neighbor
        % intensities along with its own intensity is exactly 2.
        if vol(r,c,d) == 1 && sum(cropped_vol,'all') == 2          
            tp = [tp; [r,c,d]];
        end
    end
    tp = unique(tp, 'row'); 
end

%% Generate branch points
function bp = branches(vol, dim_matrix)  
    bp = []; %stores branch points
    for i = 1:height(dim_matrix)  
        curr_dim = dim_matrix(i,:);
        r = curr_dim(1); c = curr_dim(2); d = curr_dim(3);
        % Get cropped volume that contains its neigbors
        cropped_vol = vol_crop(vol, r, c, d); % cropped_vol size: 3x3x3 
        % A voxel is a branch point if the summation of the neighbor
        % intensities along with its own intensity is greater than 3.
        if vol(r,c,d) == 1 && sum(cropped_vol, 'all') > 3          
            bp = [bp; [r,c,d]];
        end
    end
    bp = unique(bp, 'row'); 
end

%% Cropped_vol
function cropped_vol = vol_crop(vol, r, c, d)
    % 'r', 'c', 'd' -> row, column, depth
    % Add zero padding to avoid boundaries and corners
    padded_vol = padarray(vol, [1,1,1], 0, 'both');    
    padded_r = r + 1;
    padded_c = c + 1;
    padded_d = d + 1;
    % Get cropped volume
    cropped_vol = padded_vol(padded_r-1:padded_r+1,padded_c-1:padded_c+1,padded_d-1:padded_d+1);
end
