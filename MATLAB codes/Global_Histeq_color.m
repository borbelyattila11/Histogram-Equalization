% Read the color image
image = imread('lowcontrast_city.jpg');
image = im2double(image); % Convert to double for calculations

% Get the size of the image
[rows, cols, channels] = size(image);

if channels ~= 3
    error('The input image is not a color image.');
end

% Flatten all channels into a single intensity array
intensities = reshape(image, [], 1);

% Perform histogram equalization on the combined intensities
equalized_intensities = histogram_equalization(intensities);

% Reshape the equalized intensities back to the original image size
equalized_image = reshape(equalized_intensities, rows, cols, channels);

% Display the original and equalized images
figure;
subplot(1, 2, 1), imshow(image), title('Original Image');
subplot(1, 2, 2), imshow(equalized_image), title('Channels together equalized');

% Histogram Equalization Function
function output = histogram_equalization(data)
    % Normalize intensities to grayscale range (0-255)
    data = uint8(data * 255);
    
    % Step 1: Calculate histogram
    L = 256;
    histogram = zeros(1, L);
    total_pixels = numel(data);
    for i = 1:total_pixels
        intensity = data(i);
        histogram(intensity + 1) = histogram(intensity + 1) + 1;
    end
    
    % Step 2: Normalize histogram (PDF)
    pdf = histogram / total_pixels;
    
    % Step 3: Compute CDF
    cdf = zeros(1, L);
    cdf(1) = pdf(1);
    for k = 2:L
        cdf(k) = cdf(k - 1) + pdf(k);
    end
    
    % Step 4: Transformation function
    transformation = round((L - 1) * cdf);
    
    % Step 5: Apply transformation
    output = zeros(size(data), 'uint8');
    for i = 1:total_pixels
        output(i) = transformation(data(i) + 1);
    end
    
    % Convert back to double (0-1) range
    output = double(output) / 255;
end
