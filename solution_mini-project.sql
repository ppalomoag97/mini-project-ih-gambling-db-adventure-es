USE gambling;

SELECT count(*)
FROM account;

-- Pregunta 01: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre Título, Nombre y Apellido y Fecha de Nacimiento para cada uno de los clientes. No necesitarás hacer nada en Excel para esta.
SELECT c.Title,
	   c.FirstName,
	   c.LastName,
       c.DateOfBirth
FROM Customer as c;

-- Pregunta 02: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre el número de clientes en cada grupo de clientes (Bronce, Plata y Oro). Puedo ver visualmente que hay 4 Bronce, 3 Plata y 3 Oro pero si hubiera un millón de clientes ¿cómo lo haría en Excel?

SELECT 	c.CustomerGroup,
		COUNT(c.CustId)
FROM customer as c
GROUP BY c.CustomerGroup;

-- Pregunta 03: El gerente de CRM me ha pedido que proporcione una lista completa de todos los datos para esos clientes en la tabla de clientes pero necesito añadir el código de moneda de cada jugador para que pueda enviar la oferta correcta en la moneda correcta. Nota que el código de moneda no existe en la tabla de clientes sino en la tabla de cuentas. Por favor, escribe el SQL que facilitaría esto. ¿Cómo lo haría en Excel si tuviera un conjunto de datos mucho más grande?

SELECT 	c.*,
		a.CurrencyCode
FROM customer as c
	JOIN Account as a
	ON c.CustId = a.CustId;

-- Pregunta 04: Ahora necesito proporcionar a un gerente de producto un informe resumen que muestre, por producto y por día, cuánto dinero se ha apostado en un producto particular. TEN EN CUENTA que las transacciones están almacenadas en la tabla de apuestas y hay un código de producto en esa tabla que se requiere buscar (classid & categoryid) para determinar a qué familia de productos pertenece esto. Por favor, escribe el SQL que proporcionaría el informe. Si imaginas que esto fue un conjunto de datos mucho más grande en Excel, ¿cómo proporcionarías este informe en Excel?

SELECT b.Product,
	   b.BetDate,
       sum(b.Bet_Amt) as Bet_amount,
       p.sub_product
FROM Betting as b
	JOIN Product as p
	ON b.ClassId = p.ClassId AND b.CategoryId = p.CategoryId
GROUP BY b.Product,b.BetDate,p.sub_product
ORDER BY Bet_amount DESC;

-- Pregunta 05: Acabas de proporcionar el informe de la pregunta 4 al gerente de producto, ahora él me ha enviado un correo electrónico y quiere que se cambie. ¿Puedes por favor modificar el informe resumen para que solo resuma las transacciones que ocurrieron el 1 de noviembre o después y solo quiere ver transacciones de Sportsbook. Nuevamente, por favor escribe el SQL abajo que hará esto. Si yo estuviera entregando esto vía Excel, ¿cómo lo haría?

SELECT b.Product,
	   b.BetDate,
       sum(b.Bet_Amt) as Bet_amount,
       p.sub_product
FROM Betting as b
	JOIN Product as p
	ON b.ClassId = p.ClassId AND b.CategoryId = p.CategoryId
WHERE b.BetDate >= '2012-11-01' AND b.Product='Sportsbook'
GROUP BY b.Product,b.BetDate,p.sub_product
ORDER BY Bet_amount DESC;

-- Pregunta 06: Como suele suceder, el gerente de producto ha mostrado su nuevo informe a su director y ahora él también quiere una versión diferente de este informe. Esta vez, quiere todos los productos pero divididos por el código de moneda y el grupo de clientes del cliente, en lugar de por día y producto. También le gustaría solo transacciones que ocurrieron después del 1 de diciembre. Por favor, escribe el código SQL que hará esto.

SELECT a.CurrencyCode,
	   c.CustomerGroup,
       sum(b.Bet_Amt) as Bet_amount
FROM Betting as b
	JOIN Product as p
	ON b.ClassId = p.ClassId AND b.CategoryId = p.CategoryId
    JOIN Account as a
    ON b.AccountNo = a.AccountNo
    JOIN Customer as c
    ON a.CustId = c.CustId
WHERE b.BetDate > '2012-12-01'
GROUP BY a.CurrencyCode,c.CustomerGroup
ORDER BY Bet_amount DESC;

-- Pregunta 07: Nuestro equipo VIP ha pedido ver un informe de todos los jugadores independientemente de si han hecho algo en el marco de tiempo completo o no. En nuestro ejemplo, es posible que no todos los jugadores hayan estado activos. Por favor, escribe una consulta SQL que muestre a todos los jugadores Título, Nombre y Apellido y un resumen de su cantidad de apuesta para el período completo de noviembre.
SELECT	c.Title,
		c.FirstName,
		c.LastName,
        sub.Bet_Amount
FROM Customer as c
    JOIN ( SELECT a.CustId,
			sum(b.Bet_Amt) as Bet_Amount
    FROM Betting as b
    JOIN Account as a
    ON b.AccountNo = a.AccountNo
    WHERE b.BetDate BETWEEN '2012-12-01' AND '2012-12-31'
    GROUP BY  a.CustId 
    ) sub
    ON c.CustId = sub.CustId
ORDER BY Bet_amount DESC;

-- Pregunta 08: Nuestros equipos de marketing y CRM quieren medir el número de jugadores que juegan más de un producto. ¿Puedes por favor escribir 2 consultas, una que muestre el número de productos por jugador y otra que muestre jugadores que juegan tanto en Sportsbook como en Vegas?
-- Interpretamos productos distintos
SELECT	c.Title,
		c.FirstName,
		c.LastName,
        sub.Monto_producto
FROM Customer as c
    JOIN ( SELECT a.CustId,
			count(distinct b.Product) as Monto_producto
    FROM Betting as b
    JOIN Account as a
    ON b.AccountNo = a.AccountNo
    WHERE b.Product <>  '0'
    GROUP BY  a.CustId 
    HAVING count(distinct b.Product)>1
    ) sub
    ON c.CustId = sub.CustId
ORDER BY Monto_producto DESC;

SELECT
    c.Title,
    c.FirstName,
    c.LastName,
    sub.Monto_producto
FROM Customer as c
JOIN (
    SELECT 
        a.CustId,
        COUNT(DISTINCT b.Product) as Monto_producto
    FROM Betting as b
    JOIN Account as a
    ON b.AccountNo = a.AccountNo
    WHERE b.Product IN ('Sportsbook', 'Vegas')
    GROUP BY a.CustId
    HAVING count(distinct b.Product)>1
) sub
ON c.CustId = sub.CustId
ORDER BY sub.Monto_producto DESC;

-- Pregunta 09: Ahora nuestro equipo de CRM quiere ver a los jugadores que solo juegan un producto, por favor escribe código SQL que muestre a los jugadores que solo juegan en sportsbook, usa bet_amt > 0 como la clave. Muestra cada jugador y la suma de sus apuestas para ambos productos.
SELECT
    c.Title,
    c.FirstName,
    c.LastName,
    sub.Monto_apostado
FROM Customer as c
JOIN (
    SELECT a.CustId, 
    COUNT(DISTINCT b.Product) as Monto_producto, 
    MAX(b.Product) as Producto,
    sum(b.Bet_amt) as Monto_apostado
    FROM Betting as b
    JOIN Account as a ON b.AccountNo = a.AccountNo
    WHERE b.Product <> '0'
    GROUP BY a.CustId
    HAVING COUNT(DISTINCT b.Product) = 1
) sub ON c.CustId = sub.CustId
WHERE sub.Producto = 'Sportsbook'
ORDER BY sub.Monto_producto DESC;

-- Pregunta 10: La última pregunta requiere que calculemos y determinemos el producto favorito de un jugador. Esto se puede determinar por la mayor cantidad de dinero apostado. Por favor, escribe una consulta que muestre el producto favorito de cada jugador

WITH RankedBets AS (
    SELECT
        a.CustId,
        c.Title,
        c.FirstName,
        c.LastName,
        b.Product,
        SUM(b.Bet_amt) AS Monto_apostado,
        ROW_NUMBER() OVER (PARTITION BY a.CustId ORDER BY SUM(b.Bet_amt) DESC) AS rn
    FROM Betting AS b
    JOIN Account AS a ON b.AccountNo = a.AccountNo
    JOIN Customer AS c ON a.CustId = c.CustId
    GROUP BY a.CustId, c.Title, c.FirstName, c.LastName, b.Product
)
SELECT
    Title,
    FirstName,
    LastName,
    Product,
    Monto_apostado AS Monto_Preferido
FROM RankedBets
WHERE rn = 1; 

-- Mirando los datos abstractos en la pestaña "Student_School" en la hoja de cálculo de Excel, por favor responde las siguientes preguntas:

-- Pregunta 11: Escribe una consulta que devuelva a los 5 mejores estudiantes basándose en el GPA
SELECT s.student_name,
	   s.GPA
FROM student as s
ORDER BY GPA DESC
LIMIT 5;

-- Pregunta 12: Escribe una consulta que devuelva el número de estudiantes en cada escuela. (¡una escuela debería estar en la salida incluso si no tiene estudiantes!)

SELECT sc.school_name,
	   COUNT(s.student_id) as Monto_student
FROM school as sc
LEFT JOIN student as s
ON sc.school_id = s.school_id
GROUP BY sc.school_name;
     
-- Pregunta 13: Escribe una consulta que devuelva los nombres de los 3 estudiantes con el GPA más alto de cada universidad.
SELECT sc.school_name,
	   sub.student_name,
       sub.Max_GPA
FROM school as sc
JOIN ( 
	SELECT s.school_id,
		   MAX(s.student_name) as student_name,
           MAX(s.GPA) as Max_GPA
	FROM student as s 
    GROUP BY s.school_id) sub
	ON sc.school_id = sub.school_id
ORDER BY Max_GPA DESC
LIMIT 3;