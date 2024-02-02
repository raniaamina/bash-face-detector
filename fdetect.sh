#!/bin/bash
## Simple Face Detector Script by Rania Amina

# Variabel Setup
default_detected_folder="$PWD/detected-face"
default_num_parallel_processes=5

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
        echo "$faces Wajah terdeteksi dalam $image_path"
        move_to_detected_folder "$image_path" "$move_target_dir"
    else
        echo "Tidak ada wajah yang terdeteksi dalam $image_path"
    fi
}

# Fungsi untuk mendeteksi wajah dalam semua file gambar di dalam folder (dengan paralel)
detect_in_folder() {
    folder_path="$1"
    num_parallel_processes="$2"

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
        detect_single_image "{}" "$1"
        echo "------------------------"
    ' bash "$move_target_dir"
}

# Menampilkan pesan help
print_help() {
    echo "Usage: $0 -f <image_path> -o <move_target_dir> -d <folder_path>"
    echo "  -f    Path to the image file for face detection."
    echo "  -o    (Optional) Target directory to move the detected image. If not provided, the default directory will be used."
    echo "  -d    (Optional) Directory containing images in jpg, png, and webp format to perform face detection on."
}

# Parsing argumen
while getopts ":f:o:d:" opt; do
    case $opt in
    f)
        image_path="$OPTARG"
        ;;
    o)
        move_target_dir="$OPTARG"
        ;;
    d)
        folder_path="$OPTARG"
        ;;
    \?)
        print_help
        exit 1
        ;;
    esac
done

# Jika tidak ada argumen yang diberikan, tampilkan pesan usage
if [ -z "$image_path" ] && [ -z "$folder_path" ]; then
    print_help
    exit 1
fi

# Jika ada argumen file gambar, deteksi wajah
if [ -n "$image_path" ]; then
    detect_single_image "$image_path" "$move_target_dir"
fi

# Jika ada argumen folder, deteksi wajah dalam semua gambar di dalam folder
if [ -n "$folder_path" ]; then
    detect_in_folder "$folder_path" "$default_num_parallel_processes"
fi
