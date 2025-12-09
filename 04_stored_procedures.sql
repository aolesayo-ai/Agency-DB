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
--Тобто один документ належить або об’єкту, або угоді, а не обом одночасно. 
--Тому в деяких рядках є NULL у PropertyID або TransactionID

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

---Всі вільні об’єкти нерухомості
SELECT PropertyID, PropertyTypeID, AddressID, Rooms, Area, Price, Status
FROM Property
WHERE Status = N'вільно';

---Всі заявки конкретного клієнта та інформація про нерухомість
SELECT r.RequestID, r.Status, r.RequestDate, p.PropertyID, p.Price, p.Status AS PropertyStatus
FROM Request AS r
JOIN Property AS p
    ON r.PropertyID = p.PropertyID
WHERE r.ClientID = 3;  -- наприклад клієнт 3

---3 Всі агенти та кількість об’єктів, які вони обслуговують
SELECT u.UserID, u.FirstName + ' ' + u.LastName AS AgentName, COUNT(p.PropertyID) AS PropertyCount
FROM [User] AS u
LEFT JOIN Property AS p
    ON u.UserID = p.AgentID
WHERE u.RoleID = 2  -- RoleID = 2 -> агент
GROUP BY u.UserID, u.FirstName, u.LastName;

---4 Об’єкти нерухомості з їхніми характеристиками (багато-до-багатьох)
SELECT p.PropertyID, p.Description, f.FeatureName
FROM Property AS p
JOIN PropertyFeature AS pf
    ON p.PropertyID = pf.PropertyID
JOIN Feature AS f
    ON pf.FeatureID = f.FeatureID
ORDER BY p.PropertyID;

---5 Платежі по угодах із деталями угоди та клієнта
SELECT pay.PaymentID, t.TransactionID, t.TransactionPrice, u.FirstName + ' ' + u.LastName AS ClientName,
       pt.TypeName AS PaymentType, pay.Amount, pay.PaymentDate
FROM Payment AS pay
JOIN [Transaction] AS t
    ON pay.TransactionID = t.TransactionID
JOIN [User] AS u
    ON t.ClientID = u.UserID
JOIN PaymentType AS pt
    ON pay.PaymentTypeID = pt.PaymentTypeID;

---6 Відгуки клієнтів по об’єктах нерухомості з інформацією про агентів
SELECT f.FeedbackID, f.FeedbackText, f.Rating, u.FirstName + ' ' + u.LastName AS ClientName,
       p.PropertyID, p.Description, a.FirstName + ' ' + a.LastName AS AgentName
FROM Feedback AS f
JOIN [User] AS u
    ON f.UserID = u.UserID
JOIN Property AS p
    ON f.PropertyID = p.PropertyID
JOIN [User] AS a
    ON p.AgentID = a.UserID;

--7 Угоди з сумами платежів та інформацією про тип угоди
SELECT t.TransactionID, t.TransactionType, t.TransactionPrice, u.FirstName + ' ' + u.LastName AS ClientName,
       SUM(pay.Amount) AS TotalPaid
FROM [Transaction] AS t
JOIN [User] AS u
    ON t.ClientID = u.UserID
JOIN Payment AS pay
    ON t.TransactionID = pay.TransactionID
GROUP BY t.TransactionID, t.TransactionType, t.TransactionPrice, u.FirstName, u.LastName;


--=============================================================================--
CREATE OR ALTER PROCEDURE dbo.sp_GetPropertyType
    @PropertyTypeID INT = NULL,
    @TypeName NVARCHAR(50) = NULL,
    @PageSize INT = 20,
    @PageNumber INT = 1,
    @SortColumn VARCHAR(128) = 'PropertyTypeID',
    @SortDirection BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageSize <= 0 SET @PageSize = 20;
    IF @PageNumber <= 0 SET @PageNumber = 1;

    SELECT PropertyTypeID, TypeName
    FROM PropertyType
    WHERE 
        (@PropertyTypeID IS NULL OR PropertyTypeID = @PropertyTypeID)
        AND (@TypeName IS NULL OR TypeName LIKE @TypeName + N'%')

    ORDER BY
        CASE WHEN @SortColumn = 'PropertyTypeID' AND @SortDirection = 0 THEN PropertyTypeID END ASC,
        CASE WHEN @SortColumn = 'PropertyTypeID' AND @SortDirection = 1 THEN PropertyTypeID END DESC,
        CASE WHEN @SortColumn = 'TypeName' AND @SortDirection = 0 THEN TypeName END ASC,
        CASE WHEN @SortColumn = 'TypeName' AND @SortDirection = 1 THEN TypeName END DESC

    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO
EXEC dbo.sp_GetPropertyType 
    @TypeName = N'к';
EXEC dbo.sp_GetPropertyType
    @SortColumn = 'TypeName',
    @SortDirection = 0; -- ASC
--Повертає перші 2 рядки (пагінація).
--Тобто працює як сторінки у веб-додатку.
EXEC dbo.sp_GetPropertyType
    @PageSize = 2,
    @PageNumber = 1;
CREATE OR ALTER PROCEDURE dbo.sp_GetFeature
    @FeatureID INT = NULL,
    @FeatureName NVARCHAR(100) = NULL,
    @PageSize INT = 20,
    @PageNumber INT = 1,
    @SortColumn VARCHAR(128) = 'FeatureID',
    @SortDirection BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageSize <= 0 SET @PageSize = 20;
    IF @PageNumber <= 0 SET @PageNumber = 1;

    SELECT FeatureID, FeatureName
    FROM Feature
    WHERE 
        (@FeatureID IS NULL OR FeatureID = @FeatureID)
        AND (@FeatureName IS NULL OR FeatureName LIKE @FeatureName + N'%')

    ORDER BY
        CASE WHEN @SortColumn = 'FeatureID' AND @SortDirection = 0 THEN FeatureID END ASC,
        CASE WHEN @SortColumn = 'FeatureID' AND @SortDirection = 1 THEN FeatureID END DESC,
        CASE WHEN @SortColumn = 'FeatureName' AND @SortDirection = 0 THEN FeatureName END ASC,
        CASE WHEN @SortColumn = 'FeatureName' AND @SortDirection = 1 THEN FeatureName END DESC

    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO
EXEC dbo.sp_GetFeature;
EXEC dbo.sp_GetFeature 
    @FeatureID = 1;
EXEC dbo.sp_GetFeature 
    @FeatureName = N'б';
EXEC dbo.sp_GetFeature
    @SortColumn = 'FeatureName',
    @SortDirection = 0;   -- ASC
EXEC dbo.sp_GetFeature
    @FeatureName = N'л',
    @SortColumn = 'FeatureName',
    @SortDirection = 0,
    @PageSize = 5,
    @PageNumber = 1;

CREATE OR ALTER PROCEDURE dbo.sp_GetRole
    @RoleID INT = NULL,
    @RoleName NVARCHAR(50) = NULL,
    @PageSize INT = 20,
    @PageNumber INT = 1,
    @SortColumn VARCHAR(128) = 'RoleID',
    @SortDirection BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageSize <= 0 SET @PageSize = 20;
    IF @PageNumber <= 0 SET @PageNumber = 1;

    SELECT RoleID, RoleName
    FROM Role
    WHERE
        (@RoleID IS NULL OR RoleID = @RoleID)
        AND (@RoleName IS NULL OR RoleName LIKE @RoleName + N'%')

    ORDER BY
        CASE WHEN @SortColumn = 'RoleID' AND @SortDirection = 0 THEN RoleID END ASC,
        CASE WHEN @SortColumn = 'RoleID' AND @SortDirection = 1 THEN RoleID END DESC,
        CASE WHEN @SortColumn = 'RoleName' AND @SortDirection = 0 THEN RoleName END ASC,
        CASE WHEN @SortColumn = 'RoleName' AND @SortDirection = 1 THEN RoleName END DESC

    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

EXEC dbo.sp_GetRole 
    @RoleID = 1;
EXEC dbo.sp_GetRole;
EXEC dbo.sp_GetRole 
    @RoleName = N'а'; 

EXEC dbo.sp_GetRole
    @PageSize = 2,
    @PageNumber = 1;


CREATE OR ALTER PROCEDURE dbo.sp_GetPaymentType
    @PaymentTypeID INT = NULL,
    @TypeName NVARCHAR(50) = NULL,
    @PageSize INT = 20,
    @PageNumber INT = 1,
    @SortColumn VARCHAR(128) = 'PaymentTypeID',
    @SortDirection BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageSize <= 0 SET @PageSize = 20;
    IF @PageNumber <= 0 SET @PageNumber = 1;

    SELECT PaymentTypeID, TypeName
    FROM PaymentType
    WHERE 
        (@PaymentTypeID IS NULL OR PaymentTypeID = @PaymentTypeID)
        AND (@TypeName IS NULL OR TypeName LIKE @TypeName + N'%')

    ORDER BY
        CASE WHEN @SortColumn = 'PaymentTypeID' AND @SortDirection = 0 THEN PaymentTypeID END ASC,
        CASE WHEN @SortColumn = 'PaymentTypeID' AND @SortDirection = 1 THEN PaymentTypeID END DESC,
        CASE WHEN @SortColumn = 'TypeName' AND @SortDirection = 0 THEN TypeName END ASC,
        CASE WHEN @SortColumn = 'TypeName' AND @SortDirection = 1 THEN TypeName END DESC

    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO
EXEC dbo.sp_GetPaymentType;
EXEC dbo.sp_GetPaymentType @TypeName = N'а';
EXEC dbo.sp_GetPaymentType @PageSize = 2, @PageNumber = 1;
EXEC dbo.sp_GetPaymentType @SortColumn = 'TypeName', @SortDirection = 0;
---
CREATE OR ALTER PROCEDURE dbo.sp_GetCompletedDeal
    @ClientID INT = NULL,
    @PropertyID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.TransactionID,
        t.TransactionDate,
        t.TransactionPrice,
        t.TransactionType,

        -------------------------------------------------------------------
        -- CLIENT (покупець)
        -------------------------------------------------------------------
        c.UserID AS ClientID,
        c.FirstName AS ClientFirstName,
        c.LastName AS ClientLastName,

        -------------------------------------------------------------------
        -- AGENT (посередник)
        -------------------------------------------------------------------
        a.UserID AS AgentID,
        a.FirstName AS AgentFirstName,
        a.LastName AS AgentLastName,

        -------------------------------------------------------------------
        -- OWNER (власник нерухомості – продавець)
        -------------------------------------------------------------------
        o.UserID AS OwnerID,
        o.FirstName AS OwnerFirstName,
        o.LastName AS OwnerLastName,

        -------------------------------------------------------------------
        -- PROPERTY DETAILS
        -------------------------------------------------------------------
        p.PropertyID,
        pt.TypeName AS PropertyType,
        p.Rooms,
        p.Area,
        p.Price AS ListedPrice,
        p.Status,

        -------------------------------------------------------------------
        -- ADDRESS
        -------------------------------------------------------------------
        adr.City,
        adr.Street,
        adr.Building,
        adr.Apartment,

        -------------------------------------------------------------------
        -- FEATURES
        -------------------------------------------------------------------
        STUFF((SELECT ', ' + f.FeatureName
            FROM PropertyFeature pf
            JOIN Feature f ON pf.FeatureID = f.FeatureID
            WHERE pf.PropertyID = p.PropertyID
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS Features

    FROM [Transaction] t
    JOIN [User] c ON t.ClientID = c.UserID           -- покупець
    JOIN [User] a ON t.AgentID = a.UserID            -- агент
    JOIN Property p ON t.PropertyID = p.PropertyID   -- нерухомість
    JOIN PropertyType pt ON p.PropertyTypeID = pt.PropertyTypeID
    JOIN Address adr ON p.AddressID = adr.AddressID
    LEFT JOIN [User] o ON p.OwnerID = o.UserID       -- власник (продавець)

    WHERE
        (@ClientID IS NULL OR t.ClientID = @ClientID)
        AND (@PropertyID IS NULL OR t.PropertyID = @PropertyID)
        AND t.TransactionType = N'купівля';
END;
GO
--Хто купив квартиру 2 і у кого?
EXEC sp_GetCompletedDeal @PropertyID = 2;
--Усі покупки клієнта 14 (і всі продавці)
EXEC sp_GetCompletedDeal @ClientID = 14;
--
EXEC sp_GetCompletedDeal @ClientID = 3, @PropertyID = 2;



















-- stored procedures 
