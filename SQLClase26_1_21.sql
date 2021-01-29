-- Vistas y funciones
Use [Northwind]
Go

Select c.CustomerID, c.CompanyName, c.Country, o.OrderID, o.OrderDate,
DATEPART(yyyy,o.OrderDate) as Year, DATEPART(mm, OrderDate) as Month,
ca.CategoryName, p.ProductName, d.UnitPrice, d.Quantity
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Go

-- Ventas por año
Select 
DATEPART(yyyy,o.OrderDate) as Year, sum(d.UnitPrice * d.Quantity) as total
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Group by DATEPART(yyyy,o.OrderDate)
Go

-- Ventas por categoria
Select 
ca.CategoryName, sum(d.UnitPrice * d.Quantity) as total
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Group by ca.CategoryName
Go

-- Ventas por año y categoria
Select DATEPART(yyyy,o.OrderDate) as Year,
ca.CategoryName, sum(d.UnitPrice * d.Quantity) as total
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Group by ca.CategoryName, DATEPART(yyyy,o.OrderDate)
Order by DATEPART(yyyy,o.OrderDate), ca.CategoryName
Go

-- Ventas totales por año
-- Los valores que aparecen en null son los totales por año
Select DATEPART(yyyy,o.OrderDate) as Year,
ca.CategoryName, sum(d.UnitPrice * d.Quantity) as total
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Group by ca.CategoryName, DATEPART(yyyy,o.OrderDate) with rollup
-- Order by DATEPART(yyyy,o.OrderDate), ca.CategoryName 
Go

-- Ventas totales por año y categorias
-- Los valores que aparecen en null son los totales por año y por categoria
-- El null, null es el total total
Select DATEPART(yyyy,o.OrderDate) as Year,
ca.CategoryName, sum(d.UnitPrice * d.Quantity) as total
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Group by ca.CategoryName, DATEPART(yyyy,o.OrderDate) with cube
-- Order by DATEPART(yyyy,o.OrderDate), ca.CategoryName 
Go

-- Funciones de agregado
-- Total de ventas
Select 
sum(d.UnitPrice * d.Quantity) as total
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Go

-- valor minimo de venta
Select 
min(d.UnitPrice * d.Quantity) as total
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Go

-- Operaciones de conjuntos
Select CustomerID from Customers
-- Intersecta valores iguales en ambas tablas
-- En este ejemplo son todos los customers que tienen ordenes
intersect
Select CustomerID from Orders
Go


Select CustomerID from Customers
-- Lo contrario de interceptar
-- En este ejemplo son todos los customers que No tienen ordenes
Except
Select CustomerID from Orders
Go

Select CompanyName from Customers
-- Unir valores
-- Con esta funcion se une horizontalmente
Union
Select CompanyName from Suppliers
Go

-- Vistas
/*Las vistas solo pueden encapsular un select, nada más.
* Su funcion puede ser por seguridad para que un usuario no consulte tabla pero una vista si.
* La vista no tiene datos propios, toma datos del momento y la muestra
* El maximo de registros es de 16500
* Una vista no puede llevar un order by, solamente si se le agrega un top
*/
Create view view_sales
as
Select c.CustomerID, c.CompanyName, c.Country, o.OrderID, o.OrderDate,
DATEPART(yyyy,o.OrderDate) as Year, DATEPART(mm, OrderDate) as Month,
ca.CategoryName, p.ProductName, d.UnitPrice, d.Quantity
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Go

-- Ver las vista que se acaba de crear
Select * from view_sales
Go

Alter view view_sales (CodigoCliente, NombreCliente, Pais, NumeroOrden, Fecha, Año, Mes, 
NombreCategoria, NombreProducto, Precio, Cantidad)
as
Select c.CustomerID, c.CompanyName, c.Country, o.OrderID, o.OrderDate,
DATEPART(yyyy,o.OrderDate) as Year, DATEPART(mm, OrderDate) as Month,
ca.CategoryName, p.ProductName, d.UnitPrice, d.Quantity
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Go

-- Ver las vista que se acaba de modificar
Select * from view_sales

-- Para ver el script de la vista
sp_helptext view_sales
Go

-- Para encriptar el script de la vista y no se pueda consultar con el sp_helptext
Alter view view_sales (CodigoCliente, NombreCliente, Pais, NumeroOrden, Fecha, Año, Mes, 
NombreCategoria, NombreProducto, Precio, Cantidad)
with encryption
as
Select c.CustomerID, c.CompanyName, c.Country, o.OrderID, o.OrderDate,
DATEPART(yyyy,o.OrderDate) as Year, DATEPART(mm, OrderDate) as Month,
ca.CategoryName, p.ProductName, d.UnitPrice, d.Quantity
from Customers as c inner join Orders as o on c.CustomerID = o.CustomerID
inner join [Order Details] as d on o.OrderID=d.OrderID
inner join Products as p on d.ProductID = p.ProductID
inner join Categories as ca on p.CategoryID=ca.CategoryID
Go

-- Para enlazar exquemas de la vista
/*Hace que las tablas que construyen la vista no se puedan elminar o modificar
Para no dañar la vista
*/
Alter view view_sales (CodigoCliente, NombreCliente, Pais, NumeroOrden, Fecha, Año, Mes, 
NombreCategoria, NombreProducto, Precio, Cantidad)
with schemabinding
as
Select c.CustomerID, c.CompanyName, c.Country, o.OrderID, o.OrderDate,
DATEPART(yyyy,o.OrderDate) as Year, DATEPART(mm, OrderDate) as Month,
ca.CategoryName, p.ProductName, d.UnitPrice, d.Quantity
from dbo.Customers as c inner join dbo.Orders as o on c.CustomerID = o.CustomerID
inner join dbo.[Order Details] as d on o.OrderID=d.OrderID
inner join dbo.Products as p on d.ProductID = p.ProductID
inner join dbo.Categories as ca on p.CategoryID=ca.CategoryID
Go

-- Se intenta eliminar la tabla order detail y deberia dar error 
Drop table [Order Details]
Go
/* Da el siguiente 
Cannot DROP TABLE 'Order Details' because it is being referenced by object 'view_sales'.*/

/***En oracle si existen las vistas materializadas, como vistas fisicas que contienen datos
En SQL SERVER no existe como tal esa referencia aunque si 
Semi materializadas porque se le pueden colocar indices a las vistas***/


-- Para no mandar metadata a los lenguajes de programacion al consultar la vista
/*Si se consulta desde cualquier lenguaje la vista y se le coloca 
viewmetadata la consulta no sabra que esta consultando una vista sino
La va a tratar como una consulta a una tabla 
*/
Alter view view_sales (CodigoCliente, NombreCliente, Pais, NumeroOrden, Fecha, Año, Mes, 
NombreCategoria, NombreProducto, Precio, Cantidad)
with view_metadata
as
Select c.CustomerID, c.CompanyName, c.Country, o.OrderID, o.OrderDate,
DATEPART(yyyy,o.OrderDate) as Year, DATEPART(mm, OrderDate) as Month,
ca.CategoryName, p.ProductName, d.UnitPrice, d.Quantity
from dbo.Customers as c inner join dbo.Orders as o on c.CustomerID = o.CustomerID
inner join dbo.[Order Details] as d on o.OrderID=d.OrderID
inner join dbo.Products as p on d.ProductID = p.ProductID
inner join dbo.Categories as ca on p.CategoryID=ca.CategoryID
Go

-- Se crea vista para insertar solo personas de Francia 
Create view view_costumersfrance
as 
Select CustomerID, CompanyName, ContactName, Country
from Customers where Country = 'France'
Go

-- Se consulta
Select * from view_costumersfrance
Go

-- Este insert a pesar que se hace a una vista se inserta a la tabla original
-- Ya que la vista no tiene datos propios
Insert into view_costumersfrance (CustomerID, CompanyName, ContactName, Country)
values ('AAAB','Test Empresa', 'Juan Perez', 'Guatemala')
Go

Select * from Customers where Country = 'Guatemala'
Go

-- Para no permitir que a una vista se le inserte valores que no estan en su 
-- Where se le incluye el 'with check option'
Create view view_costumersfrance
as 
Select CustomerID, CompanyName, ContactName, Country
from Customers where Country = 'France'
with check option
Go

-- Funciones
-- Se crea una funcion de tabla en linea, es muy parecida a una vista 
-- Pero la funcion permite parametros 
Create function fn_customers_country (@Pais varchar(50))
Returns table
as 
Return(
Select CustomerID, CompanyName, ContactName, Country, city
from Customers where Country = @Pais)
Go

-- Se consulta la funcion 
Select * from fn_customers_country ('Argentina')
Go

-- Se crea funcion
-- Con valore de tabla en linea con multiples instrucciones
Create function fn_customers_country2 (@Pais varchar(50))
Returns @cliente table (CustomerID varchar(5), 
CompanyName varchar (100), ContactName varchar (100), 
Country varchar (100), city varchar(100))
as 
BEGIN
INSERT INTO @cliente
Select CustomerID, CompanyName, ContactName, Country, city
from Customers where Country = @Pais
Return
End
Go

Select * from fn_customers_country2 ('Argentina')
Go

-- Se crea una funcion escalar 
/*
Es una funcion de programacion para calcular el iva
*/
Create function Iva (@dinero money)
Returns money
as 
Begin
	Declare @iva money
	set @iva = @dinero * 0.12
	Return (@iva)
End
Go

-- Se consulta la funcion
/* Las funciones tienen la peculiaridad que iran consultando en cada row
de la tabla donde se coloque y eso puede hacer un poco 
lenta la consulta de una tabla muy grande
*/
Select ProductName, UnitPrice, dbo.Iva(UnitPrice) as IVA from Products
Go

/*
Es una funcion de programacion para calcular el iva
*/
Create function Comision (@dinero money)
Returns money
as 
Begin
	Declare @resultado money
	if @dinero >= 25 
		Begin
			set @resultado = @dinero * 1.10
		End
	Else
		Begin
			set @resultado = @dinero
		End
	Return (@resultado)
End
Go