#!/bin/bash
## Simple Face Detector Script by Rania Amina

# Variabel Setup
default_detected_folder="$PWD/detected-face"

# Fungsi untuk memindahkan file ke folder detected face
move_to_detected_folder() {
    image_path="$1"
    move_target_dir="$2"

    # Memeriksa apakah argumen -o diberikan atau tidak
    if [ -z "$move_target_dir" ]; then
        move_target_dir="$default_detected_folder"
    fi

    # Buat folder jika belum ada
    mkdir -p "$move_target_dir"

    # Ambil nama file tanpa path
    file_name=$(basename "$image_path")

    mv "$image_path" "$move_target_dir/"
    echo "Gambar dipindahkan ke $move_target_dir/$file_name"
}

# Fungsi untuk mendeteksi wajah dalam satu file foto
detect_single_image() {
    image_path="$1"
    move_target_dir="$2"

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
        move_to_detected_folder "$image_path" "$move_target_dir"
    else
        echo "Tidak ada wajah yang terdeteksi dalam $image_path"
    fi
}

# Menampilkan pesan help
print_help() {
    echo "Usage: $0 -f <image_path> -o <move_target_dir>"
    echo "  -f    Path to the image file for face detection."
    echo "  -o    (Optional) Target directory to move the detected image. If not provided, the default directory will be used."
}

# Parsing argumen
while getopts ":f:o:" opt; do
    case $opt in
    f)
        image_path="$OPTARG"
        ;;
    o)
        move_target_dir="$OPTARG"
        ;;
    \?)
        print_help
        exit 1
        ;;
    esac
done

# Jika tidak ada argumen yang diberikan, tampilkan pesan usage
if [ -z "$image_path" ]; then
    print_help
    exit 1
fi

# Panggil fungsi detect_single_image dengan move_target_dir sebagai argumen opsional
detect_single_image "$image_path" "$move_target_dir"
