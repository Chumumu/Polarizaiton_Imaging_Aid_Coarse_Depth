# Polarizaiton_Imaging_Aid_Coarse_Depth


## Description

we develop a polarization imaging method for 3D reconstruction combined with fused coarse depth from speckle stereo to achieve reconstruction of less-texture object with highly reflective region. The contributions of this study can be summarized as follows: 
1) We propose a polarization 3D imaging method that does not depend on the texture of objects, which intuitively fuses coarse depth with polarization information by establishing a large linear sparse equation system;
2) We discuss the necessity of taking into account both diffuse and specular reflection types under the perspective projection model

## Steps

### Step 1: Solve for Polarization Normals

The first step involves deriving polarization normals from polarized images. This process utilizes the intensity differences at various polarization angles to calculate the orientation of the surface normals based on the polarization effect.
(As shown in step1_decompose_polarisation_6.m)

### Step 2: Compute Rough Depth Map and Surface Guided Normals

The second step calculates a rough depth map from the polarization data. Based on different transmission projection models, this step also solves for surface guided normals, which are crucial for accurate surface orientation and depth estimation.
(As shown in step2_guide_normal_orthogonal.m and step2_guide_normal_perspective.m)

### Step 3: Disambiguation of Polarization Normals

In step three, the surface guided normals are used to disambiguate the polarization normals. This step is essential for resolving any inconsistencies in normal directions derived from the polarized images.
(As shown in step3_NormalCorrection folder)

### Step 4: Fusion of Rough Depth Map and Disambiguated Polarization Normals

The final step merges the rough depth map with the disambiguated polarization normals. This fusion process enhances the accuracy and quality of the final surface reconstruction, leading to more precise and detailed 3D models.
(step4_merge_depth_normal.m)

## Installation

### Prerequisites

- **Matlab**: Ensure you have Matlab installed as most of the processing steps are performed in this environment.
- **OpenGM**: OpenGM is a required library for running step 3 of this project. Currently, it is only confirmed to install successfully on Ubuntu 18.04. To install OpenGM along with its Python wrapper, use the following command (note that it only supports Python 2.7):

```bash
sudo apt-get install libopengm-bin libopengm-dev libopengm-doc python-opengm python-opengm-doc
```

## Usage

Here's how to run each step of the process:

- **Step 1-2**: Run the Matlab scripts `step1.m` and `step2.m` to process the initial stages.
- **Step 3**: Execute the provided script in the Ubuntu 18.04 environment with OpenGM installed to disambiguate the polarization normals.
- **Step 4**: Continue in Matlab with `step4.m` to complete the fusion of data.

### Visualization Demo

The `Figure_AO_paper` folder in the current directory contains visualization results and a testing demo. To view the demo, navigate to this folder and follow the instructions provided within to run the visualization scripts.

### Utilities

The `Utils` folder contains multiple utility functions that are essential for the various processing steps outlined above. These utilities provide additional functionality, such as data handling and transformations, that support the main scripts. Be sure to check this folder for any necessary functions that may need to be included or referenced in your script executions.

### Further Details


## Authors

Chuheng Xu, Yao Hu

# Acknowledgments

This project builds upon ideas and code from the following research papers:

- D. Zhu and W.A.P. Smith, "Depth from a polarisation + RGB stereo pair" 

- Ye Yu and William A. P. Smith, "Depth estimation meets inverse rendering for single image novel view synthesis" 

