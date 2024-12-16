%% Read the grayscale image
image = imread('lowcontrast.jpg');
image = rgb2gray(image); 

% Get the size of the image
[rows, cols] = size(image);

% Define the size of the local region (tile size)
tile_size = 128; 

% Initialize the equalized image
equalized_image = zeros(rows, cols, 'uint8');

% Step 1: Perform local histogram equalization
for i = 1:tile_size:rows
    for j = 1:tile_size:cols
        % Define the region (tile) boundaries
        tile_row_end = min(i + tile_size - 1, rows);
        tile_col_end = min(j + tile_size - 1, cols);
        
        % Extract the tile
        tile = image(i:tile_row_end, j:tile_col_end);
        
        % Step 2: Calculate the histogram of the tile
        L = 256; % Number of intensity levels for an 8-bit image
        histogram = zeros(1, L);
        [tile_rows, tile_cols] = size(tile);
        for m = 1:tile_rows
            for n = 1:tile_cols
                intensity = tile(m, n);
                histogram(intensity + 1) = histogram(intensity + 1) + 1;
            end
        end
        
        % Step 3: Normalize the histogram (PDF)
        total_pixels = tile_rows * tile_cols;
        pdf = histogram / total_pixels;
        
        % Step 4: Compute the CDF
        cdf = zeros(1, L);
        cdf(1) = pdf(1);
        for k = 2:L
            cdf(k) = cdf(k - 1) + pdf(k);
        end
        
        % Step 5: Create the transformation function
        transformation = round((L - 1) * cdf);
        
        % Step 6: Apply the transformation to the tile
        equalized_tile = zeros(tile_rows, tile_cols, 'uint8');
        for m = 1:tile_rows
            for n = 1:tile_cols
                equalized_tile(m, n) = transformation(tile(m, n) + 1);
            end
        end
        
        % Step 7: Store the equalized tile in the final image
        equalized_image(i:tile_row_end, j:tile_col_end) = equalized_tile;
    end
end

% Display the results
figure;
subplot(1, 2, 1), imshow(image), title('Original Image');
subplot(1, 2, 2), imshow(equalized_image), title('Local grey Equalized');
