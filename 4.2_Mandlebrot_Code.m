clear all; close all; clearvars; clc;

if isempty(gcp())
    parpool(); 
end

num_workers = gcp().NumWorkers;
maxIterations = 1000; 
gridSize = 2000; 

xaxis_lim = [-0.748766713922161, -0.748766707771757]; 
yaxis_lim = [0.123640844894862, 0.123640851045266];

numBlocks = 2; 

blockSize = gridSize / numBlocks;

yaxis_lim = linspace(yaxis_lim(1), yaxis_lim(2), numBlocks + 1); 

tic(); 
spmd
    [blockX, blockY] = ind2sub([numBlocks, numBlocks], labindex());
    
    x = linspace(xaxis_lim(1) + (blockX - 1) * (xaxis_lim(2) - xaxis_lim(1)) / numBlocks, ...
                  xaxis_lim(1) + blockX * (xaxis_lim(2) - xaxis_lim(1)) / numBlocks, ...
                  blockSize);
    
    y = linspace(yaxis_lim(blockY), yaxis_lim(blockY + 1), blockSize);
    
    [xGrid, yGrid] = meshgrid(x, y);
    z0 = xGrid + 1i * yGrid;
    count = ones(size(z0)); 
    
    z = z0; 
    for n = 0:maxIterations
        z = z .* z + z0;
        inside = abs(z) <= 2;
        count = count + inside;
    end
    count = log(count); 
end

cpuTime = toc(); 

set(gcf, 'Position', [200 200 600 600])
imagesc(cat(2, x{:}), cat(2, y{:}), cat(1, count{:})); % Combine results
axis image; axis off; colormap([jet(); flipud(jet()); 0 0 0]); % Set the color map
drawnow; % Update the figure
title(sprintf('%1.2f secs (with spmd)', cpuTime)); % Show time taken