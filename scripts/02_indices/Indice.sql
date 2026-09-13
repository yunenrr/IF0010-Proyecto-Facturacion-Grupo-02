USE FacturacionSolucionesMagnificas;
GO

CREATE UNIQUE NONCLUSTERED INDEX ix_factura_comprobante 
	ON dbo.FACTURA (identificador_comprobante);
GO

CREATE NONCLUSTERED INDEX ix_Factura_CedulaCliente 
	ON dbo.FACTURA (cedula_cliente) 
	INCLUDE (fecha_emision, monto_total, estado_factura);
GO

CREATE NONCLUSTERED INDEX ix_factura_fecha_emision 
	ON dbo.FACTURA (fecha_emision) 
	INCLUDE (codigo_factura, cedula_cliente, monto_total);
GO

CREATE NONCLUSTERED INDEX ix_factura_estado
	ON dbo.FACTURA (estado_factura)
	INCLUDE (codigo_factura, fecha_emision, monto_total);
GO

CREATE NONCLUSTERED INDEX ix_detalle_factura_totales 
	ON dbo.DetalleFactura (codigo_factura) 
	INCLUDE (id_detalle, 
	cantidad, 
	precio_unitario, 
	subtotal_linea, 
	monto_impuesto, 
	monto_total_linea); 
GO

CREATE NONCLUSTERED INDEX ix_detalle_codigo_producto
	ON dbo.DETALLEFACTURA (codigo_producto);
GO



