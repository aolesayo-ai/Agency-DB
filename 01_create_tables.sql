ALTER TABLE [User]
ADD CONSTRAINT C_User_FirstName_Format
CHECK (
    FirstName LIKE '%[^А-ЩЬЮЯҐЄІЇа-щьюяґєії]%' 
    AND FirstName NOT LIKE '%[0-9!@#\$%\^&*()_+=\[\]{};:".,<>/?\\|~`-]%' Escape '\'

    ); 

    ALTER TABLE [User]
ADD CONSTRAINT CK_User_FirstName_Format
CHECK (
    LastName LIKE '%[^А-ЩЬЮЯҐЄІЇа-щьюяґєії]%' 
    AND LastName NOT LIKE '%[0-9!@#\$%\^&*()_+=\[\]{};:".,<>/?\\|~`-]%' Escape '\'

    ); 

-- Телефон — тільки цифри, пробіли, +, -, дужки
ALTER TABLE [User]
ADD CONSTRAINT C_User_Phone_Format
CHECK (Phone NOT LIKE '%[^0-9+() -]%');

-- Email має містити @ і крапку
ALTER TABLE [User]
ADD CONSTRAINT C_User_Email_Format
CHECK (Email LIKE '%_@_%._%');

-- Кімнати не можуть бути від’ємні
ALTER TABLE Property
ADD CONSTRAINT C_Property_Rooms_Positive
CHECK (Rooms >= 0);

-- Площа має бути більше 0
ALTER TABLE Property
ADD CONSTRAINT C_Property_Area_Positive
CHECK (Area > 0);

-- Ціна має бути не менше 0
ALTER TABLE Property
ADD CONSTRAINT C_Property_Price_Positive
CHECK (Price >= 0);

-- Рейтинг у межах 1–5
ALTER TABLE Feedback
ADD CONSTRAINT C_Feedback_Rating_Range
CHECK (Rating BETWEEN 1 AND 5);

-- Сума платежу має бути > 0
ALTER TABLE Payment
ADD CONSTRAINT C_Payment_Amount_Positive
CHECK (Amount > 0);

ALTER TABLE Property
DROP CONSTRAINT CK__Property__Status__33D4B598;  -- або правильну назву, якщо інша

ALTER TABLE Property
ADD CONSTRAINT CK_Property_Status
CHECK (
    LTRIM(RTRIM(Status)) IN (N'вільно', N'бронь', N'продано', N'оренда')
);

-- Видаляємо старий constraint на Status (якщо він заважає)
ALTER TABLE Property
DROP CONSTRAINT CK_Property_Status;

-- Додаємо новий правильний constraint
ALTER TABLE Property
ADD CONSTRAINT CK_Property_Status
CHECK (LTRIM(RTRIM(Status)) IN (N'вільно', N'бронь', N'продано', N'оренда'));

-- Видаляємо старий constraint на Status (якщо є)
ALTER TABLE Request
DROP CONSTRAINT CK__Request__Status__4222D4EF; -- вказати точну назву constraint

-- Додаємо новий правильний constraint
ALTER TABLE Request
ADD CONSTRAINT CK_Request_Status
CHECK (LTRIM(RTRIM(Status)) IN (N'новий', N'у роботі', N'завершено'));


-- Видаляємо старий constraint на TransactionType
ALTER TABLE [Transaction]
DROP CONSTRAINT IF EXISTS CK__Transacti__Trans__48CFD27E;

-- Додаємо новий правильний constraint
ALTER TABLE [Transaction]
ADD CONSTRAINT CK_Transaction_TransactionType
CHECK (LTRIM(RTRIM(TransactionType)) IN (N'купівля', N'оренда'));


GO

USE MyAgency;
GO

-- =====================================
-- 1. Ролі користувачів (адмін, агент, клієнт)
-- =====================================
CREATE TABLE Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);

-- =====================================
-- 2. Користувачі
-- =====================================
CREATE TABLE [User] (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Phone NVARCHAR(20) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Login NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    RoleID INT NOT NULL,
    AddressID INT NULL
);


-- =====================================
-- 3. Адреси (винесено в окрему таблицю для повторного використання)
-- =====================================
CREATE TABLE Address (
    AddressID INT IDENTITY(1,1) PRIMARY KEY,
    City NVARCHAR(100) NOT NULL,
    District NVARCHAR(100),
    Street NVARCHAR(100) NOT NULL,
    Building NVARCHAR(20),
    Apartment NVARCHAR(20),
    PostalCode NVARCHAR(20)
);

-- =====================================
-- 4. Типи нерухомості (довідник)
-- =====================================
CREATE TABLE PropertyType (
    PropertyTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE -- квартира, будинок, земля, офіс
);

-- =====================================
-- 5. Об’єкти нерухомості
-- =====================================
CREATE TABLE Property (
    PropertyID INT IDENTITY(1,1) PRIMARY KEY,
    PropertyTypeID INT NOT NULL,
    AddressID INT NOT NULL,
    Rooms INT CHECK (Rooms >= 0),
    Area DECIMAL(10,2) CHECK (Area > 0),
    Price DECIMAL(15,2) CHECK (Price >= 0),
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('вільно','бронь','продано','оренда')),
    AgentID INT NULL,
    OwnerID INT NULL,
    Description NVARCHAR(MAX),
    CONSTRAINT FK_Property_Type FOREIGN KEY(PropertyTypeID) REFERENCES PropertyType(PropertyTypeID),
    CONSTRAINT FK_Property_Address FOREIGN KEY(AddressID) REFERENCES Address(AddressID),
    CONSTRAINT FK_Property_Agent FOREIGN KEY(AgentID) REFERENCES [User](UserID),
    CONSTRAINT FK_Property_Owner FOREIGN KEY(OwnerID) REFERENCES [User](UserID)
);

-- =====================================
-- 6. Характеристики (довідник)
-- =====================================
CREATE TABLE Feature (
    FeatureID INT IDENTITY(1,1) PRIMARY KEY,
    FeatureName NVARCHAR(100) NOT NULL UNIQUE
);

-- =====================================
-- 7. Зв’язок "багато-до-багатьох" між об’єктами та характеристиками
-- =====================================
CREATE TABLE PropertyFeature (
    PropertyID INT NOT NULL,
    FeatureID INT NOT NULL,
    PRIMARY KEY (PropertyID, FeatureID),
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    FOREIGN KEY (FeatureID) REFERENCES Feature(FeatureID)
);
--PRIMARY KEY (PropertyID, FeatureID) - забороняє дублювання однієї характеристики для одного об’єкта.

--FOREIGN KEY - забезпечує цілісність даних: PropertyID має існувати у Property, FeatureID має існувати у Feature.

-----Ця таблиця PropertyFeature потрібна для реалізації зв’язку "багато-до-багатьох" між об’єктами нерухомості (Property) і їх характеристиками (Feature).

--Пояснення:

--Property
--Містить усі об’єкти нерухомості (квартири, будинки, офіси тощо).

--Feature
--Містить всі можливі характеристики (балкон, меблі, ліфт, паркінг тощо).

--PropertyFeature

--Кожен об’єкт може мати кілька характеристик.

--Кожна характеристика може бути у кількох об’єктах.

-- потрібна окрема таблиця для зв’язку багато-до-багатьох.

-- =====================================
-- 8. Заявки клієнтів
-- =====================================
CREATE TABLE Request (
    RequestID INT IDENTITY(1,1) PRIMARY KEY,
    ClientID INT NOT NULL,
    PropertyID INT NOT NULL,
    RequestDate DATE NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('новий','у роботі','завершено')),
    CONSTRAINT FK_Request_Client FOREIGN KEY(ClientID) REFERENCES [User](UserID),
    CONSTRAINT FK_Request_Property FOREIGN KEY(PropertyID) REFERENCES Property(PropertyID)
);

-- =====================================
-- 9. Угоди (купівля, оренда)
-- =====================================
CREATE TABLE [Transaction] (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    PropertyID INT NOT NULL,
    ClientID INT NOT NULL,
    AgentID INT NOT NULL,
    TransactionPrice DECIMAL(15,2) CHECK (TransactionPrice >= 0),
    TransactionDate DATE NOT NULL DEFAULT GETDATE(),
    TransactionType NVARCHAR(20) NOT NULL CHECK (TransactionType IN ('купівля','оренда')),
    CONSTRAINT FK_Transaction_Property FOREIGN KEY(PropertyID) REFERENCES Property(PropertyID),
    CONSTRAINT FK_Transaction_Client FOREIGN KEY(ClientID) REFERENCES [User](UserID),
    CONSTRAINT FK_Transaction_Agent FOREIGN KEY(AgentID) REFERENCES [User](UserID)
);
SELECT name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('Transaction');
--CK__Transacti__Trans__46E78A0C
ALTER TABLE [Transaction]
DROP CONSTRAINT CK__Transacti__Trans__46E78A0C;


-- =====================================
-- 10. Типи платежів
-- =====================================
CREATE TABLE PaymentType (
    PaymentTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE  -- аванс, комісія, повна оплата
);

-- =====================================
-- 11. Платежі
-- =====================================
CREATE TABLE Payment (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    TransactionID INT NOT NULL,
    PaymentTypeID INT NOT NULL,
    Amount DECIMAL(15,2) CHECK (Amount > 0),
    PaymentDate DATE NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Payment_Transaction FOREIGN KEY(TransactionID) REFERENCES [Transaction](TransactionID),
    CONSTRAINT FK_Payment_Type FOREIGN KEY(PaymentTypeID) REFERENCES PaymentType(PaymentTypeID)
);

-- =====================================
-- 12. Відгуки
-- =====================================
CREATE TABLE Feedback (
    FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    PropertyID INT NOT NULL,
    FeedbackText NVARCHAR(MAX),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT FK_Feedback_User FOREIGN KEY(UserID) REFERENCES [User](UserID),
    CONSTRAINT FK_Feedback_Property FOREIGN KEY(PropertyID) REFERENCES Property(PropertyID)
);

-- =====================================
-- 13. Документи
-- =====================================
CREATE TABLE Document (
    DocumentID INT IDENTITY(1,1) PRIMARY KEY,
    PropertyID INT NULL,
    TransactionID INT NULL,
    DocumentType NVARCHAR(50) NOT NULL,
    FilePath NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_Document_Property FOREIGN KEY(PropertyID) REFERENCES Property(PropertyID),
    CONSTRAINT FK_Document_Transaction FOREIGN KEY(TransactionID) REFERENCES [Transaction](TransactionID),
    CONSTRAINT CK_Document_OnlyOne CHECK (
        (PropertyID IS NOT NULL AND TransactionID IS NULL) OR
        (PropertyID IS NULL AND TransactionID IS NOT NULL)
    )
);
DROP TABLE IF EXISTS PropertyHistory;


-- =====================================
-- 15. Повідомлення між користувачами
-- =====================================
CREATE TABLE Message (
    MessageID INT IDENTITY(1,1) PRIMARY KEY,
    SenderID INT NOT NULL,
    ReceiverID INT NOT NULL,
    MessageText NVARCHAR(MAX) NOT NULL,
    MessageDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Message_Sender FOREIGN KEY(SenderID) REFERENCES [User](UserID),
    CONSTRAINT FK_Message_Receiver FOREIGN KEY(ReceiverID) REFERENCES [User](UserID)
);

-- =====================================
-- 16. Сповіщення (для користувачів)
-- =====================================
CREATE TABLE Notification (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Message NVARCHAR(255) NOT NULL,
    IsRead BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Notification_User FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- =====================================
-- 17. Обрані об’єкти
-- =====================================
CREATE TABLE Favorite (
    FavoriteID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    PropertyID INT NOT NULL,
    AddedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Favorite_User FOREIGN KEY (UserID) REFERENCES [User](UserID),
    CONSTRAINT FK_Favorite_Property FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID)
);

-- =====================================
-- 18. Статистика агентів
-- =====================================
CREATE TABLE [Statistics] (
    StatID INT IDENTITY(1,1) PRIMARY KEY,
    AgentID INT NOT NULL,
    Month INT CHECK (Month BETWEEN 1 AND 12),
    Year INT CHECK (Year >= 2000),
    DealsCount INT DEFAULT 0 CHECK (DealsCount >= 0),
    CONSTRAINT FK_Statistics_Agent FOREIGN KEY (AgentID) REFERENCES [User](UserID)
);

-- =====================================
-- 19. Логи користувачів (дії в системі)
-- =====================================
CREATE TABLE UserLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    Action NVARCHAR(100),
    TableName NVARCHAR(100),
    RecordID INT,
    ActionDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);



-----------------------------------------------
-- 1. Додавання зовнішніх ключів
-----------------------------------------------

ALTER TABLE [User]
ADD CONSTRAINT FK_User_Role FOREIGN KEY (RoleID)
REFERENCES Role(RoleID);

ALTER TABLE [User]
ADD CONSTRAINT FK_User_Address FOREIGN KEY (AddressID)
REFERENCES Address(AddressID);

ALTER TABLE Property
ADD CONSTRAINT FK_Property_Type FOREIGN KEY (PropertyTypeID)
REFERENCES PropertyType(PropertyTypeID);

ALTER TABLE Property
ADD CONSTRAINT FK_Property_Address FOREIGN KEY (AddressID)
REFERENCES Address(AddressID);

ALTER TABLE Property
ADD CONSTRAINT FK_Property_Agent FOREIGN KEY (AgentID)
REFERENCES [User](UserID);

ALTER TABLE Property
ADD CONSTRAINT FK_Property_Owner FOREIGN KEY (OwnerID)
REFERENCES [User](UserID);

ALTER TABLE Request
ADD CONSTRAINT FK_Request_Client FOREIGN KEY (ClientID)
REFERENCES [User](UserID);

ALTER TABLE Request
ADD CONSTRAINT FK_Request_Property FOREIGN KEY (PropertyID)
REFERENCES Property(PropertyID);

ALTER TABLE [Transaction]
ADD CONSTRAINT FK_Transaction_Property FOREIGN KEY (PropertyID)
REFERENCES Property(PropertyID);

ALTER TABLE [Transaction]
ADD CONSTRAINT FK_Transaction_Client FOREIGN KEY (ClientID)
REFERENCES [User](UserID);

ALTER TABLE [Transaction]
ADD CONSTRAINT FK_Transaction_Agent FOREIGN KEY (AgentID)
REFERENCES [User](UserID);

ALTER TABLE Payment
ADD CONSTRAINT FK_Payment_Transaction FOREIGN KEY (TransactionID)
REFERENCES [Transaction](TransactionID);

ALTER TABLE Payment
ADD CONSTRAINT FK_Payment_Type FOREIGN KEY (PaymentTypeID)
REFERENCES PaymentType(PaymentTypeID);

ALTER TABLE Feedback
ADD CONSTRAINT FK_Feedback_User FOREIGN KEY (UserID)
REFERENCES [User](UserID);

ALTER TABLE Feedback
ADD CONSTRAINT FK_Feedback_Property FOREIGN KEY (PropertyID)
REFERENCES Property(PropertyID);

ALTER TABLE Favorite
ADD CONSTRAINT FK_Favorite_User FOREIGN KEY (UserID)
REFERENCES [User](UserID);

ALTER TABLE Favorite
ADD CONSTRAINT FK_Favorite_Property FOREIGN KEY (PropertyID)
REFERENCES Property(PropertyID);

ALTER TABLE Notification
ADD CONSTRAINT FK_Notification_User FOREIGN KEY (UserID)
REFERENCES [User](UserID);

ALTER TABLE [Statistics]
ADD CONSTRAINT FK_Statistics_Agent FOREIGN KEY (AgentID)
REFERENCES [User](UserID);

ALTER TABLE UserLog
ADD CONSTRAINT FK_UserLog_User FOREIGN KEY (UserID)
REFERENCES [User](UserID);

---------------------------------------
----------------------------------------
---------------------------------------
-- create tables 
