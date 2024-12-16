%% Read the grayscale image
image = imread('lowcontrast.jpg');
if size(image, 3) == 3
    image = rgb2gray(image); 
end

% Get the size of the image
[rows, cols] = size(image);

% Define the size of the sliding window
window_size = 256;  

% Initialize the equalized image
equalized_image = zeros(rows, cols, 'uint8');

% Step 1: Perform sliding window histogram equalization
half_window = floor(window_size / 2); % 50% overlap between tiles

for i = 1:rows
    for j = 1:cols
        % Define the window boundaries
        row_start = max(i - half_window, 1);
        row_end = min(i + half_window, rows);
        col_start = max(j - half_window, 1);
        col_end = min(j + half_window, cols);
        
        % Extract the window (local region)
        window = image(row_start:row_end, col_start:col_end);
        
        % Step 2: Calculate the histogram of the window
        L = 256; % Number of intensity levels for an 8-bit image
        histogram = zeros(1, L);
        [window_rows, window_cols] = size(window);
        for m = 1:window_rows
            for n = 1:window_cols
                intensity = window(m, n);
                histogram(intensity + 1) = histogram(intensity + 1) + 1;
            end
        end
        
        % Step 3: Normalize the histogram (PDF)
        total_pixels = window_rows * window_cols;
        pdf = histogram / total_pixels;
        
        % Step 4: Compute the CDF
        cdf = zeros(1, L);
        cdf(1) = pdf(1);
        for k = 2:L
            cdf(k) = cdf(k - 1) + pdf(k);
        end
        
        % Step 5: Create the transformation function
        transformation = round((L - 1) * cdf);
        
        % Step 6: Apply the transformation to the pixel
        equalized_image(i, j) = transformation(image(i, j) + 1);
    end
end

% Display the results
figure;
subplot(1, 2, 1), imshow(image), title('Original Image');
subplot(1, 2, 2), imshow(equalized_image), title('Sliding window gray equalized ');
