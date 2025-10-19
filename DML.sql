/* ==============================================
   Script DML completo - Sistema de Alertas de Fraude
   ============================================== */

/* 0. Normalizar valores antiguos en HistorialRevision */
UPDATE dbo.HistorialRevision
SET Analista = ISNULL(Analista, 'Pendiente'),
    Comentario = ISNULL(Comentario, 'Revisión pendiente'),
    Resultado = ISNULL(Resultado, 'Pendiente'),
    FechaRevision = ISNULL(FechaRevision, GETDATE());

/* 1. Declarar variables para IdTransacciones y IdAlertas */
DECLARE @IdTrans1 BIGINT, @IdTrans2 BIGINT;
DECLARE @IdAlerta1 INT, @IdAlerta2 INT;

/* 2. Insertar transacciones nuevas */
INSERT INTO dbo.Transacciones (IdTarjeta, Monto, Ciudad, Pais, Canal)
VALUES (1, 2500.00, 'Lima', 'Perú', 'WEB');
SET @IdTrans1 = SCOPE_IDENTITY();

INSERT INTO dbo.Transacciones (IdTarjeta, Monto, Ciudad, Pais, Canal)
VALUES (3, 180.00, 'Cusco', 'Perú', 'POS');
SET @IdTrans2 = SCOPE_IDENTITY();

/* 3. Insertar alertas nuevas (dispara trigger fila por fila) */
INSERT INTO dbo.AlertasFraude (IdTransaccion, TipoAlerta, NivelRiesgo)
VALUES (@IdTrans1, 'Transacción Inusual', 'Alto');
SET @IdAlerta1 = SCOPE_IDENTITY();

INSERT INTO dbo.AlertasFraude (IdTransaccion, TipoAlerta, NivelRiesgo)
VALUES (@IdTrans2, 'Transacción Sospechosa', 'Medio');
SET @IdAlerta2 = SCOPE_IDENTITY();

/* 4. Actualizar historial generado por el trigger para las nuevas alertas */
UPDATE h
SET Analista = 'Cristhian Castro',
    Comentario = 'Revisión automática completada',
    Resultado = 'Cerrada',
    FechaRevision = GETDATE()
FROM dbo.HistorialRevision h
WHERE h.IdAlerta IN (@IdAlerta1, @IdAlerta2);

/* 5. Actualizar el estado de las alertas a "Cerrada" */
UPDATE dbo.AlertasFraude
SET Estado = 'Cerrada'
WHERE IdAlerta IN (@IdAlerta1, @IdAlerta2);

/* 6. Consultar resultados finales */
SELECT
    a.IdAlerta,
    a.IdTransaccion,
    t.IdTarjeta,
    t.Monto,
    t.Ciudad,
    t.Pais,
    t.Canal,
    a.TipoAlerta,
    a.NivelRiesgo,
    a.Estado AS EstadoAlerta,
    h.IdRevision,
    h.Analista,
    h.Comentario,
    h.FechaRevision,
    h.Resultado
FROM dbo.AlertasFraude a
INNER JOIN dbo.Transacciones t ON a.IdTransaccion = t.IdTransaccion
LEFT JOIN dbo.HistorialRevision h ON a.IdAlerta = h.IdAlerta
ORDER BY a.FechaAlerta DESC;
