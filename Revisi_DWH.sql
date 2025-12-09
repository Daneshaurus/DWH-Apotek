/*
=========================
Create Data Warehouse (Revisi)
=========================
Script Purpose:
    Script ini digunakan untuk membuat ulang struktur Data Warehouse
    (DWH) pada database dwh_apotek dengan perubahan:
    (1) Mengganti fact_penjualan menjadi fact_transaksi (untuk menampung Penjualan & Pembelian).
    (2) Menambahkan tabel dimensi dim_supplier.
    (3) Mempertahankan dan menyesuaikan tabel dimensi yang sudah ada (dim_waktu, dim_obat, dim_pelanggan, dim_admin).

WARNING:
    Script ini menggunakan sintaks T-SQL (Microsoft SQL Server).
*/

-- Pastikan database ada atau buat baru
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'dwh_apotek')
    CREATE DATABASE dwh_apotek;
GO

USE dwh_apotek;
GO

-- Hapus tabel fakta lama (jika ada) untuk memfasilitasi perubahan
IF OBJECT_ID('fact_penjualan', 'U') IS NOT NULL
    DROP TABLE fact_penjualan;
GO

-- Hapus tabel fakta baru (jika ada versi sebelumnya)
IF OBJECT_ID('fact_transaksi', 'U') IS NOT NULL
    BEGIN
        -- Hapus Foreign Keys yang mungkin merujuk ke tabel dimensi
        ALTER TABLE fact_transaksi DROP CONSTRAINT FK_Transaksi_Waktu;
        ALTER TABLE fact_transaksi DROP CONSTRAINT FK_Transaksi_Obat;
        ALTER TABLE fact_transaksi DROP CONSTRAINT FK_Transaksi_Pelanggan;
        ALTER TABLE fact_transaksi DROP CONSTRAINT FK_Transaksi_Admin;
        ALTER TABLE fact_transaksi DROP CONSTRAINT FK_Transaksi_Supplier;
        DROP TABLE fact_transaksi;
    END
GO

-- Hapus tabel dimensi lama (jika ada) yang akan dibuat ulang atau diganti
IF OBJECT_ID('dim_supplier', 'U') IS NOT NULL
    DROP TABLE dim_supplier;
IF OBJECT_ID('dim_admin', 'U') IS NOT NULL
    DROP TABLE dim_admin;
IF OBJECT_ID('dim_pelanggan', 'U') IS NOT NULL
    DROP TABLE dim_pelanggan;
IF OBJECT_ID('dim_obat', 'U') IS NOT NULL
    DROP TABLE dim_obat;
IF OBJECT_ID('dim_waktu', 'U') IS NOT NULL
    DROP TABLE dim_waktu;
GO

--- Pembuatan Tabel Dimensi yang Disesuaikan/Baru ---

CREATE TABLE dim_waktu (
  sk_waktu INT IDENTITY(1,1) PRIMARY KEY,
  tanggal DATE NOT NULL UNIQUE,
  hari TINYINT,
  bulan TINYINT,
  nama_bulan VARCHAR(15),
  kuartal TINYINT,
  tahun INT
);

CREATE TABLE dim_obat (
  sk_obat INT IDENTITY(1,1) PRIMARY KEY,
  nk_id_obat INT NOT NULL,
  nama_obat VARCHAR(100),
  harga_jual DECIMAL(12,2),
  harga_beli DECIMAL(12,2),
  stok INT, -- Menyimpan stok terakhir yang diload
  mulai_berlaku DATE,
  berakhir DATE,
  is_aktif BIT DEFAULT 1
);

CREATE TABLE dim_pelanggan (
  sk_pelanggan INT IDENTITY(1,1) PRIMARY KEY,
  nk_id_pelanggan INT NOT NULL,
  nama VARCHAR(100),
  jenis_kelamin VARCHAR(10),
  alamat VARCHAR(MAX)
);

CREATE TABLE dim_admin (
  sk_admin INT IDENTITY(1,1) PRIMARY KEY,
  nk_id_admin INT NOT NULL,
  nama_admin VARCHAR(100)
);

-- Tabel Dimensi Baru: dim_supplier
CREATE TABLE dim_supplier (
  sk_supplier INT IDENTITY(1,1) PRIMARY KEY,
  nk_id_supplier INT NOT NULL, -- Natural Key dari tb_supplier (ID_Supplier)
  nama_supplier VARCHAR(100),
  alamat VARCHAR(MAX),
  no_telp VARCHAR(15)
);

--- Pembuatan Tabel Fakta yang Direvisi: fact_transaksi ---

CREATE TABLE fact_transaksi (
  sk_fakta INT IDENTITY(1, 1) PRIMARY KEY,
  sk_waktu INT NOT NULL,
  sk_obat INT NOT NULL,
  sk_pelanggan INT NULL, -- NULLable: Untuk transaksi Pembelian (tidak ada pelanggan)
  sk_admin INT NOT NULL,
  sk_supplier INT NULL, -- NULLable: Untuk transaksi Penjualan (tidak ada supplier)
  
  -- Natural Keys untuk referensi OLTP
  nk_id_penjualan INT NULL,   -- ID_Transaksi dari tb_transaksi (untuk penjualan)
  nk_id_pembelian INT NULL,   -- ID_Pemesanan dari tb_pemesanan_supplier (untuk pembelian)
  
  -- Tipe Transaksi: Penjualan atau Pembelian
  tipe_transaksi VARCHAR(10) NOT NULL, -- 'Penjualan' atau 'Pembelian'
  
  -- Pengukuran (Measures)
  jumlah INT NOT NULL,
  
  -- Ukuran yang dihitung (Penjualan: subtotal_penjualan, Pembelian: subtotal_pembelian)
  subtotal DECIMAL(12,2),
  
  -- Harga historis (untuk analisis profit margin, dll.)
  harga_unit DECIMAL(12,2) -- Harga Jual untuk Penjualan, Harga Beli untuk Pembelian
);
GO

-- Menambahkan Foreign Key Constraints
ALTER TABLE fact_transaksi ADD CONSTRAINT FK_Transaksi_Waktu FOREIGN KEY (sk_waktu) REFERENCES dim_waktu(sk_waktu);
ALTER TABLE fact_transaksi ADD CONSTRAINT FK_Transaksi_Obat FOREIGN KEY (sk_obat) REFERENCES dim_obat(sk_obat);
ALTER TABLE fact_transaksi ADD CONSTRAINT FK_Transaksi_Pelanggan FOREIGN KEY (sk_pelanggan) REFERENCES dim_pelanggan(sk_pelanggan);
ALTER TABLE fact_transaksi ADD CONSTRAINT FK_Transaksi_Admin FOREIGN KEY (sk_admin) REFERENCES dim_admin(sk_admin);
ALTER TABLE fact_transaksi ADD CONSTRAINT FK_Transaksi_Supplier FOREIGN KEY (sk_supplier) REFERENCES dim_supplier(sk_supplier);
GO