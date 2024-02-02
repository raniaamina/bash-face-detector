#!/bin/bash
## Simple Face Detector Script by Rania Amina

# Variabel Setup
default_detected_folder="$PWD/detected-face"
custom_output_folder=false
output_folder=""
num_parallel_processes=5 # Default value

# Fungsi untuk memindahkan file ke folder detected face
move_to_detected_folder() {
    image_path="$1"

    # Memeriksa apakah argumen -o diberikan atau tidak
    if [ -n "$output_folder" ]; then
        detected_folder="$output_folder"
    else
        detected_folder="$default_detected_folder"
    fi

    # Buat folder jika belum ada
    mkdir -p "$detected_folder"

    # Ambil nama file tanpa path
    file_name=$(basename "$image_path")

    mv "$image_path" "$detected_folder/"
    echo "Gambar dipindahkan ke $detected_folder/$file_name"
}

# Fungsi untuk mendeteksi wajah dalam satu file foto
detect_single_image() {
    image_path="$1"
    faces=$(
        python3 - <<EOF
import cv2
image = cv2.imread('$image_path')
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
detector = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
faces = detector.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))
print(len(faces))
EOF
    )

    if [ "$faces" -gt 0 ]; then
        echo $faces
        echo "Wajah terdeteksi dalam $image_path"
        move_to_detected_folder "$image_path"
    else
        echo "Tidak ada wajah yang terdeteksi dalam $image_path"
    fi
}

# Fungsi untuk mendeteksi wajah dalam semua file gambar di dalam folder (dengan paralel)
detect_in_folder() {
    folder_path="$1"

    # Cek apakah folder ada
    if [ ! -d "$folder_path" ]; then
        echo "Folder not found: $folder_path"
        exit 1
    fi

    # Mengekspor fungsi agar dapat diakses oleh xargs
    export -f detect_single_image
    export -f move_to_detected_folder

    # Loop semua file gambar di dalam folder dengan xargs untuk paralelisasi
    find "$folder_path" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.webp' \) -print0 | xargs -0 -n 1 -P "$num_parallel_processes" -I {} bash -c '
        echo "Mendeteksi wajah dalam {}:"
        detect_single_image "{}"
        echo "------------------------"
    '
}

# Parsing argumen
while getopts ":d:o:j:" opt; do
    case $opt in
    d)
        detect_in_folder "$OPTARG"
        ;;
    o)
        output_folder="$OPTARG"
        custom_output_folder=true
        ;;
    j)
        num_parallel_processes="$OPTARG"
        ;;
    \?)
        echo "Usage:"
        echo "  ./fdetect.sh -d <folder_path> -o <output_folder> -j <num_parallel_processes>  # Mendeteksi wajah dalam semua gambar di dalam folder"
        echo "  ./fdetect.sh <image_path> -o <output_folder>                               # Mendeteksi wajah dalam satu file gambar"
        exit 1
        ;;
    esac
done

# Shift untuk menangani argumen setelah parsing
shift $((OPTIND - 1))

# Jika tidak ada argumen yang diberikan, tampilkan pesan usage
if [ $# -eq 0 ]; then
    echo "Usage:"
    echo "  ./fdetect.sh -d <folder_path> -o <output_folder> -j <num_parallel_processes>  # Mendeteksi wajah dalam semua gambar di dalam folder"
    echo "  ./fdetect.sh <image_path> -o <output_folder>                               # Mendeteksi wajah dalam satu file gambar"
    exit 1
fi

# Jika ada argumen file gambar, deteksi wajah
if [ -f "$1" ]; then
    detect_single_image "$1"
    # Pindahkan ke custom output folder jika -o didefinisikan
    if [ "$custom_output_folder" = true ]; then
        move_to_detected_folder "$1"
    fi
else
    echo "Invalid argument: $1 is not a file"
    exit 1
fi
