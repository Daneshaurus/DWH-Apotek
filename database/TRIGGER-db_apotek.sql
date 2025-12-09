CREATE TRIGGER trg_log_update_obat
ON tb_obat
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tb_log_obat (ID_Obat, Waktu_Perubahan)
    SELECT
        i.ID_Obat,
        GETDATE()
    FROM inserted i
    JOIN deleted d ON i.ID_Obat = d.ID_Obat
    WHERE
        (ISNULL(i.ID_Kategori_Obat, -1)      <> ISNULL(d.ID_Kategori_Obat, -1)) OR
        (ISNULL(i.ID_Detail_Obat, -1)        <> ISNULL(d.ID_Detail_Obat, -1)) OR
        (ISNULL(i.ID_Supplier, -1)           <> ISNULL(d.ID_Supplier, -1)) OR
        (ISNULL(i.Nama_Obat, '')             <> ISNULL(d.Nama_Obat, '')) OR
        (ISNULL(i.Stok_Obat, -1)             <> ISNULL(d.Stok_Obat, -1)) OR
        (ISNULL(i.Harga_Jual, -1)            <> ISNULL(d.Harga_Jual, -1)) OR
        (ISNULL(i.Harga_Beli, -1)            <> ISNULL(d.Harga_Beli, -1)) OR
        (ISNULL(i.Bisa_Diproduksi, '')       <> ISNULL(d.Bisa_Diproduksi, ''));
END;
GO

--------------------------------------------------
-- 1. INSERT DATA CONTOH KE tb_obat
--------------------------------------------------

--------------------------------------------------
-- 2. CEK ISI TABEL SEBELUM UPDATE
--------------------------------------------------
SELECT * FROM tb_obat;
SELECT * FROM tb_log_obat;

--------------------------------------------------
-- 3. UPDATE UNTUK MEMICU TRIGGER (Ada Perubahan)
--------------------------------------------------
UPDATE tb_obat
SET Harga_Jual = Harga_Jual + 1000
WHERE ID_Obat = 1;       -- ubah harga Paracetamol

-- contoh alternatif UPDATE (jika ingin lanjut tes)
-- UPDATE tb_obat SET Nama_Obat = 'Paracetamol Forte' WHERE ID_Obat = 1;
-- UPDATE tb_obat SET Stok_Obat = Stok_Obat + 20 WHERE ID_Obat = 2;

--------------------------------------------------
-- 4. CEK HASIL TRIGGER PADA TABEL LOG
--------------------------------------------------
SELECT * FROM tb_log_obat ORDER BY ID_Log_Obat DESC;
