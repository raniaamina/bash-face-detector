# Simple Face Detector Script
## Dependencies

This script relies on the following Python dependency:
- OpenCV: Open Source Computer Vision Library

### Installation
Install OpenCV using pip:
```bash
pip install opencv-python
```

### Run the face detection script:

```bash
# Single file check
./fdetect.sh -f <image_path> -o <move_target_dir>

# Bulk check files inside a folder
./fdetect.sh -d <directory_path> -o <move_target_dir>
```
- -f: Path to the image file for face detection.
- -o: (Optional) Target directory to move the detected image. If not provided, the default directory will be used.
- -d: (Optional) Directory containing images in jpg, png, and webp format to perform face detection on.
- -j: (Optional) Number of parallel processes to use (default is 5).

Example:

```bash
./fdetect.sh -f path/to/image.jpg -o path/to/output_dir
```

> Notes
> -----
> Make sure to have the necessary permissions to execute the script and move files


## Disclaimer
There are no guarantees whatsoever for this script. I'm using this script simply to help me sort through my old albums, so please use it at your own risk.