% Read the color image
image = imread('lowcontrast_city.jpg'); % Also: 'underexposed.jpg'

% Get the size of the image
[rows, cols, channels] = size(image);

if channels ~= 3
    error('The input image is not a color image.');
end

% Define the size of the local region (tile size)
tile_size = 256;  

% Number of tiles in each dimension
num_tiles_x = ceil(cols / tile_size);
num_tiles_y = ceil(rows / tile_size);

% Define the clip limit
clip_limit = 0.009; % (percentage of total pixels per tile)

% Initialize a cell to store the histograms and transformations for each tile
tile_transforms = cell(num_tiles_y, num_tiles_x);

% Step 1: Precompute the transformations for each tile with CLAHE
for tile_i = 1:num_tiles_y
    for tile_j = 1:num_tiles_x
        % Define the region (tile) boundaries
        row_start = (tile_i - 1) * tile_size + 1;
        row_end = min(tile_i * tile_size, rows);
        col_start = (tile_j - 1) * tile_size + 1;
        col_end = min(tile_j * tile_size, cols);
        
        % Extract the tile for all channels
        tile = image(row_start:row_end, col_start:col_end, :);
        
        % Step 2: Calculate the histogram of the tile for all channels together
        L = 256; % Number of intensity levels for an 8-bit image
        histogram = zeros(1, L);
        tile_flat = tile(:); % Flatten the tile into a single vector for all channels
        
        % Create the histogram by counting the pixel intensities
        for k = 1:length(tile_flat)
            intensity = tile_flat(k);
            histogram(intensity + 1) = histogram(intensity + 1) + 1;
        end
        
        % Step 3: Normalize the histogram (PDF)
        total_pixels = numel(tile);
        pdf = histogram / total_pixels;
        
        % Step 4: Apply contrast limiting
        clip_value = clip_limit * total_pixels;
        excess = max(pdf - clip_value / total_pixels, 0); % Excess beyond the clip limit
        clipped_pdf = pdf - excess; % Clip the PDF
        clipped_pdf = clipped_pdf + sum(excess) / L; % Redistribute excess evenly
        
        % Step 5: Compute the CDF of the clipped histogram
        cdf = cumsum(clipped_pdf);
        
        % Create the transformation function (CLAHE)
        transformation = round((L - 1) * cdf);
        
        % Store the transformation
        tile_transforms{tile_i, tile_j} = transformation;
    end
end

% Step 2: Interpolate between tile transformations
equalized_image = zeros(rows, cols, channels, 'uint8');
for i = 1:rows
    for j = 1:cols
        % Determine which tiles surround the current pixel
        tile_i = min(floor((i - 1) / tile_size) + 1, num_tiles_y);
        tile_j = min(floor((j - 1) / tile_size) + 1, num_tiles_x);
        
        % Calculate weights for interpolation
        row_offset = mod(i - 1, tile_size) / tile_size;
        col_offset = mod(j - 1, tile_size) / tile_size;
        
        % Get the 4 surrounding tiles
        t1 = tile_transforms{tile_i, tile_j}; % Top-left
        t2 = tile_transforms{tile_i, min(tile_j + 1, num_tiles_x)}; % Top-right
        t3 = tile_transforms{min(tile_i + 1, num_tiles_y), tile_j}; % Bottom-left
        t4 = tile_transforms{min(tile_i + 1, num_tiles_y), min(tile_j + 1, num_tiles_x)}; % Bottom-right
        
        % Interpolate between the transformations
        for ch = 1:channels
            intensity = image(i, j, ch) + 1; % Add 1 because intensity levels are 1-indexed
            new_value = (1 - row_offset) * (1 - col_offset) * t1(intensity) + ...
                        (1 - row_offset) * col_offset * t2(intensity) + ...
                        row_offset * (1 - col_offset) * t3(intensity) + ...
                        row_offset * col_offset * t4(intensity);
            
            % Assign the interpolated value
            equalized_image(i, j, ch) = round(new_value);
        end
    end
end

% Display the results
figure;
subplot(1, 2, 1), imshow(image), title('Original Image');
subplot(1, 2, 2), imshow(equalized_image), title('CLAHE Equalized Image (Channels Together)');
