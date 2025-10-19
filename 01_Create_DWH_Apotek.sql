/*
=========================
Create data warehouse
=========================
Script Purpose:
    Script ini digunakan untuk membuat struktur awal Data Warehouse
    (DWH) pada database dwh_apotek.

    Membuat tabel dimensi dan fakta di dalam database dwh_apotek. Tabel-tabel yang dibuat:
    (1) dim_waktu       - Menyimpan data tanggal (time dimension)
    (2) dim_obat        - Menyimpan informasi obat (product dimension)
    (3) dim_pelanggan   - Menyimpan data pelanggan (customer dimension)
    (4) dim_admin       - Menyimpan data admin/apoteker (employee dimension)
    (5) fact_penjualan  - Menyimpan data transaksi penjualan obat

WARNING:
    Script ini menggunakan sintaks T-SQL (agar bisa dijalankan di Microsoft SQL Server), sehingga file tidak bisa berjalan kalau di-execute di MYSQL.
*/

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'dwh_apotek')
    CREATE DATABASE dwh_apotek;
GO

USE dwh_apotek;
GO

-- Tabel Dimensi
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
  stok INT,
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

-- Tabel Fakta
CREATE TABLE fact_penjualan (
  sk_fakta INT IDENTITY(1, 1) PRIMARY KEY,
  sk_waktu INT NOT NULL,
  sk_obat INT NOT NULL,
  sk_pelanggan INT,
  sk_admin INT,
  id_transaksi INT,                         -- natural key dari OLTP
  jumlah INT,
  subtotal DECIMAL(12,2),
  PRIMARY KEY (sk_waktu, sk_obat, sk_pelanggan, sk_admin),
  FOREIGN KEY (sk_waktu) REFERENCES dim_waktu(sk_waktu),
  FOREIGN KEY (sk_obat) REFERENCES dim_obat(sk_obat),
  FOREIGN KEY (sk_pelanggan) REFERENCES dim_pelanggan(sk_pelanggan),
  FOREIGN KEY (sk_admin) REFERENCES dim_admin(sk_admin)
);
GO


