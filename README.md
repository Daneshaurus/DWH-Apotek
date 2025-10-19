# 🏥 Data Warehouse Apotek

Repositori ini berisi implementasi lengkap **Data Warehouse (DWH) untuk sistem Apotek** menggunakan **Microsoft SQL Server (T-SQL)**.  
Proyek ini mencakup seluruh tahapan pembangunan DWH berdasarkan metodologi **Kimball Nine-Step**, mulai dari pembuatan struktur database, proses ETL, hingga analisis data berbasis *Star Schema*.

---

## 📂 Struktur File

| No | File | Deskripsi |
|----|------|------------|
| 1️⃣ | **`01_Create_DWH_Apotek.sql`** | Membuat struktur database **Data Warehouse** (`dwh_apotek`), termasuk tabel dimensi (`dim_waktu`, `dim_obat`, `dim_pelanggan`, `dim_admin`) dan tabel fakta (`fact_penjualan`) dengan relasi *Star Schema*. |
| 2️⃣ | **`02_Insert_Dataset_DWH_Apotek.sql`** | Melakukan proses **ETL (Extract, Transform, Load)** untuk memindahkan data dari database operasional `db_apotek` ke `dwh_apotek`. Termasuk pembangkitan dimensi waktu dan pengisian data ke tabel fakta. |
| 3️⃣ | **`03_Query_Analisis_DWH_Apotek.sql`** | Berisi kumpulan **query analisis OLAP** untuk menghasilkan laporan seperti total penjualan per tahun, obat terlaris, pelanggan aktif, dan performa admin/apoteker. |
| 4️⃣ | **`db_apotek.sql`** | Database **OLTP (sumber data)** yang merepresentasikan sistem operasional apotek, terdiri dari tabel `tb_admin`, `tb_pelanggan`, `tb_obat`, `tb_transaksi`, dan `tb_detail_transaksi`. |

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
