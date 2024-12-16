# Histogram Equalization

Histogram equalization is a technique used in image processing to improve the contrast of an image by redistributing the intensity values of pixels. The goal is to enhance the image's overall contrast, especially in areas with low contrast, by stretching the range of intensity levels.

<br/><br/>

## 1. Compute the Histogram

The first step is to compute the histogram of the image, which represents the frequency of each pixel intensity.

$$
H(r_k) = number\ of\ pixels\ with\ intensity\ r_k
$$

Where:

- r<sub>k</sub>  is the intensity value k (for grayscale images, k is between 0 and 255).

<br/><br/>

## 2. Compute the Probability Density Function (PDF)

To normalize the histogram, compute the Probability Density Function (PDF), which represents the relative frequency of each intensity.

$$
PDF(r_k) = \frac{H(r_k)}{N}
$$

Where:

- H(r<sub>k</sub>) is the histogram value for intensity r<sub>k</sub>,
- N is the total number of pixels in the image.

<br/><br/>

## 3. Compute the Cumulative Distribution Function (CDF)

Next, compute the cumulative distribution function of the histogram.

$$
CDF(r_k) = \sum_{i=0}^{k} PDF(r_i)
$$

Where:

- CDF(r<sub>k</sub>) is the cumulative sum of the PDF values from intensity 0 to k.

<br/><br/>

## 4. Map the Intensities

Use the CDF to map the original pixel intensities to the new enhanced intensities. The mapping scales the normalized CDF to the range [0, L-1], where L = 256 for 8-bit images.

$$
r_k' = round(CDF(r_k) \cdot (L - 1))
$$

Where:

- r<sub>k</sub>' is the new intensity value for each original intensity \( r<sub>k</sub> \),
- L is the number of intensity levels (for 8-bit images, L = 256).

Each pixel intensity in the input image is replaced using the transformation function

$$
T(r_k) = round(CDF(r_k) \cdot (L - 1))
$$

which is derived from the CDF.

---
## Extension to Colored Images (Channels Together)

To apply histogram equalization on a colored image while treating all channels together:

1. **Flatten All Channels**: Combine the intensities from all three color channels (R, G, B) into a single array to create a unified histogram. This ensures that the same transformation is applied across all channels.
  
2. **Perform Histogram Equalization**: Use the steps described above (compute the histogram, normalize to PDF, calculate the CDF, and map intensities) on the combined intensity data.
  
3. **Reshape Back to Original Size**: After applying the intensity mapping, reshape the equalized data back to its original dimensions for each channel.

---
## Local Histogram Equalization

Local histogram equalization improves the contrast of an image by applying histogram equalization to small regions (tiles) of the image, instead of the entire image. This technique is particularly useful in enhancing local details in low-contrast areas without overexposing other regions.

### Steps for Local Histogram Equalization:

1. **Define Local Regions**: The image is divided into small, non-overlapping tiles (e.g., 128x128 pixels), and histogram equalization is applied to each region independently.
   
2. **Calculate Local Histogram**: For each tile, compute the histogram of pixel intensities.

3. **Normalize Local Histogram (PDF)**: Normalize the histogram to get the Probability Density Function (PDF) for each tile.

4. **Compute Cumulative Distribution Function (CDF)**: Calculate the CDF of the tile's PDF to capture the cumulative pixel distribution.

5. **Map Intensities**: Map the pixel intensities in each tile using the transformation function derived from the CDF, similar to global histogram equalization.

6. **Reconstruct the Image**: After processing all tiles, combine the equalized tiles to reconstruct the final image.

### Formula for Local Transformation:

Given the CDF of a local tile:

$$
CDF_{local}(r_k) = \sum_{i=0}^{k} PDF_{local}(r_i)
$$

The pixel intensities are then mapped by:

$$
r_k' = round(CDF_{local}(r_k) \cdot (L - 1))
$$

Where the transformation is applied to each tile independently.
