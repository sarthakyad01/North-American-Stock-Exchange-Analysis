--Q2--
DROP VIEW IF EXISTS q1;
CREATE VIEW q1 AS
SELECT gvkey, fyear, conm, sale, loc,
	CASE
			WHEN loc='USA' THEN 1
			WHEN loc='CAN' THEN 0
			ELSE -1
			END AS KITT
FROM Fundamentals_Annual;

SELECT AVG(KITT) FROM q1;

--Q3--
DROP VIEW IF EXISTS q3;
CREATE VIEW q3 AS
SELECT gvkey, fyear, conm, sale, emp, NTILE(10) OVER(PARTITION BY fyear ORDER BY emp) as deciles FROM Fundamentals_Annual WHERE fyear=2019 and emp is not null and sale is not null;

SELECT * FROM q3 WHERE deciles=3 ORDER BY sale DESC;

--Q8--
SELECT DISTINCT gvkey, fyear FROM Fundamentals_Annual;
SELECT gvkey, fyear FROM Fundamentals_Annual;

--Q9--
SELECT gvkey, fyear, emp, conm, RANK() OVER (PARTITION BY fyear ORDER BY emp DESC) as ranked_emp FROM Fundamentals_Annual WHERE fyear=2015 and loc!='USA' LIMIT 500;

--Q10--
SELECT
    MAX(huh) AS mystery
FROM 
    (SELECT
        fyear,
        AVG(ni/at) AS huh
    FROM Fundamentals_Annual
    WHERE 
        at IS NOT NULL
    GROUP BY fyear) AS roa_annual;
	
--Q11--
SELECT
    gvkey,
    fyear,
    conm,
    sale
FROM Fundamentals_Annual
WHERE fyear = 2019
UNION
SELECT
    gvkey,
    fyear,
    conm,
    at
FROM Fundamentals_Annual
WHERE fyear = 2020;

--Q12--
DROP VIEW IF EXISTS q12_19;
CREATE VIEW q12_19 AS
SELECT gvkey, fyear as fyear_19, conm, sale as sale_19 FROM Fundamentals_Annual WHERE loc='USA' and fyear=2019 and sale is not null and at>=500;


DROP VIEW IF EXISTS q12_22;
CREATE VIEW q12_22 AS
SELECT gvkey, fyear as fyear_22, conm, sale as sale_22 FROM Fundamentals_Annual WHERE loc='USA' and fyear=2022 and sale is not null;

DROP VIEW IF EXISTS q12_com;
CREATE VIEW q12_com AS
SELECT gvkey, sale_19, sale_22 FROM q12_19 INNER JOIN q12_22 USING (gvkey);

SELECT DISTINCT gvkey FROM q12_com; --Number of firms in the calculation--

DROP VIEW IF EXISTS q12_com1;
CREATE VIEW q12_com1 AS
SELECT gvkey, sale_19, sale_22, ((sale_22-sale_19)/sale_19)*100 as perc_change FROM q12_com;

SELECT AVG(perc_change) FROM q12_com1; --Overall Average percentage change--

--Q20--
DROP VIEW IF EXISTS q20;
CREATE VIEW q20 AS
SELECT * FROM Fundamentals_Annual WHERE fyear BETWEEN 2015 and 2020 and loc='USA' and naicsh NOT LIKE '52%' and naicsh NOT LIKE '99%' and naicsh is not null and at>=500 and emp is not null and sale is not null;

DROP VIEW IF EXISTS q20_1;
CREATE VIEW q20_1 AS
SELECT gvkey, fyear, conm, tic, naicsh, q_tot FROM q20 INNER JOIN Total_q USING (gvkey, fyear);

SELECT * FROM q20_1 WHERE q_tot is not null;

--Q22--
SELECT DISTINCT gvkey FROM Segments;

--Q23--
DROP VIEW IF EXISTS q23;
CREATE VIEW q23 AS
SELECT gvkey, fyear, NAICSS1, NAICSS2,soptp1, soptp2,
	CASE
			WHEN NAICSS1 IS NOT NULL THEN NAICSS1
			ELSE NAICSS2
			END AS naics_seg
FROM Segments;

SELECT AVG(naics_seg) FROM q23 WHERE naics_seg IS NOT NULL;

--Q24--
SELECT * FROM q23 WHERE fyear=2019 and soptp1='PD_SRVC' and naics_seg IS NOT NULL;

--Q25--
DROP VIEW IF EXISTS q20_final;
CREATE VIEW q20_final AS
SELECT * FROM q20_1 WHERE q_tot is not null;

DROP VIEW IF EXISTS q24_final;
CREATE VIEW q24_final AS
SELECT * FROM q23 WHERE fyear=2019 and soptp1='PD_SRVC' and naics_seg IS NOT NULL;

DROP VIEW IF EXISTS q25_com;
CREATE VIEW q25_com AS
SELECT gvkey, fyear, conm FROM q20_final INNER JOIN q24_final USING (fyear, gvkey);

DROP VIEW IF EXISTS q25_scr;
CREATE VIEW q25_scr AS
SELECT gvkey, fyear, conm, COUNT(gvkey) OVER (PARTITION BY gvkey) as number_of_segments FROM q25_com;

SELECT DISTINCT gvkey FROM q25_scr WHERE number_of_segments=1;
SELECT DISTINCT gvkey FROM q25_scr WHERE number_of_segments=2;
SELECT DISTINCT gvkey FROM q25_scr WHERE number_of_segments=3;
SELECT DISTINCT gvkey FROM q25_scr WHERE number_of_segments=4;
SELECT DISTINCT gvkey FROM q25_scr WHERE number_of_segments>=5;

--Q27--
DROP VIEW IF EXISTS q24_final1;
CREATE VIEW q24_final1 AS
SELECT * FROM q23 WHERE fyear BETWEEN 2015 AND 2020 and soptp1='PD_SRVC' and naics_seg IS NOT NULL;

DROP VIEW IF EXISTS q27_com;
CREATE VIEW q27_com AS
SELECT gvkey, fyear, conm, q_tot FROM q20_final INNER JOIN q24_final1 USING (fyear, gvkey);

DROP VIEW IF EXISTS q27_scr;
CREATE VIEW q27_scr AS
SELECT gvkey, fyear, conm, q_tot, COUNT(gvkey) OVER (PARTITION BY fyear, gvkey) as number_of_segments FROM q27_com;

DROP VIEW IF EXISTS q27_scr1;
CREATE VIEW q27_scr1 AS
SELECT DISTINCT gvkey, fyear, conm, q_tot, number_of_segments FROM q27_scr;

DROP VIEW IF EXISTS q27_15;
CREATE VIEW q27_15 AS
SELECT * FROM q27_scr1 WHERE fyear=2015;

SELECT AVG(q_tot) FROM q27_15 WHERE number_of_segments=1;
SELECT AVG(q_tot) FROM q27_15 WHERE number_of_segments>1;

DROP VIEW IF EXISTS q27_16;
CREATE VIEW q27_16 AS
SELECT * FROM q27_scr1 WHERE fyear=2016;

SELECT AVG(q_tot) FROM q27_16 WHERE number_of_segments=1;
SELECT AVG(q_tot) FROM q27_16 WHERE number_of_segments>1;

DROP VIEW IF EXISTS q27_17;
CREATE VIEW q27_17 AS
SELECT * FROM q27_scr1 WHERE fyear=2017;

SELECT AVG(q_tot) FROM q27_17 WHERE number_of_segments=1;
SELECT AVG(q_tot) FROM q27_17 WHERE number_of_segments>1;

DROP VIEW IF EXISTS q27_18;
CREATE VIEW q27_18 AS
SELECT * FROM q27_scr1 WHERE fyear=2018;

SELECT AVG(q_tot) FROM q27_18 WHERE number_of_segments=1;
SELECT AVG(q_tot) FROM q27_18 WHERE number_of_segments>1;

DROP VIEW IF EXISTS q27_19;
CREATE VIEW q27_19 AS
SELECT * FROM q27_scr1 WHERE fyear=2019;

SELECT AVG(q_tot) FROM q27_19 WHERE number_of_segments=1;
SELECT AVG(q_tot) FROM q27_19 WHERE number_of_segments>1;

DROP VIEW IF EXISTS q27_20;
CREATE VIEW q27_20 AS
SELECT * FROM q27_scr1 WHERE fyear=2020;

SELECT AVG(q_tot) FROM q27_20 WHERE number_of_segments=1;
SELECT AVG(q_tot) FROM q27_20 WHERE number_of_segments>1;
