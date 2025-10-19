/*
=========================
Contoh query analisis
=========================
Script Purpose:
    Script ini berisi kumpulan query analisis (OLAP query)
    yang dijalankan pada Data Warehouse "dwh_apotek".
    Tujuan query adalah untuk menampilkan hasil analitik 
    dari tabel fakta dan tabel dimensi.

WARNING:
    Script ini menggunakan sintaks T-SQL (agar bisa dijalankan di Microsoft SQL Server), sehingga file tidak bisa berjalan kalau di-execute di MYSQL.
*/

use dwh_apotek;
GO

-- =========================================================
-- (1) TOTAL PENJUALAN PER TAHUN DAN NAMA OBAT
-- Tujuan: Menampilkan total omzet per tahun untuk setiap jenis obat.
--         Query ini membantu analisis tren penjualan tahunan per produk.
-- =========================================================
SELECT w.tahun, o.nama_obat, SUM(f.subtotal) AS total_penjualan
FROM fact_penjualan f
JOIN dim_waktu w ON w.sk_waktu = f.sk_waktu
JOIN dim_obat o  ON o.sk_obat  = f.sk_obat
GROUP BY w.tahun, o.nama_obat
ORDER BY w.tahun, total_penjualan DESC;



-- =========================================================
-- (2) TOTAL PENJUALAN PER TAHUN
-- Tujuan: Menampilkan akumulasi total penjualan per tahun
--         untuk mengetahui pertumbuhan penjualan dari waktu ke waktu.
-- =========================================================
SELECT w.tahun, SUM(f.subtotal) AS total_penjualan
FROM fact_penjualan f
JOIN dim_waktu w ON f.sk_waktu = w.sk_waktu
GROUP BY w.tahun
ORDER BY w.tahun;



-- =========================================================
-- (3) TOP 5 OBAT TERLARIS
-- Tujuan: Menampilkan 5 obat dengan jumlah penjualan terbanyak.
--         Query ini membantu menentukan produk unggulan.
-- =========================================================
SELECT TOP 5 o.nama_obat, SUM(f.jumlah) AS total_terjual
FROM fact_penjualan f
JOIN dim_obat o ON f.sk_obat = o.sk_obat
GROUP BY o.nama_obat
ORDER BY total_terjual DESC;



-- =========================================================
-- (4) TOP 5 PELANGGAN DENGAN TRANSAKSI TERBANYAK
-- Tujuan: Menampilkan pelanggan dengan jumlah transaksi tertinggi
--         dan total belanja mereka, untuk mendukung strategi loyalitas.
-- =========================================================
SELECT TOP 5 p.nama, COUNT(*) AS jumlah_transaksi, SUM(f.subtotal) AS total_belanja
FROM fact_penjualan f
JOIN dim_pelanggan p ON f.sk_pelanggan = p.sk_pelanggan
GROUP BY p.nama
ORDER BY jumlah_transaksi DESC;



-- =========================================================
-- (5) TOTAL PENJUALAN PER ADMIN/APOTEKER
-- Tujuan: Menampilkan kinerja admin/apoteker berdasarkan total penjualan
--         yang mereka tangani, sebagai dasar evaluasi performa.
-- =========================================================
SELECT a.nama_admin, SUM(f.subtotal) AS total_penjualan
FROM fact_penjualan f
JOIN dim_admin a ON f.sk_admin = a.sk_admin
GROUP BY a.nama_admin
ORDER BY total_penjualan DESC;