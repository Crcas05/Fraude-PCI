CREATE TRIGGER trg_AutoHistorialAlerta
ON dbo.AlertasFraude
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.HistorialRevision
        (IdAlerta, Analista, Comentario, Resultado, FechaRevision)
    SELECT
        i.IdAlerta,
        'Pendiente',                -- Analista por defecto
        'Revisión pendiente',        -- Comentario inicial
        'Pendiente',                 -- Resultado inicial
        GETDATE()                    -- Fecha de creación
    FROM INSERTED i;
END;
