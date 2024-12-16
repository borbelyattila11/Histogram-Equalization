% Read the color image
image = imread('lena.png');

% Convert image to double for computation
image = im2double(image);

% Check if the image is grayscale or color
[rows, cols, channels] = size(image);
if channels ~= 3
    error('The input image is not a color image.');
end

% Parameters for Adaptive Histogram Equalization
tile_size = 256; % Size of the local regions
overlap = tile_size / 2; % 50% overlap between tiles
L = 256; % Number of intensity levels for an 8-bit image
clip_limit = 0.9; % Clip limit for contrast limiting

% Calculate padding required to ensure full tiles at edges
pad_row = ceil(rows / tile_size) * tile_size - rows;
pad_col = ceil(cols / tile_size) * tile_size - cols;

% Pad the image for edge tiles (pad symmetrically)
padded_image = padarray(image, [pad_row, pad_col], 'replicate', 'post');
[pad_rows, pad_cols, ~] = size(padded_image);

% Initialize blended image and weight map
blended_image = zeros(pad_rows, pad_cols, channels);
weight_map = zeros(pad_rows, pad_cols);

% Step 1: Process Each Tile and Blend
for row_start = 1:overlap:pad_rows
    for col_start = 1:overlap:pad_cols
        % Define the tile region
        row_end = min(row_start + tile_size - 1, pad_rows);
        col_end = min(col_start + tile_size - 1, pad_cols);

        % Extract the tile (all channels combined)
        tile = padded_image(row_start:row_end, col_start:col_end, :);
        tile_flat = tile(:); % Flatten all channels into one vector

        % Compute the histogram with contrast limiting (for all channels together)
        histogram = histcounts(tile_flat, L, 'BinLimits', [0, 1], 'Normalization', 'probability');
        clip_value = clip_limit * numel(tile_flat);
        histogram = min(histogram, clip_value);
        histogram = histogram / sum(histogram); % Renormalize after clipping

        % Compute the CDF and map intensities
        cdf = cumsum(histogram);
        equalized_tile_flat = interp1(linspace(0, 1, L), cdf, tile_flat, 'linear', 'extrap');

        % Reshape the flattened tile back to its original dimensions
        equalized_tile = reshape(equalized_tile_flat, size(tile));

        % Generate blending weights
        [rr, cc] = ndgrid(1:(row_end-row_start+1), 1:(col_end-col_start+1));
        row_blend = min(rr / overlap, (tile_size - rr + 1) / overlap);
        col_blend = min(cc / overlap, (tile_size - cc + 1) / overlap);
        blend_weights = row_blend .* col_blend;

        % Add the weighted tile to the blended image (channels together)
        for ch = 1:channels
            blended_image(row_start:row_end, col_start:col_end, ch) = ...
                blended_image(row_start:row_end, col_start:col_end, ch) + ...
                equalized_tile(:, :, ch) .* blend_weights;
        end

        % Accumulate weights for normalization
        weight_map(row_start:row_end, col_start:col_end) = ...
            weight_map(row_start:row_end, col_start:col_end) + blend_weights;
    end
end

% Normalize the blended image using the weight map
for ch = 1:channels
    blended_image(:, :, ch) = blended_image(:, :, ch) ./ max(weight_map, eps); % Avoid division by zero
end

% Step 2: Crop the image back to the original size
equalized_image = blended_image(1:rows, 1:cols, :);

% Clip intensity values to [0, 1]
equalized_image = max(0, min(equalized_image, 1));

% Step 3: Apply Gaussian Smoothing to Reduce Remaining Blockiness
sigma = 0.4; % Standard deviation for Gaussian blur
for ch = 1:channels
    equalized_image(:, :, ch) = imgaussfilt(equalized_image(:, :, ch), sigma);
end

% Display the results
figure;
subplot(1, 2, 1), imshow(image), title('Original Image');
subplot(1, 2, 2), imshow(equalized_image), title('CLAHE Sliding Window (Channels Together)');
