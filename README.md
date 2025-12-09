# 🏥 Data Warehouse Apotek

Repositori ini berisi implementasi lengkap **Data Warehouse (DWH) untuk sistem Apotek** menggunakan **Microsoft SQL Server (T-SQL)**.  
Proyek ini mencakup seluruh tahapan pembangunan DWH berdasarkan metodologi **Kimball Nine-Step**, mulai dari pembuatan struktur database, proses ETL, hingga analisis data berbasis *Star Schema*.

---

## 🧠 Tujuan Proyek

- Membangun model **Data Warehouse Apotek** yang mampu menyimpan data historis penjualan dengan struktur analitis.  
- Mengimplementasikan proses **ETL manual** antara sistem operasional dan DWH.  
- Menerapkan konsep **Star Schema** sebagai dasar untuk analisis multidimensi.  
- Menghasilkan laporan dan insight bisnis untuk pengambilan keputusan.

---

## ⚙️ Teknologi yang Digunakan

- 🧱 **Microsoft SQL Server (Developer Edition)**  
- 💬 **Transact-SQL (T-SQL)**  
- 🧰 **SQL Server Management Studio (SSMS)**  
- 🔄 *(Opsional)* **SQL Server Migration Assistant (SSMA)** untuk migrasi dari MySQL ke SQL Server  

---

## 📊 Hasil Implementasi

Setelah seluruh skrip dijalankan:

- Database `dwh_apotek` berhasil dibuat dengan lima tabel utama.  
- Sebanyak ±95 baris data transaksi berhasil dimuat ke tabel fakta `fact_penjualan`.  
- Struktur DWH membentuk **Star Schema** yang siap digunakan untuk analisis dan visualisasi.  
- Query analisis menghasilkan insight seperti:
  - 📈 Total penjualan per tahun  
  - 💊 5 obat paling laris  
  - 🧍‍♂️ 5 pelanggan dengan transaksi terbanyak  
  - 👨‍⚕️ Total omzet per admin/apoteker  
