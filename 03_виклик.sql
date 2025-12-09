USE MyAgency;
GO

-- 1. Ролі користувачів
SELECT * FROM Role;

-- 2. Користувачі
SELECT * FROM [User];

-- 3. Адреси
SELECT * FROM Address;

-- 4. Типи нерухомості
SELECT * FROM PropertyType;

-- 5. Об’єкти нерухомості
SELECT * FROM Property;

-- 6. Характеристики
SELECT * FROM Feature;

-- 7. Зв’язок "багато-до-багатьох" між об’єктами та характеристиками
SELECT * FROM PropertyFeature;

-- 8. Заявки клієнтів
SELECT * FROM Request;

-- 9. Угоди (Transaction)
SELECT * FROM [Transaction];

-- 10. Типи платежів
SELECT * FROM PaymentType;

-- 11. Платежі
SELECT * FROM Payment;

-- 12. Відгуки
SELECT * FROM Feedback;

-- 13. Документи
SELECT * FROM Document;

-- 14. Історія змін по об’єктах
SELECT * FROM PropertyHistory;

-- 15. Повідомлення між користувачами
SELECT * FROM Message;

-- 16. Сповіщення для користувачів
SELECT * FROM Notification;

-- 17. Обрані об’єкти
SELECT * FROM Favorite;

-- 18. Статистика агентів
SELECT * FROM [Statistics];

-- 19. Логи користувачів
SELECT * FROM UserLog;

---. LEFT JOIN: показати всі об’єкти нерухомості, навіть якщо по них немає відгуків
---показує нерухомість і відгуки, якщо вони є, якщо немає — відгук буде NULL
SELECT 
    p.PropertyID,
    pt.TypeName AS PropertyType,
    p.Price,
    f.Rating,
    f.FeedbackText
FROM Property AS p
LEFT JOIN Feedback AS f ON p.PropertyID = f.PropertyID
JOIN PropertyType AS pt ON p.PropertyTypeID = pt.PropertyTypeID;
--------------
--------------
--LEFT JOIN: список клієнтів і їхні заявки (навіть якщо немає заявки)
---Навіщо: бачимо всіх клієнтів і хто з них взагалі нічого не замовляв.
SELECT 
    u.UserID,
    u.FirstName + ' ' + u.LastName AS ClientName,
    r.RequestID,
    r.Status AS RequestStatus
FROM [User] AS u
LEFT JOIN Request AS r ON u.UserID = r.ClientID
WHERE u.RoleID = 3;   -- припустимо, 3 = клієнт
----3. RIGHT JOIN: всі платежі, навіть якщо деякі транзакції були видалені/не існують
-----RIGHT JOIN рідко потрібен, але для демонстрації:
SELECT
    t.TransactionID,
    t.TransactionType,
    p.PaymentID,
    p.Amount
FROM [Transaction] AS t
RIGHT JOIN Payment AS p 
    ON t.TransactionID = p.TransactionID;

------4. RIGHT JOIN: всі нерухомості навіть якщо агент помилково видалений
----Навіщо: знайти об’єкти, які "висять" без агента.
SELECT
    u.FirstName + ' ' + u.LastName AS AgentName,
    pr.PropertyID,
    pr.Status
FROM [User] AS u
RIGHT JOIN Property AS pr ON u.UserID = pr.AgentID;

---5. FULL JOIN: всі об’єкти й всі заявки, навіть якщо вони не пов’язані
--об’єкти без заявок і заявки без об’єктів

SELECT
    p.PropertyID,
    p.Status AS PropertyStatus,
    r.RequestID,
    r.Status AS RequestStatus
FROM Property AS p
FULL JOIN Request AS r 
    ON p.PropertyID = r.PropertyID;
---Навіщо:

--які об’єкти не цікавлять клієнтів

--які заявки зроблені на видалені/неіснуючі об’єкти

------
--6. FULL JOIN: всі агенти та всі транзакції (навіть непов’язані)
SELECT
    ag.UserID AS AgentID,
    ag.FirstName + ' ' + ag.LastName AS AgentName,
    t.TransactionID,
    t.TransactionType
FROM [User] AS ag
FULL JOIN [Transaction] AS t ON ag.UserID = t.AgentID
WHERE ag.RoleID = 2 OR ag.RoleID IS NULL;

--Навіщо:

--знайти агентів, які не провели жодної угоди

--знайти угоди без агента (аномалія)

--=============================================================================================
--1. Перетворення таблиці Property на SYSTEM-VERSIONED--
ALTER TABLE Property ADD
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_Property_ValidFrom DEFAULT SYSUTCDATETIME(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_Property_ValidTo DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO
--
ALTER TABLE Property
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Property_History));
GO
-------------------------------------------------------------------------------------------
SELECT *
FROM Property
FOR SYSTEM_TIME ALL
ORDER BY PropertyID, ValidFrom;

SELECT UserID, FirstName, LastName, Phone, Login, ValidFrom, ValidTo
FROM [User] FOR SYSTEM_TIME ALL
WHERE UserID = 2
ORDER BY ValidFrom;

UPDATE [User]
SET Phone = '380500000000'
WHERE UserID = 1;

UPDATE [User]
SET Email = 'new_mail@gmail.com'
WHERE UserID = 2;


---Який агент був закріплений за кожним об’єктом нерухомості станом на 10:47
SELECT p.PropertyID, u.FirstName + ' ' + u.LastName AS AgentName
FROM Property FOR SYSTEM_TIME AS OF '2025-11-17 10:47:00' AS p
JOIN [User] FOR SYSTEM_TIME AS OF '2025-11-17 10:47:00' AS u
    ON p.AgentID = u.UserID;

SELECT PropertyID, AgentID, ValidFrom, ValidTo
FROM Property FOR SYSTEM_TIME ALL
ORDER BY PropertyID, ValidFrom;


-------------------------------------------------------------------------------
---2) !!!!!!!!! Перетворення таблиці User на SYSTEM-VERSIONED !!!!!!!!!!
ALTER TABLE [User] ADD
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_User_ValidFrom DEFAULT SYSUTCDATETIME(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_User_ValidTo DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO
---
ALTER TABLE [User]
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.User_History));
GO
-------------------------------------------------------------------------

---Перевір поточні дані
SELECT PropertyID, Price, ValidFrom, ValidTo
FROM Property
ORDER BY PropertyID;
---Виконай ЗМІНУ ЦІНИ (UPDATE)
UPDATE Property
SET Price = 360000.00
WHERE PropertyID = 8;
---Переглянути ІСТОРИЧНІ версії
SELECT 
    PropertyID,
    Price,
    ValidFrom,
    ValidTo
FROM Property
FOR SYSTEM_TIME ALL
WHERE PropertyID = 8
ORDER BY ValidFrom;
----------------------------------------------------------------------------------
--- ALTER TABLE dbo.Request ADD
ALTER TABLE dbo.Request ADD
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_Request_ValidFrom DEFAULT SYSUTCDATETIME(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_Request_ValidTo DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO

ALTER TABLE dbo.Request
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Request_History));
GO
-----------------------------------------------------------------
UPDATE Request
SET Status = N'у роботі'
WHERE RequestID = 1;

-- Через кілька хвилин/секунд змінюємо знову
UPDATE Request
SET Status = N'завершено'
WHERE RequestID = 1;

SELECT *
FROM dbo.Request
FOR SYSTEM_TIME ALL
WHERE RequestID = 1
ORDER BY ValidFrom;


---------------------------------------
----------------------------------------
---------------------------------------
--1) sp_SetUser
CREATE OR ALTER PROCEDURE dbo.sp_SetUser
    @UserID INT = NULL OUTPUT,
    @FirstName NVARCHAR(50) = NULL,
    @LastName NVARCHAR(50) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Email NVARCHAR(100) = NULL,
    @Login NVARCHAR(50) = NULL,
    @Password NVARCHAR(100) = NULL,
    @RoleID INT = NULL,
    @AddressID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        ------------------------------------------------------
        -- 1. Перевірка обов’язкових полів — тільки INSERT
        ------------------------------------------------------
        IF @UserID IS NULL  -- INSERT
        BEGIN
            IF (@FirstName IS NULL OR LTRIM(RTRIM(@FirstName)) = '')
                THROW 50001, 'FirstName cannot be empty for INSERT.', 1;

            IF (@LastName IS NULL OR LTRIM(RTRIM(@LastName)) = '')
                THROW 50002, 'LastName cannot be empty for INSERT.', 1;

            IF (@Phone IS NULL OR LTRIM(RTRIM(@Phone)) = '')
                THROW 50003, 'Phone cannot be empty for INSERT.', 1;

            IF (@Email IS NULL OR LTRIM(RTRIM(@Email)) = '')
                THROW 50004, 'Email cannot be empty for INSERT.', 1;

            IF (@Login IS NULL OR LTRIM(RTRIM(@Login)) = '')
                THROW 50005, 'Login cannot be empty for INSERT.', 1;

            IF (@Password IS NULL OR LTRIM(RTRIM(@Password)) = '')
                THROW 50006, 'Password cannot be empty for INSERT.', 1;
        END


        ------------------------------------------------------
        -- 2. INSERT
        ------------------------------------------------------
        IF @UserID IS NULL
        BEGIN
            INSERT INTO [User] 
                (FirstName, LastName, Phone, Email, Login, Password, RoleID, AddressID)
            VALUES 
                (@FirstName, @LastName, @Phone, @Email, @Login, @Password, @RoleID, @AddressID);

            SET @UserID = SCOPE_IDENTITY();
        END
        
        ------------------------------------------------------
        -- 3. UPDATE
        ------------------------------------------------------
        ELSE
        BEGIN
            UPDATE [User]
            SET 
                FirstName = ISNULL(@FirstName, FirstName),
                LastName  = ISNULL(@LastName, LastName),
                Phone     = ISNULL(@Phone, Phone),
                Email     = ISNULL(@Email, Email),
                Login     = ISNULL(@Login, Login),
                Password  = ISNULL(@Password, Password),
                RoleID    = ISNULL(@RoleID, RoleID),
                AddressID = ISNULL(@AddressID, AddressID)
            WHERE UserID = @UserID;

            IF @@ROWCOUNT = 0 
                THROW 50007, 'UserID not found for UPDATE.', 1;
        END

    END TRY

    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

--приклад
DECLARE @id INT;
EXEC sp_SetUser
    @UserID = @id OUTPUT,
    @FirstName = N'Фін',
    @LastName = N'Вулфхарт',
    @Phone = N'+380501112232',
    @Email = N'oles@example.com',
    @Login = N'olya2',
    @Password = N'pass125',
    @RoleID = 3;
SELECT @id AS NewUserID;
--
EXEC sp_SetUser
    @UserID = 14,
    @Phone = N'+380501234567';

--2) sp_SetAddress
CREATE OR ALTER PROCEDURE dbo.sp_SetAddress
    @AddressID INT = NULL OUTPUT,
    @City NVARCHAR(100) = NULL,
    @District NVARCHAR(100) = NULL,
    @Street NVARCHAR(100) = NULL,
    @Building NVARCHAR(20) = NULL,
    @Apartment NVARCHAR(20) = NULL,
    @PostalCode NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF (@City IS NULL OR LTRIM(RTRIM(@City)) = '')
            THROW 50010, 'City cannot be empty.', 1;

        IF (@Street IS NULL OR LTRIM(RTRIM(@Street)) = '')
            THROW 50011, 'Street cannot be empty.', 1;

        -- INSERT
        IF @AddressID IS NULL
        BEGIN
            INSERT INTO Address (City, District, Street, Building, Apartment, PostalCode)
            VALUES (@City, @District, @Street, @Building, @Apartment, @PostalCode);

            SET @AddressID = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE Address
            SET City = ISNULL(@City, City),
                District = ISNULL(@District, District),
                Street = ISNULL(@Street, Street),
                Building = ISNULL(@Building, Building),
                Apartment = ISNULL(@Apartment, Apartment),
                PostalCode = ISNULL(@PostalCode, PostalCode)
            WHERE AddressID = @AddressID;

            IF @@ROWCOUNT = 0
                THROW 50012, 'AddressID not found.', 1;
        END
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
--приклад
DECLARE @addr INT;
EXEC sp_SetAddress
    @AddressID = @addr OUTPUT,
    @City = N'Івано-Франківськ',
    @Street = N'Галицька',
    @Building = N'12';
SELECT @addr AS NewAddressID;
--3) sp_SetProperty
CREATE OR ALTER PROCEDURE dbo.sp_SetProperty
    @PropertyID INT = NULL OUTPUT,
    @PropertyTypeID INT = NULL,
    @AddressID INT = NULL,
    @Rooms INT = NULL,
    @Area DECIMAL(10,2) = NULL,
    @Price DECIMAL(15,2) = NULL,
    @Status NVARCHAR(20) = NULL,
    @AgentID INT = NULL,
    @OwnerID INT = NULL,
    @Description NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Required
        IF @PropertyTypeID IS NULL THROW 50020, 'PropertyTypeID required.', 1;
        IF @AddressID IS NULL THROW 50021, 'AddressID required.', 1;

        -- Status validation
        IF @Status NOT IN (N'вільно', N'бронь', N'продано', N'оренда')
            THROW 50022, 'Invalid Status value.', 1;

        -- INSERT
        IF @PropertyID IS NULL
        BEGIN
            INSERT INTO Property
                (PropertyTypeID, AddressID, Rooms, Area, Price, Status, AgentID, OwnerID, Description)
            VALUES
                (@PropertyTypeID, @AddressID, @Rooms, @Area, @Price, @Status, @AgentID, @OwnerID, @Description);

            SET @PropertyID = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE Property
            SET PropertyTypeID = ISNULL(@PropertyTypeID, PropertyTypeID),
                AddressID = ISNULL(@AddressID, AddressID),
                Rooms = ISNULL(@Rooms, Rooms),
                Area = ISNULL(@Area, Area),
                Price = ISNULL(@Price, Price),
                Status = ISNULL(@Status, Status),
                AgentID = ISNULL(@AgentID, AgentID),
                OwnerID = ISNULL(@OwnerID, OwnerID),
                Description = ISNULL(@Description, Description)
            WHERE PropertyID = @PropertyID;

            IF @@ROWCOUNT = 0
                THROW 50023, 'PropertyID not found.', 1;
        END
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
--приклад
DECLARE @pid INT;
EXEC sp_SetProperty
    @PropertyID = @pid OUTPUT,
    @PropertyTypeID = 1,
    @AddressID = 3,
    @Rooms = 2,
    @Area = 56.5,
    @Price = 75000,
    @Status = N'вільно';
SELECT @pid AS NewPropertyID;
--4) sp_SetRequest
CREATE OR ALTER PROCEDURE dbo.sp_SetRequest
    @RequestID INT = NULL OUTPUT,
    @ClientID INT = NULL,
    @PropertyID INT = NULL,
    @RequestDate DATE = NULL,
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Required
        IF @ClientID IS NULL THROW 51001, 'ClientID is required.', 1;
        IF @PropertyID IS NULL THROW 51002, 'PropertyID is required.', 1;

        -- Status validation
        IF @Status NOT IN (N'новий', N'у роботі', N'завершено')
            THROW 51003, 'Invalid Status value.', 1;

        IF @RequestDate IS NULL
            SET @RequestDate = GETDATE();

        -- INSERT
        IF @RequestID IS NULL
        BEGIN
            INSERT INTO Request (ClientID, PropertyID, RequestDate, Status)
            VALUES (@ClientID, @PropertyID, @RequestDate, @Status);

            SET @RequestID = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE Request
            SET ClientID = ISNULL(@ClientID, ClientID),
                PropertyID = ISNULL(@PropertyID, PropertyID),
                RequestDate = ISNULL(@RequestDate, RequestDate),
                Status = ISNULL(@Status, Status)
            WHERE RequestID = @RequestID;

            IF @@ROWCOUNT = 0
                THROW 51004, 'RequestID not found.', 1;
        END
    END TRY

    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
--приклад
DECLARE @r INT;
EXEC sp_SetRequest
    @RequestID = @r OUTPUT,
    @ClientID = 5,
    @PropertyID = 8,
    @Status = N'у роботі';
SELECT @r AS NewRequestID;
--5) sp_SetTransaction
CREATE OR ALTER PROCEDURE dbo.sp_SetTransaction
    @TransactionID INT = NULL OUTPUT,
    @PropertyID INT = NULL,
    @ClientID INT = NULL,
    @AgentID INT = NULL,
    @TransactionPrice DECIMAL(15,2) = NULL,
    @TransactionDate DATE = NULL,
    @TransactionType NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Required
        IF @PropertyID IS NULL THROW 52001, 'PropertyID is required.', 1;
        IF @ClientID IS NULL THROW 52002, 'ClientID is required.', 1;
        IF @AgentID IS NULL THROW 52003, 'AgentID is required.', 1;

        IF @TransactionPrice IS NULL OR @TransactionPrice < 0
            THROW 52004, 'Invalid TransactionPrice.', 1;

        -- Type validation
        IF @TransactionType NOT IN (N'купівля', N'оренда')
            THROW 52005, 'Invalid TransactionType.', 1;

        IF @TransactionDate IS NULL
            SET @TransactionDate = GETDATE();

        -- INSERT
        IF @TransactionID IS NULL
        BEGIN
            INSERT INTO [Transaction]
                (PropertyID, ClientID, AgentID, TransactionPrice, TransactionDate, TransactionType)
            VALUES
                (@PropertyID, @ClientID, @AgentID, @TransactionPrice, @TransactionDate, @TransactionType);

            SET @TransactionID = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE [Transaction]
            SET PropertyID = ISNULL(@PropertyID, PropertyID),
                ClientID = ISNULL(@ClientID, ClientID),
                AgentID = ISNULL(@AgentID, AgentID),
                TransactionPrice = ISNULL(@TransactionPrice, TransactionPrice),
                TransactionDate = ISNULL(@TransactionDate, TransactionDate),
                TransactionType = ISNULL(@TransactionType, TransactionType)
            WHERE TransactionID = @TransactionID;

            IF @@ROWCOUNT = 0
                THROW 52006, 'TransactionID not found.', 1;
        END
    END TRY

    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
--приклад
DECLARE @t INT;
EXEC sp_SetTransaction
    @TransactionID = @t OUTPUT,
    @PropertyID = 3,
    @ClientID = 14,
    @AgentID = 2,
    @TransactionPrice = 82000,
    @TransactionType = N'купівля';
SELECT @t AS NewTransactionID;
--6) sp_SetPayment
CREATE OR ALTER PROCEDURE dbo.sp_SetPayment
    @PaymentID INT = NULL OUTPUT,
    @TransactionID INT = NULL,
    @PaymentTypeID INT = NULL,
    @Amount DECIMAL(15,2) = NULL,
    @PaymentDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @TransactionID IS NULL
            THROW 53001, 'TransactionID is required.', 1;

        IF @PaymentTypeID IS NULL
            THROW 53002, 'PaymentTypeID is required.', 1;

        IF @Amount IS NULL OR @Amount <= 0
            THROW 53003, 'Payment amount must be > 0.', 1;

        IF @PaymentDate IS NULL
            SET @PaymentDate = GETDATE();

        -- INSERT
        IF @PaymentID IS NULL
        BEGIN
            INSERT INTO Payment (TransactionID, PaymentTypeID, Amount, PaymentDate)
            VALUES (@TransactionID, @PaymentTypeID, @Amount, @PaymentDate);

            SET @PaymentID = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE Payment
            SET TransactionID = ISNULL(@TransactionID, TransactionID),
                PaymentTypeID = ISNULL(@PaymentTypeID, PaymentTypeID),
                Amount = ISNULL(@Amount, Amount),
                PaymentDate = ISNULL(@PaymentDate, PaymentDate)
            WHERE PaymentID = @PaymentID;

            IF @@ROWCOUNT = 0
                THROW 53004, 'PaymentID not found.', 1;
        END
    END TRY

    BEGIN CATCH
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
--приклад
DECLARE @pay INT;
EXEC sp_SetPayment
    @PaymentID = @pay OUTPUT,
    @TransactionID = 3,
    @PaymentTypeID = 1,
    @Amount = 5000;
SELECT @pay AS NewPaymentID;
---

-- triggers 
