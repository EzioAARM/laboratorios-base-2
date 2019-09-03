/*
	Personas que no tienen direcciòn registrada
*/

select C.CustomerID, C.PersonID, p.FirstName, p.LastName  from sales.Customer C
inner join Person.Person P on c.PersonID = p.BusinessEntityID
left outer join Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID
where bea.AddressID is null;

/*
	Productos que nunca han sido vendidos
*/

select * from Production.Product p
where FinishedGoodsFlag = 1 and
not exists (select * from sales.SalesOrderDetail s where p.productID = s.ProductID)

/*
	Cantidad de ordenes (por $) que cumplan con el siguiente formato
*/

select '0 - 99' as Rango, COUNT(hd.SalesOrderID) as Cantidad, SUM(TotalDue) as Suma from Sales.SalesOrderHeader hd where TotalDue >= 0 and TotalDue <= 99
union all
select '100 - 999' as Rango, COUNT(hd.SalesOrderID) as Cantidad, SUM(TotalDue) as Suma from Sales.SalesOrderHeader hd where TotalDue >= 100 and TotalDue <= 999
union all
select '1000 - 9999' as Rango, COUNT(hd.SalesOrderID) as Cantidad, SUM(TotalDue) as Suma from Sales.SalesOrderHeader hd where TotalDue >= 1000 and TotalDue <= 9999
union all
select '10000' as Rango, COUNT(hd.SalesOrderID) as Cantidad, SUM(TotalDue) as Suma from Sales.SalesOrderHeader hd where TotalDue >= 10000

select case 
	when hd.TotalDue between 0 and 99 then '0 - 99'
	when hd.TotalDue between 100 and 999 then '100 - 999'
	when hd.TotalDue between 1000 and 9999 then '1000 - 9999'
	else '10000 -'
end as Rango,
Count(hd.SalesOrderID),
SUM(hd.TotalDue)

from Sales.SalesOrderHeader hd
group by case 
	when hd.TotalDue between 0 and 99 then '0 - 99'
	when hd.TotalDue between 100 and 999 then '100 - 999'
	when hd.TotalDue between 1000 and 9999 then '1000 - 9999'
	else '10000 -'
end

/*
	Listar por cada proveedor, la cantidad de compras que se le han realizado, el monto total, la
compra mínima y máxima, así como también la primer y última fecha cuando se le compró.
*/

select v.BusinessEntityID, v.Name, COUNT(a.PurchaseOrderID) as CantidadOrdenes, SUM(a.TotalDue) as TotalOrdenes, MIN(a.TotalDue) as CompraMinima, 
MAX(a.TotalDue) as CompraMaxima, MIN(a.OrderDate) as PrimeraCompra, MAX(a.OrderDate) as UltimaCompra from purchasing.PurchaseOrderHeader a
	inner join Purchasing.Vendor v on a.VendorID = v.BusinessEntityID group by v.BusinessEntityID, v.Name;
/*
	Cuanto a recibido cada empleado (salario ) al día de hoy.
*/

Select ph.BusinessEntityID, Sum(ph.Rate * dbo.hojasTrabajadas(Convert(date, ph.RateChangeDate), Convert(time, ph.RateChangeDate), Convert(date, GETDATE()), Convert(time, GETDATE()))) as Total
from HumanResources.EmployeePayHistory ph group by BusinessEntityID;

/*
	Mostrar todos los componentes que se necesitan para fabricar un producto en específico. 
*/

CREATE PROCEDURE USP_Derivados @ProductId int
as
begin

Select Pro.Name, P.Name from Production.Product Pro inner join Production.BillOfMaterials Bill on Pro.ProductID = Bill.ProductAssemblyID
inner join Production.Product P on Bill.ComponentID = P.ProductID where Pro.ProductID = @ProductId order by Pro.Name
end;

/*
	No permita ingresar una tarjeta de crédito con diferencia de fecha de expiración menor a 30 días.
*/

CREATE OR ALTER TRIGGER Sales.VerificarVencimientoTarjeta
ON Sales.CreditCard
INSTEAD OF INSERT 
AS
BEGIN
	DECLARE @ExpMonth as int
	Declare @ExpYear as int
	Declare @Actual as date
	DECLARE @cardType as nvarchar(50)
	declare @cardNum as nvarchar(25)
	declare @modDate as datetime
	SELECT @ExpMonth = ExpMonth, @ExpYear = ExpYear, @Actual = CONVERT(date, ModifiedDate), @cardType = CardType, @cardNum = CardNumber, @modDate = ModifiedDate FROM inserted
	print @Actual
	declare @fechaDiff as int
	print  convert(varchar(10), @ExpYear) + '-' + convert(varchar(10), @ExpMonth) + '-01'
	select @fechaDiff = DATEDIFF(DAY, @Actual , convert(varchar(10), @ExpYear) + '-' + convert(varchar(10), @ExpMonth) + '-01')
	print @fechaDiff
	if @fechaDiff > 30
	begin
		insert into Sales.CreditCard (CardType, CardNumber, ExpMonth, ExpYear, ModifiedDate) values (@cardType, @cardNum, @ExpMonth, @ExpYear, @modDate);
	end
	else
	begin
		RAISERROR ('La tarjeta vencerà en 30 dìas o menos',10, 1) 
	end;
END


/*
	No permita ingresar y/o actualizar un correo electrónico asociado a otra persona
*/
CREATE OR ALTER TRIGGER Person.VerificarEmail
ON Person.EmailAddress
INSTEAD OF INSERT 
AS
BEGIN
	declare @emailNuevo as nvarchar(50)
	SELECT @emailNuevo = EmailAddress FROM inserted
	declare @query as nvarchar(50)
	select @query = EmailAddress.EmailAddress from Person.EmailAddress where EmailAddress = @emailNuevo
	if EXISTS(select * from Person.EmailAddress where EmailAddress = @emailNuevo)
	begin
		RAISERROR ('El correo ya esta asociado a otra persona',10, 1)
	end
	else
	begin
		insert Person.EmailAddress (BusinessEntityID, EmailAddress, ModifiedDate) select BusinessEntityID, EmailAddress, ModifiedDate from inserted 
	end
END

/*
	Actualizar el inventario del producto al vender cada uno de ellos. (Al momento que se confirma y/o cancela la venta).
		o Primero actualizar el status de las ventas con un random entre 1 y 6.
*/

