#!/bin/bash
## Simple Face Detector Script by Rania Amina

# Variabel Setup
default_detected_folder="$PWD/detected-face"

# Fungsi untuk memindahkan file ke folder detected face
move_to_detected_folder() {
    image_path="$1"
    detected_folder="$default_detected_folder"

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

    # Memeriksa apakah file gambar ditemukan
    if [ ! -f "$image_path" ]; then
        echo "Error: File gambar tidak ditemukan: $image_path"
        exit 1
    fi

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

# Parsing argumen
while getopts ":f:" opt; do
    case $opt in
    f)
        detect_single_image "$OPTARG"
        ;;
    \?)
        echo "Usage:"
        echo "  ./fdetect.sh -f <image_path>"
        exit 1
        ;;
    esac
done

# Jika tidak ada argumen yang diberikan, tampilkan pesan usage
if [ $# -eq 0 ]; then
    echo "Usage:"
    echo "  ./fdetect.sh -f <image_path>"
    exit 1
fi
