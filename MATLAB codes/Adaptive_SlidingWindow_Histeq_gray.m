%% Read the grayscale image
image = imread('lowcontrast.jpg');
image = rgb2gray(image); % Convert to grayscale if it's a color image

image = im2double(image); % Convert to double for computation

% Parameters for Adaptive Histogram Equalization
tile_size = 256; % Size of the local regions
overlap = tile_size / 2; % 50% overlap between tiles
L = 256; % Number of intensity levels for an 8-bit image
clip_limit = 0.009; % Clip limit for contrast limiting

[rows, cols] = size(image);

% Calculate padding required to ensure full tiles at edges
pad_row = ceil(rows / tile_size) * tile_size - rows;
pad_col = ceil(cols / tile_size) * tile_size - cols;

% Pad the image for edge tiles (pad both rows and columns symmetrically)
padded_image = padarray(image, [pad_row, pad_col], 'replicate', 'post');
[pad_rows, pad_cols] = size(padded_image);

% Initialize blended image and weight map
blended_image = zeros(pad_rows, pad_cols);
weight_map = zeros(pad_rows, pad_cols);

% Step 1: Process Each Tile and Blend
for row_start = 1:overlap:pad_rows
    for col_start = 1:overlap:pad_cols
        % Define the tile region
        row_end = min(row_start + tile_size - 1, pad_rows);
        col_end = min(col_start + tile_size - 1, pad_cols);

        % Extract the tile
        tile = padded_image(row_start:row_end, col_start:col_end);
        tile_flat = tile(:);

        % Compute the histogram with contrast limiting
        histogram = histcounts(tile_flat, L, 'BinLimits', [0, 1], 'Normalization', 'probability');
        clip_value = clip_limit * numel(tile_flat);
        histogram = min(histogram, clip_value);
        histogram = histogram / sum(histogram); % Renormalize after clipping

        % Compute the CDF and map intensities
        cdf = cumsum(histogram);
        equalized_tile = interp1(linspace(0, 1, L), cdf, tile, 'linear', 'extrap');

        % Generate blending weights
        [rr, cc] = ndgrid(1:(row_end-row_start+1), 1:(col_end-col_start+1));
        row_blend = min(rr / overlap, (tile_size - rr + 1) / overlap);
        col_blend = min(cc / overlap, (tile_size - cc + 1) / overlap);
        blend_weights = row_blend .* col_blend;

        % Add the weighted tile to the blended image
        blended_image(row_start:row_end, col_start:col_end) = ...
            blended_image(row_start:row_end, col_start:col_end) + equalized_tile .* blend_weights;

        % Accumulate weights for normalization
        weight_map(row_start:row_end, col_start:col_end) = ...
            weight_map(row_start:row_end, col_start:col_end) + blend_weights;
    end
end

% Normalize the blended image using the weight map
blended_image = blended_image ./ max(weight_map, eps); % Avoid division by zero

% Step 2: Crop the image back to the original size
equalized_image = blended_image(1:rows, 1:cols);

% Clip intensity values to [0, 1]
equalized_image = max(0, min(equalized_image, 1));

% Step 3: Apply Gaussian Smoothing to Reduce Remaining Blockiness
sigma = 0.4; % Standard deviation for Gaussian blur
equalized_image = imgaussfilt(equalized_image, sigma);

% Display the results
figure;
subplot(1, 2, 1), imshow(image), title('Original Image');
subplot(1, 2, 2), imshow(equalized_image), title('CLAHE sliding window');
