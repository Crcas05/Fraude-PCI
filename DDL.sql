USE FRAUDE;
GO

-- ================================================
-- TABLA: CLIENTES
-- ================================================
CREATE TABLE dbo.Clientes (
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    DocumentoIdentidad NVARCHAR(20) UNIQUE NOT NULL,
    FechaRegistro DATETIME DEFAULT GETDATE()
);
GO

-- ================================================
-- TABLA: TARJETAS
-- ================================================
CREATE TABLE dbo.Tarjetas (
    IdTarjeta INT IDENTITY(1,1) PRIMARY KEY,
    IdCliente INT NOT NULL,
    NumeroTarjeta NVARCHAR(20) UNIQUE NOT NULL,
    FechaExpiracion DATE NOT NULL,
    Estado NVARCHAR(20) DEFAULT 'Activa',
    CONSTRAINT FK_Tarjetas_Clientes FOREIGN KEY (IdCliente)
        REFERENCES dbo.Clientes (IdCliente)
);
GO

-- ================================================
-- TABLA: TRANSACCIONES
-- ================================================
CREATE TABLE dbo.Transacciones (
    IdTransaccion BIGINT IDENTITY(1,1) PRIMARY KEY,
    IdTarjeta INT NOT NULL,
    Monto DECIMAL(18,2) NOT NULL,
    FechaTransaccion DATETIME DEFAULT GETDATE(),
    Ciudad NVARCHAR(100),
    Pais NVARCHAR(100),
    Canal NVARCHAR(50),  -- POS, WEB, APP
    Resultado NVARCHAR(20) DEFAULT 'Aprobada',
    CONSTRAINT FK_Transacciones_Tarjetas FOREIGN KEY (IdTarjeta)
        REFERENCES dbo.Tarjetas (IdTarjeta)
);
GO

-- ================================================
-- TABLA: ALERTAS DE FRAUDE
-- ================================================
CREATE TABLE dbo.AlertasFraude (
    IdAlerta INT IDENTITY(1,1) PRIMARY KEY,
    IdTransaccion BIGINT NOT NULL,
    TipoAlerta NVARCHAR(100) NOT NULL,
    NivelRiesgo NVARCHAR(20) CHECK (NivelRiesgo IN ('Bajo', 'Medio', 'Alto')),
    FechaAlerta DATETIME DEFAULT GETDATE(),
    Estado NVARCHAR(20) DEFAULT 'Pendiente',
    CONSTRAINT FK_Alertas_Transacciones FOREIGN KEY (IdTransaccion)
        REFERENCES dbo.Transacciones (IdTransaccion)
);
GO

-- ================================================
-- TABLA: HISTORIAL DE REVISION
-- ================================================
CREATE TABLE dbo.HistorialRevision (
    IdRevision INT IDENTITY(1,1) PRIMARY KEY,
    IdAlerta INT NOT NULL,
    Analista NVARCHAR(100),
    Comentario NVARCHAR(255),
    FechaRevision DATETIME DEFAULT GETDATE(),
    Resultado NVARCHAR(50),
    CONSTRAINT FK_Revision_Alertas FOREIGN KEY (IdAlerta)
        REFERENCES dbo.AlertasFraude (IdAlerta)
);
GO

/* Insertando Valores */
-- Clientes ----
INSERT INTO dbo.Clientes (Nombre, Apellido, DocumentoIdentidad)
VALUES
('Juan', 'Pérez', 'DNI12345678'),
('María', 'Gómez', 'DNI87654321'),
('Carlos', 'Ramírez', 'DNI11223344');
GO

-- Tarjetas
INSERT INTO dbo.Tarjetas (IdCliente, NumeroTarjeta, FechaExpiracion)
VALUES
(1, '4111111111111111', '2026-12-31'),
(1, '4222222222222222', '2025-06-30'),
(2, '4333333333333333', '2027-03-31'),
(3, '4444444444444444', '2024-11-30');
GO

-- Transacciones
INSERT INTO dbo.Transacciones (IdTarjeta, Monto, Ciudad, Pais, Canal)
VALUES
(1, 150.50, 'Lima', 'Perú', 'POS'),
(1, 1200.00, 'Lima', 'Perú', 'WEB'),
(2, 75.00, 'Cusco', 'Perú', 'APP'),
(3, 3000.00, 'Arequipa', 'Perú', 'POS'),
(4, 50.00, 'Lima', 'Perú', 'WEB');
GO

-- AlertasFraude (el trigger crea automáticamente HistorialRevision)
INSERT INTO dbo.AlertasFraude (IdTransaccion, TipoAlerta, NivelRiesgo)
VALUES
(2, 'Transacción Alta', 'Alto'),
(4, 'Transacción Sospechosa', 'Medio');
GO
