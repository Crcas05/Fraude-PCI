
-- Iniciar transacción --
BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Insertar primera transacción y guardar su Id
    INSERT INTO dbo.Transacciones (IdTarjeta, Monto, Ciudad, Pais, Canal)
    VALUES (1, 2500.00, 'Lima', 'Perú', 'WEB');
    DECLARE @IdTrans1 BIGINT = SCOPE_IDENTITY();

    -- 2. Insertar segunda transacción y guardar su Id
    INSERT INTO dbo.Transacciones (IdTarjeta, Monto, Ciudad, Pais, Canal)
    VALUES (3, 180.00, 'Cusco', 'Perú', 'POS');
    DECLARE @IdTrans2 BIGINT = SCOPE_IDENTITY();

    -- 3. Insertar alertas asociadas a las transacciones
    INSERT INTO dbo.AlertasFraude (IdTransaccion, TipoAlerta, NivelRiesgo)
    VALUES 
        (@IdTrans1, 'Transacción Inusual', 'Alto'),
        (@IdTrans2, 'Transacción Sospechosa', 'Medio');

    -- 4. Actualizar historial de las alertas recién creadas
    UPDATE h
    SET Analista = 'Cristhian Castro',
        Comentario = 'Revisión automática completada',
        Resultado = 'Cerrada',
        FechaRevision = GETDATE()
    FROM dbo.HistorialRevision h
    INNER JOIN dbo.AlertasFraude a ON h.IdAlerta = a.IdAlerta
    WHERE a.IdTransaccion IN (@IdTrans1, @IdTrans2);

    -- 5. Actualizar el estado de las alertas
    UPDATE dbo.AlertasFraude
    SET Estado = 'Cerrada'
    WHERE IdTransaccion IN (@IdTrans1, @IdTrans2);

    -- Si todo salió bien, confirmar cambios
    COMMIT;
END TRY
BEGIN CATCH
    -- Si hay error, revertir todo
    ROLLBACK;

    -- Mostrar mensaje de error
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Error en la transacción: %s', 16, 1, @ErrorMessage);
END CATCH;

/*Simulacion */
BEGIN TRANSACTION;

INSERT INTO dbo.Transacciones (IdTarjeta, Monto, Ciudad, Pais, Canal)
VALUES (1, 2500.00, 'Lima', 'Perú', 'WEB');

SELECT * FROM dbo.Transacciones;

ROLLBACK;