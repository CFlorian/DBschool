Use Northwind
Go
-- Procedimientos almacenados 
SELECT 
c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate,
Sum(d.unitprice * d.quantity) as Total
From customers as c inner join orders as o ON c.customerid = o.customerid
INNER JOIN [Order Details] as d ON o.OrderID=d.OrderID
GROUP BY c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate
Go

-- Se crea el procedimiento almacenado
Create Procedure proc_ventas @fecha1 date, @fecha2 date
as
SELECT 
c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate,
Sum(d.unitprice * d.quantity) as Total
From customers as c inner join orders as o ON c.customerid = o.customerid
INNER JOIN [Order Details] as d ON o.OrderID=d.OrderID
GROUP BY c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate
Go

-- ejecutar el SP
Execute proc_ventas '01-01-1996','12-31-1996'
Go

-- SP con insert
Create Procedure proc_insert_customers
@Customerid nChar(5), @Companyname nvarchar(100),
@ContactName nvarchar(100), @ContactTitle nvarchar(100),
@Country nvarchar(100)
as
INSERT INTO Customers (Customerid, CompanyName, ContactName,
ContactTitle, Country)
Values (@Customerid, @Companyname, @ContactName,
@ContactTitle, @Country)
Go

-- Se ejecuta
Execute proc_insert_customers 'CCCC','NuevoTest Enterprice',
'Juanito Bazooka','Dr','Guatemala'

-- Se consulta lo insertado
Select * from Customers WHERE CustomerID = 'CCCC'
Go

-- Procedimiento almacenado 
Create OR ALTER PROCEDURE proc_parimpar @numeromaximo int
as
Declare @numero int
Set @numero = 1
While @numero <= @numeromaximo
Begin
	if (@numero%2) = 0
		BEGIN
			Print 'El numero '+ cast(@numero as varchar(5)) + ' Es par'
		END
	ELSE
		BEGIN
			Print 'El numero '+ cast(@numero as varchar(5)) + ' Es impar'
		END
	Set @numero = @numero + 1
End
Go

-- Se ejecuta
Execute proc_parimpar 70
Go

-- Parametros de salida en un SP
CREATE OR ALTER PROCEDURE proc_numeroclientes @pais varchar(15), @resultado int output
as
Select CustomerID, CompanyName, Country FROM Customers WHERE Country=@pais
SET @resultado=@@ROWCOUNT -- @@RowCount es una variable propia de sql para devolver No. de rows en la consulta
Execute proc_parimpar @resultado
Go

-- Se ejecuta y se le indica que el SP devolvera un parametro 
Declare @numeroclientes int
Execute proc_numeroclientes 'France', @numeroclientes output
Select @numeroclientes
Go

-- Procedimientos extendidos 
/* Estos procedimientos extiendes poder realizar cosas fuera del sql como por ejemplo
Leer directorios. 
Primero se corre un query para modificar la configuracion de la base de datos 
a avanzada y permitir estos SP*/
Execute sp_configure 'show advanced option',1
GO
Reconfigure

Execute sp_configure 'xp_cmdshell',1
Go
Reconfigure

-- Con este procedimiento se lee el directorio del disco C:
Execute master.dbo.xp_cmdshell 'dir c:\'

-- SP extendido que devuelve info del servidor
Execute master.dbo.xp_msver 'ProductName' -- Nombre del producto
Execute master.dbo.xp_msver 'ProductVersion' -- Version que se esta utilizando
Execute master.dbo.xp_msver 'Platform' -- La plataforma utilizada
/* Link para poder ver más procedimientos extendidos
https://docs.microsoft.com/es-es/sql/relational-databases/system-stored-procedures/general-extended-stored-procedures-transact-sql?view=sql-server-ver15
*/


/*Recompile funciona para decirle a la cache que verifique si la ruta que esta tomando
es la correcta o puede tomar otra ruta. Se recomienda hacer el recompile 
En una ejecucion de SP
*/
Declare @numeroclientes int
Execute proc_numeroclientes 'France', @numeroclientes output with recompile
Select @numeroclientes
Go

/*Trigers es un procedimiento ligado a una tabla 
Cuando la tabla se ve afectada se dipara el trigger

Ejemplo la tabla de productos y detalle de ordenes
Se requiere que al insertar la orden el trigger inserte
el valor del producto insertado */

-- Se crea el trigger
Create trigger tg_buscarprecio
on [order details] for insert
AS
Update [Order Details] set UnitPrice=(
Select p.UnitPrice from Products p 
INNER JOIN inserted as i ON p.ProductID=i.ProductID) from [Order Details]
INNER JOIN inserted ON [Order Details].OrderID = inserted.OrderID and
[Order Details].ProductID = inserted.ProductID
Go

-- Se prueba trigger
Select * from Products WHERE ProductID = 12 -- Id 12 Val 38 || Id 5 Val 21.35
Select * From [Order Details]
Go

-- Se inserta un dato y luego se debe verificar que el trigger funciono
INSERT INTO [Order Details] (OrderID,ProductID, Quantity, Discount)
values (10248,5,10,0)
Go

-- Se borra el registro de prueba
Delete from [Order Details] WHERE OrderID = 10248 AND ProductID = 5

/* Segundo ejemplo con trigger 
Se requiere rebajar de inventario el producto y la cantidad adquirida*/
Create Trigger tg_rebajarinventario
ON [Order Details] for insert
AS
Update Products set UnitsInStock = UnitsInStock - i1.Quantity
From Products p1 INNER JOIN inserted i1 ON
i1.ProductID = p1.ProductID
Go

-- Regresar a inventario
Create OR ALTER Trigger tg_regresarinventario
ON [Order Details] for delete
AS
Update Products set UnitsInStock = UnitsInStock + d1.Quantity
From Products p1 INNER JOIN deleted d1 ON
d1.ProductID = p1.ProductID
Go

-- Se prueba trigger
Select * from Products WHERE ProductID = 12 -- Id 12 Unit 86 || Id 9 Val 29
Select * From [Order Details]
Go
-- Update Products set UnitsInStock = 86 WHERE ProductID = 12

-- Se inserta un dato y luego se debe verificar que el trigger funciono
-- y RESTO DE products los que se tomaron en la orden 
INSERT INTO [Order Details] (OrderID,ProductID, Quantity, Discount)
values (10248,12,16,0)
Go

-- Se borra el registro de prueba debe regreses los productos al inventario
Delete from [Order Details] WHERE OrderID = 10248 AND ProductID = 12