/*
=========================
ETL dari db_apotek ke DWH
=========================
Script Purpose:
    Script ini digunakan untuk melakukan proses ETL (Extract, Transform, Load) 
    dari database OLTP "db_apotek" ke dalam database Data Warehouse "dwh_apotek".
    Data akan dimasukkan ke dalam tabel dimensi dan fakta sesuai struktur Star Schema.

WARNING:
    
    !!! Import db_apotek dulu dari versi MYSQL ke T-SQL. Langsung import aja pakai file yang ada di repo.

    Script ini menggunakan sintaks T-SQL (agar bisa dijalankan di Microsoft SQL Server), sehingga file tidak bisa berjalan kalau di-execute di MYSQL.
*/

USE dwh_apotek;
GO

-- Generate data waktu (dimensi waktu)
;WITH d AS (
    SELECT CAST('2020-01-01' AS DATE) AS tanggal
    UNION ALL
    SELECT DATEADD(DAY, 1, tanggal)
    FROM d
    WHERE tanggal < '2030-12-31'
)
INSERT INTO dim_waktu (tanggal, hari, bulan, nama_bulan, kuartal, tahun)
SELECT
    tanggal,
    DATEPART(DAY, tanggal),
    DATEPART(MONTH, tanggal),
    DATENAME(MONTH, tanggal),
    DATEPART(QUARTER, tanggal),
    DATEPART(YEAR, tanggal)
FROM d
OPTION (MAXRECURSION 0);

-- Dimensi Admin
INSERT INTO dim_admin (nk_id_admin, nama_admin)
SELECT ID_Admin, Nama_Admin
FROM db_apotek.db_apotek.tb_admin

-- Dimensi Pelanggan
INSERT INTO dim_pelanggan (nk_id_pelanggan, nama, jenis_kelamin, alamat)
SELECT ID_Pelanggan, Nama, Jenis_Kelamin, Alamat
FROM db_apotek.db_apotek.tb_pelanggan;

-- Dimensi Obat
INSERT INTO dim_obat (nk_id_obat, nama_obat, harga_jual, harga_beli, stok, mulai_berlaku)
SELECT ID_Obat, Nama_Obat, Harga_Jual, Harga_Beli, Stok_Obat, GETDATE()
FROM db_apotek.db_apotek.tb_obat;

-- Fakta Penjualan
INSERT INTO fact_penjualan (sk_waktu, sk_obat, sk_pelanggan, sk_admin, jumlah, subtotal)
SELECT
    w.sk_waktu,
    o.sk_obat,
    p.sk_pelanggan,
    a.sk_admin,
    d.Jumlah,
    d.Subtotal_Harga
FROM db_apotek.db_apotek.tb_transaksi t
JOIN db_apotek.db_apotek.tb_detail_transaksi d ON t.ID_Transaksi = d.ID_Transaksi
JOIN dim_waktu w ON w.tanggal = t.Tanggal
JOIN dim_obat o ON o.nk_id_obat = d.ID_Obat
JOIN dim_pelanggan p ON p.nk_id_pelanggan = t.ID_Pelanggan
JOIN dim_admin a ON a.nk_id_admin = t.ID_Admin;

-- Validasi isi tabel
SELECT COUNT(*) AS jumlah_fakta FROM fact_penjualan;
SELECT COUNT(*) AS jumlah_admin FROM dim_admin;
SELECT COUNT(*) AS jumlah_pelanggan FROM dim_pelanggan;
SELECT COUNT(*) AS jumlah_obat FROM dim_obat;
SELECT COUNT(*) AS jumlah_waktu FROM dim_waktu;


