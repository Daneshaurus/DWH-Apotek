/* ============================================================
   0. CREATE STAGING TABLES
   ============================================================ */

-- USE Master;
-- DROP DATABASE staging_apotek;
CREATE DATABASE staging_apotek;
USE staging_apotek;
GO

IF OBJECT_ID('stg_admin') IS NOT NULL DROP TABLE stg_admin;
CREATE TABLE stg_admin (
    ID_Admin INT,
    Nama_Admin NVARCHAR(50),
    No_Telp NVARCHAR(15),
    Alamat_Admin NVARCHAR(MAX),
    Registrasi DATE,
    Jenis_Kelamin NVARCHAR(1),
    Email_Admin NVARCHAR(100)
);

IF OBJECT_ID('stg_obat') IS NOT NULL DROP TABLE stg_obat;
CREATE TABLE stg_obat (
    ID_Obat INT,
    ID_Kategori_Obat INT,
    ID_Detail_Obat INT,
    ID_Supplier INT,
    Nama_Obat NVARCHAR(50),
    Stok_Obat INT,
    Harga_Jual DECIMAL(12,2),
    Harga_Beli DECIMAL(12,2),
    Bisa_Diproduksi NVARCHAR(5),
);

IF OBJECT_ID('stg_supplier') IS NOT NULL DROP TABLE stg_supplier;
CREATE TABLE stg_supplier (
    ID_Supplier INT,
    Nama_Supplier NVARCHAR(100),
    Alamat NVARCHAR(MAX),
    No_HP NVARCHAR(20)
);


IF OBJECT_ID('stg_pelanggan') IS NOT NULL DROP TABLE stg_pelanggan;
CREATE TABLE stg_pelanggan (
    ID_Pelanggan INT,
    Nama NVARCHAR(50),
    Jenis_Kelamin NVARCHAR(1),
    No_HP NVARCHAR(15),
    Alamat NVARCHAR(MAX)
);

IF OBJECT_ID('stg_transaksi') IS NOT NULL DROP TABLE stg_transaksi;
CREATE TABLE stg_transaksi (
    ID_Transaksi INT,
    ID_Admin INT,
    ID_Pelanggan INT,
    No_Transaksi NVARCHAR(20),
    Tanggal_Transaksi DATE,
    Total_Harga DECIMAL(12,2),
    Metode_Pembayaran NVARCHAR(20)
);

IF OBJECT_ID('stg_detail_transaksi') IS NOT NULL DROP TABLE stg_detail_transaksi;
CREATE TABLE stg_detail_transaksi (
    ID_Detail_Transaksi INT,
    ID_Transaksi INT,
    ID_Obat INT,
    Jumlah INT,
    Subtotal_Harga DECIMAL(12,2)
);

/* ============================================================
   1. EXTRACT (FROM db_apotek)
   ============================================================ */

TRUNCATE TABLE stg_admin;
INSERT INTO stg_admin
SELECT
    ID_Admin,
    Nama_Admin,
    No_Telp,
    Alamat_Admin,
    Registrasi,
    Jenis_Kelamin,
    Email_Admin
FROM db_apotek.dbo.tb_admin;

TRUNCATE TABLE stg_obat;
INSERT INTO stg_obat SELECT * FROM db_apotek.dbo.tb_obat;

TRUNCATE TABLE stg_pelanggan;
INSERT INTO stg_pelanggan SELECT * FROM db_apotek.dbo.tb_pelanggan;

TRUNCATE TABLE stg_transaksi;
INSERT INTO stg_transaksi SELECT * FROM db_apotek.dbo.tb_transaksi;

TRUNCATE TABLE stg_detail_transaksi;
INSERT INTO stg_detail_transaksi SELECT * FROM db_apotek.dbo.tb_detail_transaksi;

TRUNCATE TABLE stg_supplier;
INSERT INTO stg_supplier SELECT * FROM db_apotek.dbo.tb_supplier;


/* ============================================================
   2. TRANSFORM + CLEANSING
   ============================================================ */

---------------------------------------------------------------
-- 2.1 REMOVE DUPLICATES (BERDASARKAN PRIMARY KEY LOGIS)
---------------------------------------------------------------

;WITH c_admin AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID_Admin ORDER BY ID_Admin) AS rn
    FROM stg_admin 
)
DELETE FROM c_admin WHERE rn > 1;

;WITH c_obat AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID_Obat ORDER BY ID_Obat) AS rn
    FROM stg_obat
)
DELETE FROM c_obat WHERE rn > 1;

;WITH c_supplier AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID_supplier ORDER BY ID_supplier) AS rn
    FROM stg_supplier
)
DELETE FROM c_supplier WHERE rn > 1;

;WITH c_pelanggan AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID_Pelanggan ORDER BY ID_Pelanggan) AS rn
    FROM stg_pelanggan
)
DELETE FROM c_pelanggan WHERE rn > 1;

;WITH c_trx AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID_Transaksi ORDER BY ID_Transaksi) AS rn
    FROM stg_transaksi
)
DELETE FROM c_trx WHERE rn > 1;

;WITH c_det_trx AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID_Detail_Transaksi ORDER BY ID_Detail_Transaksi) AS rn
    FROM stg_detail_transaksi
)
DELETE FROM c_det_trx WHERE rn > 1;

---------------------------------------------------------------
-- 2.2 NULL HANDLING (HAPUS BARIS YANG WAJIBNYA TIDAK BOLEH NULL)
---------------------------------------------------------------

-- buang admin tanpa nama
DELETE FROM staging_apotek.dbo.stg_admin
WHERE Nama_Admin IS NULL OR LTRIM(RTRIM(Nama_Admin)) = '';

-- Obat: nama, harga, stok wajib terisi
DELETE FROM stg_obat
WHERE Nama_Obat IS NULL
   OR Harga_Jual IS NULL
   OR Harga_Beli IS NULL
   OR Stok_Obat IS NULL;

-- supplier: minimal nama ada
DELETE FROM stg_supplier
WHERE Nama_supplier IS NULL;

-- Pelanggan: nama wajib, jenis kelamin boleh null tapi idealnya ada
DELETE FROM stg_pelanggan
WHERE Nama IS NULL;

-- Transaksi: relasi, tanggal, total wajib
DELETE FROM stg_transaksi
WHERE ID_Pelanggan IS NULL
   OR Tanggal_Transaksi IS NULL
   OR Total_Harga IS NULL;

-- Detail transaksi: transaksi, obat, jumlah, subtotal wajib
DELETE FROM stg_detail_transaksi
WHERE ID_Transaksi IS NULL
   OR ID_Obat IS NULL
   OR Jumlah IS NULL
   OR Subtotal_Harga IS NULL;

---------------------------------------------------------------
-- 2.3 STANDARDISASI TANGGAL (FORMAT YYYY-MM-DD VIA DATE)
---------------------------------------------------------------

-- Walaupun kolom sudah DATE, TRY_CONVERT memastikan konsisten
UPDATE stg_transaksi
SET Tanggal_Transaksi = TRY_CONVERT(DATE, Tanggal_Transaksi)
WHERE Tanggal_Transaksi IS NOT NULL;

-- Hapus jika ada tanggal invalid (gagal dikonversi)
DELETE FROM stg_transaksi
WHERE Tanggal_Transaksi IS NULL;

---------------------------------------------------------------
-- 2.4 VALIDASI ANGKA & OUTLIER SEDERHANA
---------------------------------------------------------------

-- Obat: stok tidak boleh negatif, harga > 0
DELETE FROM stg_obat
WHERE Stok_Obat < 0
   OR Harga_Jual <= 0
   OR Harga_Beli <= 0;

-- Transaksi: total harga > 0
DELETE FROM stg_transaksi
WHERE Total_Harga <= 0;

-- Detail transaksi: jumlah > 0, subtotal > 0
DELETE FROM stg_detail_transaksi
WHERE Jumlah <= 0
   OR Subtotal_Harga <= 0;

---------------------------------------------------------------
-- 2.5 NORMALISASI TEKS (NAMA JADI TITLE-CASE SEDERHANA)
---------------------------------------------------------------

-- normalisasi nama title-case
UPDATE staging_apotek.dbo.stg_admin
SET Nama_Admin = UPPER(LEFT(Nama_Admin, 1)) 
                  + LOWER(SUBSTRING(Nama_Admin, 2, LEN(Nama_Admin)));

-- Nama obat: huruf pertama kapital, sisanya lower
UPDATE stg_obat
SET Nama_Obat =
    UPPER(LEFT(Nama_Obat, 1)) +
    LOWER(SUBSTRING(Nama_Obat, 2, LEN(Nama_Obat)));

-- Nama supplier
UPDATE stg_supplier
SET Nama_supplier =
    UPPER(LEFT(Nama_supplier, 1)) +
    LOWER(SUBSTRING(Nama_supplier, 2, LEN(Nama_supplier)));

-- Nama pelanggan
UPDATE stg_pelanggan
SET Nama =
    UPPER(LEFT(Nama, 1)) +
    LOWER(SUBSTRING(Nama, 2, LEN(Nama)));

---------------------------------------------------------------
-- 2.6 UNIVERSAL PHONE CLEANSING (supports international format)
---------------------------------------------------------------

/*
CORE RULES:
1. Remove noise characters: space, dash, dot, parentheses
2. Allow only digits and leading "+"
3. If "+" exists but not at first char = invalid
4. Length must be 7–20 (universal reasonable range)
*/

-------------------------
-- CLEANING FUNCTION
-------------------------

-- Pelanggan
UPDATE stg_pelanggan
SET No_HP =
    -- Step 1: remove noise characters
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(No_HP, ' ', ''), '-', ''), '.', ''), '(', ''), ')', '');

-- supplier
UPDATE stg_supplier
SET No_HP =
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(No_HP, ' ', ''), '-', ''), '.', ''), '(', ''), ')', '');


-------------------------
-- VALIDATION RULES
-------------------------

-- 1) Remove rows with invalid "+"
-- "+" must appear ONLY at the beginning
DELETE FROM stg_pelanggan
WHERE No_HP LIKE '%+%' AND LEFT(No_HP, 1) <> '+';

DELETE FROM stg_supplier
WHERE No_HP LIKE '%+%' AND LEFT(No_HP, 1) <> '+';


-- 2) Remove rows with invalid characters (should be only digits or leading "+")
DELETE FROM stg_pelanggan
WHERE No_HP LIKE '%[^0-9+]%';

DELETE FROM stg_supplier
WHERE No_HP LIKE '%[^0-9+]%';


-- 3) Length validation (international safe)
DELETE FROM stg_pelanggan
WHERE LEN(No_HP) < 7 OR LEN(No_HP) > 20;

DELETE FROM stg_supplier
WHERE LEN(No_HP) < 7 OR LEN(No_HP) > 20;


-- 4) Remove rows with multiple "+" (invalid international format)
DELETE FROM stg_pelanggan
WHERE LEN(No_HP) - LEN(REPLACE(No_HP, '+', '')) > 1;

DELETE FROM stg_supplier
WHERE LEN(No_HP) - LEN(REPLACE(No_HP, '+', '')) > 1;

/* ============================================================
   3. LOAD DIMENSIONS
   ============================================================ */

TRUNCATE TABLE dwh_apotek.dbo.dim_obat;
TRUNCATE TABLE dwh_apotek.dbo.dim_admin;
TRUNCATE TABLE dwh_apotek.dbo.dim_pelanggan;
TRUNCATE TABLE dwh_apotek.dbo.dim_supplier;
TRUNCATE TABLE dwh_apotek.dbo.dim_waktu;   -- optional

-- 1. Dimensi Admin
INSERT INTO dwh_apotek.dbo.dim_admin (
    nk_id_admin,
    nama_admin
)
SELECT
    ID_Admin,
    Nama_Admin
FROM staging_apotek.dbo.stg_admin;

-- 2. Dimensi Pelanggan
-- !!! GAADA NOMOR TELP
INSERT INTO dwh_apotek.dbo.dim_pelanggan (
    nk_id_pelanggan,
    nama,
    jenis_kelamin,
    alamat,
    no_telp
)
SELECT
    ID_Pelanggan,
    Nama,
    Jenis_Kelamin,
    Alamat,
    No_HP
FROM staging_apotek.dbo.stg_pelanggan;

-- 3. Dimensi Supplier
INSERT INTO dwh_apotek.dbo.dim_supplier (
    nk_id_supplier,
    nama_supplier,
    alamat,
    no_telp
)
SELECT
    ID_Supplier,        -- di OLTP produsen = supplier
    Nama_Supplier,
    Alamat,
    No_HP
FROM staging_apotek.dbo.stg_supplier;

-- 4. Dimensi Obat
INSERT INTO dwh_apotek.dbo.dim_obat (
    nk_id_obat,
    nama_obat,
    harga_jual,
    harga_beli,
    stok,
    mulai_berlaku,
    berakhir,
    is_aktif
)
SELECT
    ID_Obat,
    Nama_Obat,
    Harga_Jual,
    Harga_Beli,
    Stok_Obat,
    GETDATE(),
    '9999-12-31',
    1
FROM staging_apotek.dbo.stg_obat;

-- 5. Dimensi Waktu
WITH d AS (
    SELECT CAST('2020-01-01' AS DATE) AS tanggal
    UNION ALL
    SELECT DATEADD(DAY, 1, tanggal)
    FROM d
    WHERE tanggal < '2030-12-31'
)
INSERT INTO dwh_apotek.dbo.dim_waktu (
    tanggal,
    hari,
    bulan,
    nama_bulan,
    kuartal,
    tahun
)
SELECT
    tanggal,
    DATEPART(WEEKDAY, tanggal),
    DATEPART(MONTH, tanggal),
    DATENAME(MONTH, tanggal),
    DATEPART(QUARTER, tanggal),
    DATEPART(YEAR, tanggal)
FROM d
OPTION (MAXRECURSION 0);

/* ============================================================
   4. LOAD FACT TABLES
   ============================================================ */

INSERT INTO dwh_apotek.dbo.fact_transaksi (
    sk_waktu,
    sk_obat,
    sk_pelanggan,
    sk_admin,
    sk_supplier,
    nk_id_penjualan,
    nk_id_pembelian,
    tipe_transaksi,
    jumlah,
    subtotal
)
SELECT
    w.sk_waktu,
    o.sk_obat,
    p.sk_pelanggan,
    a.sk_admin,
    s.sk_supplier,
    t.ID_Transaksi,          -- nk_id_penjualan
    NULL,                    -- nk_id_pembelian (jika tidak ada di OLTP)
    'Penjualan',             -- tipe transaksi (bisa disesuaikan)
    dt.Jumlah,
    dt.Subtotal_Harga
FROM staging_apotek.dbo.stg_detail_transaksi dt
JOIN staging_apotek.dbo.stg_transaksi t
    ON t.ID_Transaksi = dt.ID_Transaksi
JOIN dwh_apotek.dbo.dim_obat o
    ON o.nk_id_obat = dt.ID_Obat
JOIN dwh_apotek.dbo.dim_pelanggan p
    ON p.nk_id_pelanggan = t.ID_Pelanggan
JOIN dwh_apotek.dbo.dim_admin a
    ON a.nk_id_admin = t.ID_Admin
JOIN dwh_apotek.dbo.dim_supplier s
    ON s.nk_id_supplier = o.nk_id_obat  -- jika OLTP punya supplier_id, sesuaikan
JOIN dwh_apotek.dbo.dim_waktu w
    ON w.tanggal = t.Tanggal_Transaksi;
