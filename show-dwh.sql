-- Dimensi Admin
SELECT TOP (1000) [sk_admin]
      ,[nk_id_admin]
      ,[nama_admin]
  FROM [dwh_apotek].[dbo].[dim_admin]

-- Dimensi Obat
SELECT TOP (1000) [sk_obat]
      ,[nk_id_obat]
      ,[nama_obat]
      ,[harga_jual]
      ,[harga_beli]
      ,[stok]
      ,[mulai_berlaku]
      ,[berakhir]
      ,[is_aktif]
  FROM [dwh_apotek].[dbo].[dim_obat]

-- Dimensi Pelanggan
SELECT TOP (1000) [sk_pelanggan]
      ,[nk_id_pelanggan]
      ,[nama]
      ,[jenis_kelamin]
      ,[alamat]
      ,[no_telp]
  FROM [dwh_apotek].[dbo].[dim_pelanggan]

-- Dimensi Supplier
SELECT TOP (1000) [sk_supplier]
      ,[nk_id_supplier]
      ,[nama_supplier]
      ,[alamat]
      ,[no_telp]
  FROM [dwh_apotek].[dbo].[dim_supplier]

-- Dimensi Waktu
-- Dim waktu = semua tanggal dalam rentang waktu DWH
-- Ada 4018, Karena 11 tahun × 365 hari = 4015–4018 baris
-- 2020-01-01 - 2030-12-31
SELECT TOP (5000) [sk_waktu]
      ,[tanggal]
      ,[hari]
      ,[bulan]
      ,[nama_bulan]
      ,[kuartal]
      ,[tahun]
  FROM [dwh_apotek].[dbo].[dim_waktu]

-- Fact Transaksi
SELECT TOP (1000) [sk_fakta]
      ,[sk_waktu]
      ,[sk_obat]
      ,[sk_pelanggan]
      ,[sk_admin]
      ,[sk_supplier]
      ,[nk_id_penjualan]
      ,[nk_id_pembelian]
      ,[tipe_transaksi]
      ,[jumlah]
      ,[subtotal]
      ,[harga_unit]
  FROM [dwh_apotek].[dbo].[fact_transaksi]
