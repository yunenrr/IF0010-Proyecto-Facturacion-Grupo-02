USE FACTURACIONSOLUCIONESMAGNIFICAS;

CREATE TABLE EMPRESAEMISORA (
    CEDULA VARCHAR(20) NOT NULL,
    NOMBRE_COMERCIAL VARCHAR(150) NOT NULL,
    RAZON_SOCIAL VARCHAR(150) NOT NULL,
    DIRECCION VARCHAR(250) NULL,
    TELEFONO VARCHAR(20) NULL,
    CORREO VARCHAR(100) NULL,
    FECHA_CREACION DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ACTIVA BIT NOT NULL DEFAULT 1,

    CONSTRAINT PK_EMPRESAEMISORA PRIMARY KEY (CEDULA)
);

CREATE TABLE CLIENTE (
    CEDULA VARCHAR(20) NOT NULL,
    NOMBRE VARCHAR(70) NOT NULL,
    DIRECCION_CONTACTO VARCHAR(50) NOT NULL,
    TELEFONO VARCHAR(15) NOT NULL,
    CORREO VARCHAR(75) NOT NULL,
    FECHA_REGISTRO DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ULTIMA_ACTUALIZACION DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_CLIENTE PRIMARY KEY (CEDULA)
);

CREATE TABLE TIPODOCUMENTO (
    ID_TIPO_DOCUMENTO INT NOT NULL,
    DESCRIPCION_TIPO_DOCUMENTO VARCHAR(50) NOT NULL,

    CONSTRAINT PK_TIPODOCUMENTO PRIMARY KEY (ID_TIPO_DOCUMENTO)
);

CREATE TABLE DIVISA (
    CODIGO_DIVISA CHAR(3) NOT NULL,
    NOMBRE VARCHAR(50) NOT NULL,
    SIMBOLO VARCHAR(5) NOT NULL,

    CONSTRAINT PK_DIVISA PRIMARY KEY (CODIGO_DIVISA)
);

CREATE TABLE ESTADOFACTURA (
    ESTADO VARCHAR(20) NOT NULL,
    DESCRIPCION_ESTADO VARCHAR(100) NOT NULL,

    CONSTRAINT PK_ESTADOFACTURA PRIMARY KEY (ESTADO)
);

CREATE TABLE PRODUCTOSERVICIO(
    codigo_id VARCHAR(30) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    precio_unitario DECIMAL(18,2) NOT NULL,
    porcentaje_impuesto DECIMAL (5,2) NOT NULL,
    tipo_item VARCHAR(10) NOT NULL DEFAULT 'PRODUCTO',
    estado VARCHAR(10) NOT NULL DEFAULT 'ACTIVO',
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_ProductoServicio PRIMARY KEY (codigo_id)
);

CREATE TABLE FACTURA(
    codigo_factura INT IDENTITY(1,1) NOT NULL,
    identificador_comprobante VARCHAR(30) NOT NULL,
    cedula_empresa VARCHAR(20) NOT NULL,
    cedula_cliente VARCHAR(20) NOT NULL,
    id_tipo_documento INT NOT NULL,
    codigo_divisa CHAR(3) NOT NULL,
    estado_factura VARCHAR(20) NOT NULL DEFAULT 'EMITIDA',
    fecha_emision DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    subtotal DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    total_descuentos DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    total_impuestos DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    monto_total AS (subtotal - total_descuentos + total_impuestos) PERSISTED,
    observaciones VARCHAR(255) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Factura PRIMARY KEY (codigo_factura),
    CONSTRAINT UQ_Factura_Comprobante UNIQUE (identificador_comprobante),
    CONSTRAINT FK_Factura_EmpresaEm FOREIGN KEY (cedula_empresa) REFERENCES EMPRESAEMISORA(cedula),
    CONSTRAINT FK_Factura_Cliente FOREIGN KEY (cedula_cliente) REFERENCES CLIENTE(cedula),
    CONSTRAINT FK_Factura_TipoDoc FOREIGN KEY (id_tipo_documento) REFERENCES TIPODOCUMENTO(id_tipo_documento),
    CONSTRAINT FK_Factura_Divisa FOREIGN KEY (codigo_divisa) REFERENCES DIVISA(codigo_divisa),
    CONSTRAINT FK_Factura_Estado FOREIGN KEY (estado_factura) REFERENCES ESTADOFACTURA(estado)
);

CREATE TABLE DETALLEFACTURA (
    id_detalle INT IDENTITY(1,1) NOT NULL,
    codigo_factura INT NOT NULL,
    codigo_producto VARCHAR(30) NOT NULL,
    numero_linea INT NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    precio_unitario DECIMAL(18,2) NOT NULL,
    porcentaje_descuento DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    porcentaje_impuesto DECIMAL(5,2) NOT NULL DEFAULT 0.00,

    subtotal_linea AS (cantidad * precio_unitario) PERSISTED,
    monto_descuento AS ((cantidad * precio_unitario) * (porcentaje_descuento / 100.0)) PERSISTED,
    monto_impuesto AS (((cantidad * precio_unitario) - ((cantidad * precio_unitario) * (porcentaje_descuento / 100.0))) * (porcentaje_impuesto / 100.0)) PERSISTED,
    monto_total_linea AS (((cantidad * precio_unitario) - ((cantidad * precio_unitario) * (porcentaje_descuento / 100.0))) + (((cantidad * precio_unitario) - ((cantidad * precio_unitario) * (porcentaje_descuento / 100.0))) * (porcentaje_impuesto / 100.0))) PERSISTED,

    CONSTRAINT PK_DetalleFactura PRIMARY KEY (id_detalle),
    CONSTRAINT FK_DetalleFactura_Factura FOREIGN KEY (codigo_factura) REFERENCES FACTURA(codigo_factura) ON DELETE CASCADE,
    CONSTRAINT FK_DetalleFactura_Producto FOREIGN KEY (codigo_producto) REFERENCES PRODUCTOSERVICIO(codigo_id)
);

CREATE TABLE AUDITORIASISTEMA (
    id_auditoria INT IDENTITY(1,1) NOT NULL,
    tabla_afectada VARCHAR(50) NOT NULL,          
    llave_primaria VARCHAR(50) NOT NULL,          
    operacion VARCHAR(10) NOT NULL,               
    campo_modificado VARCHAR(50) NULL,            
    valor_anterior VARCHAR(MAX) NULL,             
    valor_nuevo VARCHAR(MAX) NULL,                
    usuario VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(), 
    fecha_hora DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_AuditoriaSistema PRIMARY KEY (id_auditoria),
    CONSTRAINT CHK_Auditoria_Operacion CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE'))
);
