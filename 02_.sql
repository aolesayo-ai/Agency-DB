INSERT INTO Role (RoleName)
VALUES
(N'Адміністратор'),
(N'Агент'),
(N'Клієнт'),
(N'Власник');
INSERT INTO Address (City, District, Street, Building, Apartment, PostalCode)
VALUES
(N'Київ', N'Печерський', N'Лесі Українки', N'10', N'15', N'01001'),
(N'Львів', N'Галицький', N'Дорошенка', N'25', N'8', N'79000'),
(N'Одеса', N'Приморський', N'Дерибасівська', N'7', N'2', N'65000'),
(N'Харків', N'Шевченківський', N'Сумська', N'50', N'11', N'61000');
INSERT INTO [User] (FirstName, LastName, Phone, Email, Login, Password, RoleID, AddressID)
VALUES
(N'Олеся', N'Петренко', N'+380631234567', N'olesya.petrenko@gmail.com', N'olesya', N'pass123', 1, 1),
(N'Андрій', N'Іванов', N'+380671112233', N'andrii.ivanov@gmail.com', N'andrii', N'qwerty', 2, 2),
(N'Марія', N'Шевченко', N'+380931234567', N'maria.shevchenko@gmail.com', N'maria', N'abc123', 3, 3),
(N'Ігор', N'Коваленко', N'+380501234567', N'ihor.kovalenko@gmail.com', N'ihor', N'ihor2024', 4, 4);
INSERT INTO PropertyType (TypeName)
VALUES
(N'Квартира'),
(N'Будинок'),
(N'Офіс'),
(N'Земельна ділянка');

INSERT INTO Property (PropertyTypeID, AddressID, Rooms, Area, Price, Status, AgentID, OwnerID, Description)
VALUES
(1, 1, 2, 55.5, 85000, N'вільно', 1, 2, N'Затишна квартира в центрі Києва'),
(2, 2, 5, 180.0, 250000, N'бронь', 3, 4, N'Просторий приватний будинок з садом'),
(3, 3, 4, 120.0, 500000, N'вільно', 1, 4, N'Офісне приміщення в бізнес-центрі'),
(4, 4, 0, 1000.0, 120000, N'оренда', 3, 2, N'Ділянка біля річки з гарним краєвидом');

INSERT INTO Property (PropertyTypeID, AddressID, Rooms, Area, Price, Status, AgentID, OwnerID, Description)
VALUES
(1, 1, 2, 55.5, 85000, N'вільно', 1, 2, N'Затишна квартира в центрі Києва'),
(2, 2, 5, 180.0, 250000, N'бронь', 2, 3, N'Просторий приватний будинок з садом'),
(3, 3, 4, 120.0, 500000, N'продано', 1, 3, N'Офісне приміщення в бізнес-центрі'),
(4, 4, 0, 1000.0, 120000, N'оренда', 2, 2, N'Ділянка біля річки з гарним краєвидом'),
(1, 1, 3, 75.0, 100000, N'вільно', 1, 2, N'Квартира з ремонтом, поруч парк'),
(2, 2, 6, 200.0, 300000, N'бронь', 2, 3, N'Будинок з гаражем та садом'),
(3, 3, 5, 150.0, 450000, N'продано', 1, 3, N'Офіс у діловому центрі Одеси'),
(4, 4, 0, 1200.0, 150000, N'оренда', 2, 2, N'Земельна ділянка на околиці Харкова');


SELECT * FROM Feature

INSERT INTO Feature (FeatureName) VALUES
(N'Балкон'),
(N'Ліфт'),
(N'Паркінг'),
(N'Сад'),
(N'Охорона'),
(N'Кондиціонер'),
(N'Ремонт'),
(N'Меблі'),
(N'Панорамні вікна');

SELECT * FROM Property;
SELECT * FROM PropertyFeature
SELECT PropertyID, Description FROM Property;
INSERT INTO PropertyFeature (PropertyID, FeatureID)
VALUES
(5, 1),  -- Затишна квартира в центрі Києва -> Балкон
(5, 2),  -- Затишна квартира в центрі Києва -> Ліфт
(6, 1),  -- Просторий приватний будинок -> Балкон
(7, 3),  -- Офісне приміщення -> Паркінг
(8, 2),  -- Ділянка біля річки -> Ліфт (можна інший Feature)
(13, 1), -- Квартира з ремонтом -> Балкон
(14, 4), -- Будинок з гаражем -> Сад
(15, 3), -- Офіс у центрі Одеси -> Паркінг
(16, 5); -- Земельна ділянка -> Охорона

SELECT * FROM  Request

INSERT INTO Property (PropertyTypeID, AddressID, Rooms, Area, Price, Status, AgentID, OwnerID, Description)
VALUES
(1, 1, 2, 55.5, 85000, N'вільно', 1, 2, N'Затишна квартира в центрі Києва'),
(2, 2, 5, 180.0, 250000, N'бронь', 2, 3, N'Просторий приватний будинок з садом'),
(3, 3, 4, 120.0, 500000, N'продано', 1, 3, N'Офісне приміщення в бізнес-центрі'),
(4, 4, 0, 1000.0, 120000, N'оренда', 2, 2, N'Ділянка біля річки з гарним краєвидом'),
(1, 1, 3, 75.0, 100000, N'вільно', 1, 2, N'Квартира з ремонтом, поруч парк'),
(2, 2, 6, 200.0, 300000, N'бронь', 2, 3, N'Будинок з гаражем та садом'),
(3, 3, 5, 150.0, 450000, N'продано', 1, 3, N'Офіс у діловому центрі Одеси'),
(4, 4, 0, 1200.0, 150000, N'оренда', 2, 2, N'Земельна ділянка на околиці Харкова');

INSERT INTO Request (ClientID, PropertyID, Status)
VALUES
(3, 5, N'новий'),
(3, 6, N'у роботі'),
(4, 7, N'завершено'),
(4, 8, N'новий'),
(3, 9, N'новий'),
(2, 10, N'у роботі'),
(1, 11, N'завершено'),
(2, 12, N'новий'),
(3, 13, N'новий'),
(2, 14, N'у роботі'),
(1, 15, N'завершено');

SELECT * FROM PropertyFeature;

INSERT INTO PropertyFeature (PropertyID, FeatureID)
VALUES
(1, 1);  -- Будинок -> Ліфт
(6, 4),  -- Будинок -> Сад
(7, 1),  -- Офіс -> Балкон
(8, 1),  -- Ділянка -> Балкон
(9, 2),  -- Квартира з ремонтом -> Ліфт
(10, 1), -- Будинок з гаражем -> Балкон
(11, 2), -- Офіс у центрі -> Ліфт
(12, 1), -- Земельна ділянка -> Балкон
(13, 2), -- Квартира з ремонтом -> Ліфт
(14, 1), -- Будинок -> Балкон
(15, 2), -- Офіс у Одесі -> Ліфт
(16, 1); -- Земельна ділянка -> Балкон

INSERT INTO PaymentType (TypeName)
VALUES
(N'аванс'),
(N'комісія'),
(N'повна оплата');

INSERT INTO [Transaction] (PropertyID, ClientID, AgentID, TransactionPrice, TransactionType)
VALUES
(5, 3, 1, 85000, N'купівля'),
(6, 3, 2, 250000, N'купівля'),
(7, 4, 1, 500000, N'оренда'),
(8, 4, 2, 120000, N'оренда');

INSERT INTO [Transaction] (PropertyID, ClientID, AgentID, TransactionPrice, TransactionType)
VALUES
(5, 3, 1, 85000, N'купівля'),
(6, 3, 2, 250000, N'купівля'),
(7, 4, 1, 500000, N'оренда'),
(8, 4, 2, 120000, N'оренда');

INSERT INTO Payment (TransactionID, PaymentTypeID, Amount)
VALUES
(1, 1, 30000),
(1, 3, 55000),
(2, 1, 100000),
(2, 3, 150000),
(3, 3, 500000),
(4, 3, 120000);



SELECT * FROM [Transaction];
SELECT * FROM PaymentType;

INSERT INTO Payment (TransactionID, PaymentTypeID, Amount)
VALUES
(4, 6, 30000),  -- аванс по угоді 4
(4, 8, 55000),  -- повна оплата по угоді 4
(5, 6, 100000), -- аванс по угоді 5
(5, 8, 150000), -- повна оплата по угоді 5
(6, 8, 500000), -- повна оплата по угоді 6
(7, 8, 120000); -- повна оплата по угоді 7

INSERT INTO Document (PropertyID, DocumentType, FilePath)
VALUES
(5, N'Договір купівлі-продажу', N'C:\Docs\contract_5.pdf'),
(6, N'Договір купівлі-продажу', N'C:\Docs\contract_6.pdf');

INSERT INTO PropertyHistory (PropertyID, Changes)
VALUES
(5, N'Статус змінено на "вільно"'),
(6, N'Змінено ціну на 250000'),
(7, N'Додано новий ремонт'),
(8, N'Оновлено опис ділянки');

INSERT INTO Message (SenderID, ReceiverID, MessageText)
VALUES
(1, 3, N'Будь ласка, перевір заявку №5'),
(2, 4, N'Клієнт цікавиться будинком'),
(3, 1, N'Підтвердив бронь квартири'),
(4, 2, N'Дякую, угода проведена');

INSERT INTO Notification (UserID, Message, IsRead)
VALUES
(1, N'Нова заявка від клієнта', 0),
(2, N'Клієнт підтвердив бронь', 0),
(3, N'Ваша угода успішно завершена', 0),
(4, N'Отримано нове повідомлення', 0);


INSERT INTO Favorite (UserID, PropertyID)
VALUES
(3, 5),
(3, 6),
(2, 8),
(1, 5),
(4, 7);

INSERT INTO [Statistics] (AgentID, Month, Year, DealsCount)
VALUES
(1, 11, 2025, 3),
(2, 11, 2025, 2),
(1, 10, 2025, 1),
(2, 10, 2025, 1);


INSERT INTO UserLog (UserID, Action, TableName, RecordID)
VALUES
(1, N'Додано нову заявку', N'Request', 5),
(2, N'Оновлено статус угоди', N'[Transaction]', 2),
(3, N'Додав відгук', N'Feedback', 7),
(4, N'Видалив повідомлення', N'Message', 4);

SELECT PropertyID, Description FROM Property;

INSERT INTO Feedback (UserID, PropertyID, FeedbackText, Rating)
VALUES
(1, 5, N'Затишна квартира, агент професійний.', 5),
(2, 6, N'Просторий будинок, все відповідає опису.', 4),
(3, 7, N'Офісне приміщення зручне для роботи.', 5),
(4, 8, N'Ділянка гарна, але трохи далеко від міста.', 3),
(1, 9, N'Квартира затишна, поруч магазини і парк.', 5),
(2, 10, N'Будинок з гаражем, сад великий і доглянутий.', 4),
(3, 11, N'Офіс добре розташований, світлий.', 5),
(4, 12, N'Ділянка велика, але потрібне благоустрій.', 3);



INSERT INTO [User] (FirstName, LastName, Phone, Email, Login, Password, RoleID, AddressID)
VALUES
(N'Ігорї', N'Коваленко', N'+380501234567', N'ihor.kovalenko@gmail.com', N'ihor', N'ihor2024', 3, 4);-- constraints 
