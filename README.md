# Polarizaiton_Imaging_Aid_Coarse_Depth

# Project Title

## Description

This project focuses on processing polarized images to extract surface information through various computational photography techniques. The steps outlined below describe the core functionality implemented in this repository.

## Steps

### Step 1: Solve for Polarization Normals

The first step involves deriving polarization normals from polarized images. This process utilizes the intensity differences at various polarization angles to calculate the orientation of the surface normals based on the polarization effect.

### Step 2: Compute Rough Depth Map and Surface Guided Normals

The second step calculates a rough depth map from the polarization data. Based on different transmission projection models, this step also solves for surface guided normals, which are crucial for accurate surface orientation and depth estimation.

### Step 3: Disambiguation of Polarization Normals

In step three, the surface guided normals are used to disambiguate the polarization normals. This step is essential for resolving any inconsistencies in normal directions derived from the polarized images.

### Step 4: Fusion of Rough Depth Map and Disambiguated Polarization Normals

The final step merges the rough depth map with the disambiguated polarization normals. This fusion process enhances the accuracy and quality of the final surface reconstruction, leading to more precise and detailed 3D models.

## Installation

Provide instructions on how to install and run the project here.

## Usage

Include basic usage examples, perhaps how to run the main functions or scripts in the repository.

## Contributing

Information for developers interested in contributing to the project, such as how to submit pull requests, style guidelines, or contact info for the maintainer(s).

## License

Specify the project's license here.

## Authors

List of contributors and maintainers.

## Acknowledgments

Credits, references, and acknowledgments.
