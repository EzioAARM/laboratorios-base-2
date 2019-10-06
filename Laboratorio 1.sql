-- Axel Rodriguez y Salvador Grave

CREATE OR ALTER PROCEDURE UPS_DetailVentas
	@ProductId AS INTEGER,
	@OrderHeaderId AS INTEGER
AS
BEGIN
	BEGIN TRY
		SAVE TRANSACTION DetailBeforeInsert;
		DECLARE @RandQty AS INTEGER;
		DECLARE @FinishedFlag AS BIT;
		DECLARE @ListPrice AS MONEY;
		SELECT @FinishedFlag = FinishedGoodsFlag, @ListPrice = ListPrice FROM Production.Product WHERE ProductID = @ProductId;
		IF @FinishedFlag = 1
		BEGIN
			SELECT @RandQty = FLOOR(RAND()*(15-1+1)+1);
			INSERT INTO Sales.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, SpecialOfferID, UnitPrice) VALUES 
				(@OrderHeaderId, @RandQty, @ProductId, 1, @ListPrice);
			SAVE TRANSACTION DetailAfterInsert;
		END
		ELSE
		BEGIN
			PRINT 'No es producto terminado';
			ROLLBACK TRANSACTION DetailBeforeInsert;
		END
	END TRY
	BEGIN CATCH
		PRINT 'No se encontro producto';
		ROLLBACK TRANSACTION DetailBeforeInsert;
	END CATCH
END
GO
CREATE OR ALTER PROCEDURE USP_HeaderVentas
	@RevisionNumber AS INTEGER,
	@DueDate AS DATETIME,
	@ShipDate AS DATETIME,
	@Status AS INTEGER,
	@OnlineOrderFlag AS BIT,
	@PurchaseOrderNumber AS NVARCHAR(25),
	@AccountNumber AS NVARCHAR(25),
	@CustomerId AS INTEGER,
	@SalesPersonId AS INTEGER,
	@TerritoryId AS INTEGER,
	@BillToAddressId AS INTEGER,
	@ShipToAddressId AS INTEGER,
	@ShipMethodId AS INTEGER,
	@CreditCardId AS INTEGER,
	@CreditCardApprovalCode AS NVARCHAR(25),
	@ProductQuantity AS INTEGER
AS
BEGIN
	BEGIN TRANSACTION;
	ALTER TABLE Sales.SalesOrderDetail DISABLE TRIGGER iduSalesOrderDetail;
	INSERT INTO Sales.SalesOrderHeader (RevisionNumber, DueDate, ShipDate, Status, OnlineOrderFlag, PurchaseOrderNumber, AccountNumber,
		CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode) VALUES 
		(@RevisionNumber, @DueDate, @ShipDate, @Status, @OnlineOrderFlag, @PurchaseOrderNumber, @AccountNumber,
		@CustomerID, @SalesPersonID, @TerritoryID, @BillToAddressID, @ShipToAddressID, @ShipMethodID, @CreditCardID, @CreditCardApprovalCode);

	DECLARE @i AS INTEGER;
	SET @i = 0;
	SAVE TRAN SalesOrderHeaderCheckpoint;
	DECLARE @Correctos AS NVARCHAR(MAX);
	DECLARE @Erroneos AS NVARCHAR(MAX);
	DECLARE @RandomProductId AS INTEGER;
	DECLARE @OrderHeaderId AS INTEGER;
	SELECT @OrderHeaderId = MAX(SalesOrderID) FROM Sales.SalesOrderHeader;
	WHILE (@i < @ProductQuantity)
	BEGIN
		SELECT @RandomProductId = FLOOR(RAND()*(1500-500+1)+500);
		BEGIN TRY
			EXEC UPS_DetailVentas @RandomProductId, @OrderHeaderId
			PRINT @i
			SET @Correctos = @Correctos + CONVERT(NVARCHAR(50), @RandomProductId);
		END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE() AS ErrorMsg;
			SET @Erroneos = @Erroneos + CONVERT(NVARCHAR(50), @RandomProductId);
		END CATCH
		SET @i = @i + 1;
	END;
	DECLARE @OrderTotal AS MONEY;
	SELECT @OrderTotal = SUM(LineTotal) FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderHeaderId;
	UPDATE Sales.SalesOrderHeader SET SubTotal = @OrderTotal WHERE SalesOrderID = @OrderHeaderId;
	PRINT 'Se insertaron correctamente: ' + @Correctos;
	PRINT 'No se insertaron correctamente: ' + @Erroneos;
	COMMIT;
END;

GO
DECLARE @t1 AS DATETIME
SELECT @t1 = DATEADD(DAY, 5, GETDATE());

DECLARE @t2 AS DATETIME
SELECT @t2 = GETDATE();
EXEC USP_HeaderVentas 10, @t1, @t1, 5, 0, 'asdfasdfasdf', 'asfasdfasdf', 29825, 279, 5, 985, 985, 5, 16281, 'asdfasdf', 100
