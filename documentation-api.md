# Dokumentasi API Quran Audio Dataset

Dokumen ini memuat spesifikasi rute distribusi media CDN serta endpoint API GitHub yang digunakan dalam pengelolaan dataset audio murottal.

## Endpoint Distribusi Media (CDN Publik)

| Field | Detail |
|---|---|
| Method + Endpoint | GET `https://github.com/FikFikk/quran-audio/releases/download/1.0.0/{surahNumber}.mp3` |
| Auth Required | No (Akses publik bebas token) |
| Headers | `Range: bytes=start-end` (opsional untuk pemutaran bertahap) |
| Query Params | Tidak ada |
| Request Body | Tidak ada |
| Response | HTTP 200 OK / HTTP 206 Partial Content (Stream biner audio MP3) |
| Notes | Mendukung HTTP Range Request untuk timeline scrubbing pemutar audio. |

| Field | Detail |
|---|---|
| Method + Endpoint | GET `https://raw.githubusercontent.com/FikFikk/quran-audio/main/metadata.json` |
| Auth Required | No |
| Headers | `Accept: application/json` |
| Query Params | Tidak ada |
| Request Body | Tidak ada |
| Response | HTTP 200 OK + Array JSON metadata 114 surah (nomor, nama, arti, dsb.) |
| Notes | Digunakan oleh aplikasi pemutar web untuk memuat data indeks surah secara dinamis. |

## Endpoint Manajemen Rilis (GitHub REST API Internal)

| Field | Detail |
|---|---|
| Method + Endpoint | GET `https://api.github.com/repos/FikFikk/quran-audio/releases/tags/{tag}` |
| Auth Required | Yes (Bearer token via Git Credential Manager / Personal Access Token) |
| Headers | `Authorization: Bearer <token>`, `Accept: application/vnd.github.v3+json` |
| Query Params | Tidak ada |
| Request Body | Tidak ada |
| Response | HTTP 200 OK + `id`, `upload_url`, `assets` |
| Notes | Digunakan oleh skrip sinkronisasi untuk mendeteksi rilis dan mengambil endpoint unggah aset. |

| Field | Detail |
|---|---|
| Method + Endpoint | GET `https://api.github.com/repos/FikFikk/quran-audio/releases/{release_id}/assets` |
| Auth Required | Yes (Bearer token) |
| Headers | `Authorization: Bearer <token>`, `Accept: application/vnd.github.v3+json` |
| Query Params | `per_page: integer (opsional, maks 100)`, `page: integer (opsional)` |
| Request Body | Tidak ada |
| Response | HTTP 200 OK + Daftar aset yang terpasang pada rilis |
| Notes | Mencegah unggah ganda dengan mengecek aset yang sudah terdaftar. |

| Field | Detail |
|---|---|
| Method + Endpoint | POST `{upload_url}?name={fileName}` |
| Auth Required | Yes (Bearer token) |
| Headers | `Authorization: Bearer <token>`, `Content-Type: audio/mpeg` |
| Query Params | `name: string (wajib, contoh: 001.mp3)` |
| Request Body | Binary stream berkas MP3 |
| Response | HTTP 201 Created + `id`, `name`, `browser_download_url` |
| Notes | Membutuhkan timeout minimum 600 detik untuk berkas surah besar (> 100 MB). |

## Tugas Terjadwal (Cron Jobs)

Tidak ada tugas terjadwal (cron job) yang berjalan di tingkat peladen lokal pada repositori dataset ini.
