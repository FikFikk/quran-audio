# Kala Quran Audio Dataset (CDN Media)

Repositori publik resmi untuk penyimpanan dan distribusi berkas audio murottal Al-Qur'an 30 Juz (114 Surah) lengkap. Didesain khusus sebagai CDN media tanpa biaya untuk pemutar web **Kala** dan aplikasi Al-Qur'an digital lainnya.

---

## Informasi Qari
- **Qari:** Syeikh Dr. Yasser bin Rasyid Al-Dosari (إمام الحرم المكي الشريف)
- **Format:** MP3 Master Studio (Audio Continuous Gapless per Surah)
- **Kualitas:** 128 kbps, 44.1 kHz, Stereo
- **Total Surah:** 114 Surah Lengkap

---

## Pola URL Distribusi (GitHub Releases CDN)

Seluruh berkas audio didistribusikan melalui infrastruktur **GitHub Releases Asset CDN** (`objects.githubusercontent.com`) yang cepat, stabil, mendukung *HTTP Range Requests (206 Partial Content)* untuk *scrubbing* timeline, dan dapat diakses publik tanpa autentikasi token.

### Format Pemanggilan URL
```text
https://github.com/FikFikk/quran-audio/releases/download/1.0.0/{surahNumber}.mp3
```

### Contoh URL Siap Pakai:
- Surah Al-Fatihah (001):  
  `https://github.com/FikFikk/quran-audio/releases/download/1.0.0/001.mp3`
- Surah Al-Baqarah (002):  
  `https://github.com/FikFikk/quran-audio/releases/download/1.0.0/002.mp3`
- Surah Ali 'Imran (003):  
  `https://github.com/FikFikk/quran-audio/releases/download/1.0.0/003.mp3`
- Surah An-Nas (114):  
  `https://github.com/FikFikk/quran-audio/releases/download/1.0.0/114.mp3`

---

## Struktur Penamaan Berkas
Setiap berkas menggunakan format 3 digit nomor surah standar internasional:

| Nomor Surah | Nama Surah | Nama Berkas |
|:---:|:---|:---|
| 001 | Al-Fatihah | `001.mp3` |
| 002 | Al-Baqarah | `002.mp3` |
| 003 | Ali 'Imran | `003.mp3` |
| ... | ... | ... |
| 114 | An-Nas | `114.mp3` |

---

## Panduan Mengunggah Berkas Audio ke GitHub Releases

Jangan pernah melakukan `git commit` file `.mp3` langsung ke cabang Git agar repositori tetap ringan. Unggah berkas audio melalui fitur **Releases**:

### Cara 1: Unggah Manual via Web Peramban
1. Buka halaman [GitHub Releases](https://github.com/FikFikk/quran-audio/releases).
2. Klik tombol edit pada release yang dituju.
3. Tarik dan lepas (*drag-and-drop*) berkas `001.mp3` hingga `114.mp3` ke area lampiran berkas biner.
4. Pastikan seluruh berkas selesai terunggah (indikator putaran/progress selesai), lalu klik **Update release**.

### Cara 2: Sinkronisasi Otomatis dari Sumber CDN Langsung ke GitHub Releases
Skrip ini mengunduh setiap surah satu per satu dan langsung mengunggahnya ke GitHub Releases:
```powershell
.\scripts\sync-to-release.ps1 -Tag "1.0.0"
```

### Cara 3: Unggah Otomatis dari Folder Lokal
Jika sudah memiliki folder audio lokal di komputer:
```powershell
.\scripts\upload-release.ps1 -AudioFolder "C:\Jalur\Ke\Folder\AudioMP3" -Tag "1.0.0"
```

---

## Lisensi & Atribusi
Rekaman murottal Al-Qur'an ini diperuntukkan secara bebas bagi umat Islam untuk kepentingan dakwah, pembelajaran, dan pengembangan aplikasi non-komersial.
