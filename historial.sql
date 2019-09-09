-- Jose Fuentes - 1168315
-- Axel Rodriguez - 1229715
create or alter function Sales.fn_Compras(@customerId int, @fecha date, @order int)
	returns int
	begin
		declare @countMes as integer
		declare @total as integer
		set @total = 0
		declare @i as integer
		declare @fechaCalc as date

		set @i = -6
		while @i < 0
		begin
			select @fechaCalc = DATEADD(month, @i, @fecha)

			select @countMes = COUNT(detail.ProductID)
			from Sales.SalesOrderHeader header inner join Sales.SalesOrderDetail detail on header.SalesOrderID = detail.SalesOrderID 
			where header.CustomerID = @customerId AND MONTH(header.OrderDate) = MONTH(@fechaCalc) AND YEAR(header.OrderDate) = YEAR(@fechaCalc)
			having COUNT(detail.ProductID) > 1

			if @countMes > 0
			begin
				set @total = @total + 1
			end
			set @i = @i + 1
		end
		return @total
	end;

go

CREATE OR ALTER PROCEDURE USP_Compras
as
begin
	IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Sales.ResumenClientes' and xtype='U')
	begin
		CREATE TABLE Sales.ResumenClientes (
			nombreCliente nvarchar(50),
			actualYear int,
			actualMonth int,
			compras int,
			codigoPrimera int,
			mesesCompra int,
			constraint pk_resumen_clientes primary key (
				nombreCliente, actualYear, actualMonth
			)
		);
	end

	insert into Sales.ResumenClientes (nombreCliente, actualYear, actualMonth, compras, codigoPrimera, mesesCompra) 
	select (person.FirstName + ' ' + person.LastName) as Nombre, YEAR(header.OrderDate) as MyYear, 
	MONTH(header.OrderDate) as MyMonth, COUNT(header.SalesOrderID) as Compras, MIN(header.SalesOrderID) as CodigoPrimeraCompra, SUM(Sales.fn_Compras(header.CustomerID, header.OrderDate, header.SalesOrderID)) as HistoricoCompras
	from Sales.SalesOrderHeader header inner join Sales.Customer customer on header.CustomerID = customer.CustomerID inner join Person.Person person on customer.PersonID = person.BusinessEntityID
	group by (person.FirstName + ' ' + person.LastName), YEAR(header.OrderDate), MONTH(header.OrderDate)
	order by (person.FirstName + ' ' + person.LastName);

end;

go

exec USP_Compras
