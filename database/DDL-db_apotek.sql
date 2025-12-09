-- =======================
--    CREATE DATABASE
-- =======================
CREATE DATABASE db_apotek;
GO
USE db_apotek;
GO

-- =======================
--       TABLES
-- =======================

CREATE TABLE tb_admin (
    ID_Admin INT IDENTITY(1,1) PRIMARY KEY,
    Nama_Admin NVARCHAR(50),
    No_Telp NVARCHAR(15),
    Alamat_Admin NVARCHAR(MAX),
    Registrasi DATE,
    Jenis_Kelamin NVARCHAR(1),
    Email_Admin NVARCHAR(100)
);

CREATE TABLE tb_supplier (
    ID_Supplier INT IDENTITY(1,1) PRIMARY KEY,
    Nama_Supplier NVARCHAR(50),
    Alamat NVARCHAR(MAX),
    No_Telp NVARCHAR(15)
);

CREATE TABLE tb_kategori_obat (
    ID_Kategori_Obat INT IDENTITY(1,1) PRIMARY KEY,
    Nama_Kategori NVARCHAR(50),
    Deskripsi_Kategori NVARCHAR(MAX)
);

CREATE TABLE tb_detail_obat (
    ID_Detail_Obat INT IDENTITY(1,1) PRIMARY KEY,
    Komposisi_Obat NVARCHAR(MAX),
    Dosis NVARCHAR(50),
    Tanggal DATE
);

CREATE TABLE tb_obat (
    ID_Obat INT IDENTITY(1,1) PRIMARY KEY,
    ID_Kategori_Obat INT,
    ID_Detail_Obat INT,
    ID_Supplier INT,
    Nama_Obat NVARCHAR(50),
    Stok_Obat INT,
    Harga_Jual DECIMAL(12,2),
    Harga_Beli DECIMAL(12,2),
    Bisa_Diproduksi NVARCHAR(5)
);

CREATE TABLE tb_pelanggan (
    ID_Pelanggan INT IDENTITY(1,1) PRIMARY KEY,
    Nama NVARCHAR(50),
    Jenis_Kelamin NVARCHAR(1),
    No_HP NVARCHAR(15),
    Alamat NVARCHAR(MAX)
);

CREATE TABLE tb_transaksi (
    ID_Transaksi INT IDENTITY(1,1) PRIMARY KEY,
    ID_Admin INT,
    ID_Pelanggan INT,
    No_Registrasi NVARCHAR(20),
    Tanggal DATE,
    Total_Harga DECIMAL(12,2),
    Jenis_Pembayaran NVARCHAR(20)
);

CREATE TABLE tb_detail_transaksi (
    ID_Detail_Transaksi INT IDENTITY(1,1) PRIMARY KEY,
    ID_Transaksi INT,
    ID_Obat INT,
    Jumlah INT,
    Subtotal_Harga DECIMAL(12,2)
);

CREATE TABLE tb_dokter (
    ID_Dokter INT IDENTITY(1,1) PRIMARY KEY,
    Nama_Dokter NVARCHAR(50),
    Jabatan NVARCHAR(30),
    Jenis_Kelamin NVARCHAR(1),
    No_Telp NVARCHAR(15),
    Alamat NVARCHAR(MAX)
);

CREATE TABLE tb_resep_obat (
    ID_Resep INT IDENTITY(1,1) PRIMARY KEY,
    ID_Dokter INT,
    ID_Detail_Transaksi INT,
    Tgl_Pembuatan DATE,
    Deskripsi_Resep NVARCHAR(MAX)
);


CREATE TABLE tb_detail_resep (
    ID_Detail_Resep INT IDENTITY(1,1) PRIMARY KEY,
    ID_Resep        INT,
    ID_Obat         INT,
    Harga_Satuan    DECIMAL(12, 2),
    Jumlah          INT
);

CREATE TABLE tb_pemesanan_supplier (
    ID_Pemesanan INT IDENTITY(1,1) PRIMARY KEY,
    ID_Supplier INT,
    Total_Harga DECIMAL(12,2),
    Tanggal_Pemesanan DATE
);

CREATE TABLE tb_detail_pemesanan (
    ID_Detail_Pemesanan INT IDENTITY(1,1) PRIMARY KEY,
    ID_Pemesanan INT,
    ID_Obat INT,
    Tanggal_Pemesanan DATE,
    Jumlah_Pesanan INT
);

CREATE TABLE tb_log_obat (
    ID_Log_Obat INT IDENTITY(1,1) PRIMARY KEY,
    ID_Obat INT,
    Waktu_Perubahan DATETIME DEFAULT GETDATE(),
);

-- =======================
--     FOREIGN KEYS
-- =======================

ALTER TABLE tb_obat
    ADD FOREIGN KEY (ID_Kategori_Obat) REFERENCES tb_kategori_obat(ID_Kategori_Obat),
        FOREIGN KEY (ID_Detail_Obat) REFERENCES tb_detail_obat(ID_Detail_Obat),
        FOREIGN KEY (ID_Supplier) REFERENCES tb_supplier(ID_Supplier);

ALTER TABLE tb_transaksi
    ADD FOREIGN KEY (ID_Admin) REFERENCES tb_admin(ID_Admin),
        FOREIGN KEY (ID_Pelanggan) REFERENCES tb_pelanggan(ID_Pelanggan);

ALTER TABLE tb_detail_transaksi
    ADD FOREIGN KEY (ID_Transaksi) REFERENCES tb_transaksi(ID_Transaksi),
        FOREIGN KEY (ID_Obat) REFERENCES tb_obat(ID_Obat);

ALTER TABLE tb_resep_obat
    ADD FOREIGN KEY (ID_Dokter) REFERENCES tb_dokter(ID_Dokter),
        FOREIGN KEY (ID_Detail_Transaksi) REFERENCES tb_detail_transaksi(ID_Detail_Transaksi);

ALTER TABLE tb_detail_resep
    ADD FOREIGN KEY (ID_Resep) REFERENCES tb_resep_obat(ID_Resep),
        FOREIGN KEY (ID_Obat) REFERENCES tb_obat(ID_Obat);

ALTER TABLE tb_pemesanan_supplier
    ADD FOREIGN KEY (ID_Supplier) REFERENCES tb_supplier(ID_Supplier);

ALTER TABLE tb_detail_pemesanan
    ADD FOREIGN KEY (ID_Pemesanan) REFERENCES tb_pemesanan_supplier(ID_Pemesanan),
        FOREIGN KEY (ID_Obat) REFERENCES tb_obat(ID_Obat);

ALTER TABLE tb_log_obat
    ADD FOREIGN KEY (ID_Obat) REFERENCES tb_obat(ID_Obat),
        FOREIGN KEY (ID_Admin) REFERENCES tb_admin(ID_Admin);
