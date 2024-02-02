# Skrip Detektor Wajah

## Dependensi

Skrip ini bergantung pada satu dependensi Python:
- OpenCV: Open Source Computer Vision Library

### Instalasi
Instal OpenCV menggunakan pip:
```bash
pip install opencv-python
```
Jalankan skrip deteksi wajah:

```bash
# Pengecekan tunggal
./fdetect.sh -f <image_path> -o <move_target_dir>

# Pengecekan masal dalam folder
./fdetect.sh -d <directory_path> -o <move_target_dir>
```
- -f: Path ke file gambar untuk deteksi wajah.
- -o: (Opsional) Direktori tujuan untuk memindahkan gambar yang terdeteksi. Jika tidak diberikan, direktori default akan digunakan.
- -d: (Opsional) Direktori yang berisi gambar dalam format jpg, png, dan webp untuk dilakukan deteksi wajah.
- -j: (Optional) Jumlah proses paralel processes(default 5).

Contoh:

```bash
./fdetect.sh -f path/to/image.jpg -o path/to/output_dir
```
> Catatan
> -------
> Pastikan memiliki izin yang diperlukan untuk menjalankan skrip dan memindahkan file.

## Sangkalan
Tidak ada jaminan apapun untuk skrip ini. Saya menggunakan skrip ini sekadar untuk membantu saya menyortir album lama saya, jadi silakan gunakan dengan kesadaran risiko Anda tanggung sendiri.