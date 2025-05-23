--For CTE logic, CTE will be executed first then the main query. SO to speed up, optimize the CTEs first then do the main query
--If you see decrepancy between SRQ and Sys2, check feature quantity. Feature quantity will go to SRQ
WITH 
CTE1 AS (--CREATE DATA WITH STORE SINCE IT'S ASSORTED  
SELECT 	test1.STRNBR,test1.SKUNBR,YYWWW,test1.FISCAL_YEAR,test1.week_number_in_fiscal_year,SFC01,SFC02,SFC03,SFC04,SFC05,SFC06,SFC07,SFC08,SFC09,SFC10,SFC11,SFC12,SFC13,SFC14,SFC15,SFC16,SFC17,SFC18,SFC19,SFC20,SFC21,SFC22,SFC23,
	SFC24,SFC25,SFC26,SFC27,SFC28,SFC29,SFC30,SFC31,SFC32,SFC33,SFC34,SFC35,SFC36,SFC37	,SFC38,SFC39,SFC40,SFC41,SFC42,SFC43,SFC44,SFC45,SFC46,SFC47,SFC48,SFC49,SFC50,SFC51, SFC52 FROM 	
	(SELECT STRNBR,SKUNBR,YYWWW,FISCAL_YEAR,week_number_in_fiscal_year FROM(
	SELECT DISTINCT STRNBR,SKUNBR,YYWWW,FISCAL_YEAR,week_number_in_fiscal_year,
	min_week,max_week FROM (  
	SELECT CAST(EXTRACT (YEAR FROM load_datetime) % 100 || LPAD(EXTRACT (week FROM load_datetime),2,'0') AS INT) AS YYWW,
	EXTRACT (year FROM LOAD_DATETIME) AS year,
	EXTRACT (week FROM LOAD_DATETIME) AS week,
	MIN(YYWW) OVER (PARTITION BY STRNBR,SKUNBR) MIN_WEEK,
	CAST(EXTRACT (YEAR FROM NOW()) % 100 || LPAD(EXTRACT (week FROM NOW()),2,'0') AS INT) AS MAX_WEEK,STRNBR,SKUNBR
	FROM EDW_HUB_STAGE.NZ.ARCHIVE_SALES_BPS_FUT_MRSRQW1P s
	LEFT JOIN EDW_SPOKE..DIM_PRODUCT_BPS P ON s.skunbr = p.sku_display_number
	WHERE LOAD_DATETIME  >= '2022-01-01 00:00:00.000' 
	AND DEPARTMENT_MEMBER_NUMBER in (350) --AND P.SUB_DEPARTMENT_MEMBER_NUMBER IN (430)
	and MEMBER_type = 'BPS PRODUCT' 
	AND (SKU_TRANSITION_START_DATE_YRWK = 0 OR SKU_TRANSITION_START_DATE_YRWK >=2445) AND SKU_TYPE_DESCRIPTION = 'Finished'
	) AS P
	CROSS JOIN (SELECT ( fiscal_year % 100 || LPAD(week_number_in_fiscal_year,2,'0')) AS YYWWW,FISCAL_YEAR,week_number_in_fiscal_year FROM EDW_SPOKE..DIM_DATE 
	WHERE fiscal_year >= 2022 AND FISCAL_YEAR <= 2025  GROUP BY 1,2,3 ORDER BY 1 DESC) AS T
	WHERE YYWWW >= 2200
	) X
	WHERE YYWWW >= MIN_WEEK AND YYWWW <= max_week) test1
LEFT JOIN (
	SELECT * FROM (
	SELECT CAST(TO_CHAR(LOAD_DATETIME::date,'iyyy') AS int) AS year, CAST(TO_CHAR(LOAD_DATETIME ::date,'iw') AS int) AS week,
	CAST(TO_CHAR(LOAD_DATETIME::date,'iy') || TO_CHAR(LOAD_DATETIME::date,'iw') AS INT) AS YYWW,
	MIN(YYWW) OVER (PARTITION BY STRNBR,SKUNBR) MIN_WEEK,
	MAX(LOAD_DATETIME) OVER (PARTITION BY STRNBR,SKUNBR,YEAR,WEEK) AS WEEK_MAX_LOADTIME,
	CAST(EXTRACT (YEAR FROM NOW()) % 100 || LPAD(EXTRACT (week FROM NOW()),2,'0') AS INT) AS MAX_WEEK,LOAD_DATETIME,strnbr,skunbr,
	SFC01,SFC02,SFC03,SFC04,SFC05,SFC06,SFC07,SFC08,SFC09,SFC10,SFC11,SFC12,SFC13,SFC14,SFC15,SFC16,SFC17,SFC18,SFC19,SFC20,SFC21,SFC22,SFC23,SFC24,SFC25,SFC26,
	SFC27,SFC28,SFC29,SFC30,SFC31,SFC32,SFC33,SFC34,SFC35,SFC36,SFC37,SFC38,SFC39,SFC40,SFC41,SFC42,SFC43,SFC44,SFC45,SFC46,SFC47,SFC48,SFC49,SFC50,SFC51, SFC52 
	FROM EDW_HUB_STAGE.NZ.ARCHIVE_SALES_BPS_FUT_MRSRQW1P S
	LEFT JOIN EDW_SPOKE..DIM_PRODUCT_BPS P ON s.skunbr = p.sku_display_number
	WHERE LOAD_DATETIME  >= '2022-01-01 00:00:00.000' 
	AND DEPARTMENT_MEMBER_NUMBER in(350) -- AND P.SUB_DEPARTMENT_MEMBER_NUMBER IN (430)
	AND MEMBER_type = 'BPS PRODUCT' 
	AND (SKU_TRANSITION_START_DATE_YRWK = 0 OR SKU_TRANSITION_START_DATE_YRWK >=2430) AND SKU_TYPE_DESCRIPTION = 'Finished' --AND skunbr = 4034967 AND strnbr = 5 --ORDER BY LOAD_DATETIME desc
	) xxxx
	WHERE LOAD_DATETIME  = WEEK_MAX_LOADTIME ORDER BY LOAD_DATETIME desc) test2
	ON test1.STRNBR = test2.STRNBR AND test1.SKUNBR = test2.SKUNBR and test1.YYWWW = test2.YYWW),
CTE3 AS(
	SELECT  FISCAL_YEAR, WEEK_NUMBER_IN_FISCAL_YEAR,DEPARTMENT_MEMBER_NUMBER,SUB_DEPARTMENT_MEMBER_NUMBER,CLASS_MEMBER_NUMBER,sub_class_display_number, 
	STYLE_DISPLAY_NUMBER, SKU_DISPLAY_NUMBER,sku_name, ASSORTMENT_STATUS, CAST(STORE_NUMBER AS INT) STORE_NUMBER
	FROM EDW_SPOKE..FACT_BPS_HISTORIC_ASSORTMENT HA
	JOIN EDW_SPOKE..DIM_PRODUCT_BPS P ON HA.PRODUCT_MEMBER_KEY = P.MEMBER_KEY
	JOIN EDW_SPOKE..DIM_DATE D ON D.DATE_VALUE >= HA.START_DATE AND D.date_value <= HA.END_DATE
	RIGHT JOIN EDW_SPOKE..DIM_STORE S ON HA.STORE_MEMBER_KEY = S.MEMBER_KEY
	WHERE FISCAL_YEAR >= 2022 AND date_value <= CURRENT_DATE AND S.CHANNEL_GROUP in ('RETAIL','DIRECT') 
	AND ASSORTMENT_STATUS in('A','P') 
	AND P.DEPARTMENT_MEMBER_NUMBER in(350) --AND P.SUB_DEPARTMENT_MEMBER_NUMBER IN (430)
	AND P.MEMBER_type = 'BPS PRODUCT' 
	AND (P.SKU_TRANSITION_START_DATE_YRWK = 0 OR P.SKU_TRANSITION_START_DATE_YRWK >=2430) AND P.SKU_TYPE_DESCRIPTION = 'Finished'
	GROUP BY 1, 2, 3, 4, 5, 6,7,8,9,10,11),
SALES AS (
    SELECT SKU_DISPLAY_NUMBER, style_display_number, WEEK_NUMBER_IN_FISCAL_YEAR, FISCAL_YEAR,AVG(PRICE) AVG_SALE_PRICE, SUM(SALE_QUANTITY) SALES_UNIT
    FROM (
    SELECT SKU_DISPLAY_NUMBER, style_display_number, WEEK_NUMBER_IN_FISCAL_YEAR, FISCAL_YEAR,RETURN_FLAG, SALES_PRICE / NULLIF(SALE_QUANTITY,0) AS PRICE,SALE_QUANTITY 
    FROM EDW_SPOKE.NZ.FACT_BPS_SALES_DETAIL HA
    JOIN EDW_SPOKE..DIM_PRODUCT_BPS P ON HA.INVENTORY_PRODUCT_MEMBER_KEY = P.MEMBER_KEY
    JOIN EDW_SPOKE..DIM_STORE S ON HA.STORE_MEMBER_KEY = S.MEMBER_KEY
    JOIN EDW_SPOKE..DIM_DATE D ON D.DATE_VALUE >= HA.PROCESS_DATE AND D.date_value <= HA.PROCESS_DATE
    AND P.DEPARTMENT_MEMBER_NUMBER in(350) --AND P.SUB_DEPARTMENT_MEMBER_NUMBER IN (430)
    AND P.MEMBER_type = 'BPS PRODUCT' 
    AND (P.SKU_TRANSITION_START_DATE_YRWK = 0 OR P.SKU_TRANSITION_START_DATE_YRWK >=2430) AND P.SKU_TYPE_DESCRIPTION = 'Finished'
    ) TEMP1
    WHERE RETURN_FLAG = 'N' AND FISCAL_YEAR >= 2022 -- AND SALE_QUANTITY > 0 AND sku_display_number = 271986 AND WEEK_NUMBER_IN_FISCAL_YEAR = 1
    GROUP BY 1, 2, 3, 4),
INSTOCK AS (
    SELECT FISCAL_YEAR, WEEK_NUMBER_IN_FISCAL_YEAR, STYLE_DISPLAY_NUMBER, SKU_DISPLAY_NUMBER,STR_CNT, AVG(day_instock) AS INSTOCK
    FROM (
    SELECT FISCAL_YEAR, WEEK_NUMBER_IN_FISCAL_YEAR, STYLE_DISPLAY_NUMBER, SKU_DISPLAY_NUMBER, store_number,DAYOFWEEK, SUM(CASE WHEN TOTAL_ONHAND >= 1 THEN 1 ELSE 0 END) / DAYOFWEEK AS DAY_INSTOCK,
    COUNT(DISTINCT store_number) OVER (PARTITION BY FISCAL_YEAR, WEEK_NUMBER_IN_FISCAL_YEAR,SKU_DISPLAY_NUMBER) AS STR_CNT
    FROM (
	SELECT FISCAL_YEAR, WEEK_NUMBER_IN_FISCAL_YEAR, DATE_VALUE, PRODUCT_MEMBER_KEY, STYLE_DISPLAY_NUMBER, SKU_DISPLAY_NUMBER, ASSORTMENT_STATUS, store_number, SUM(HA.ON_HAND_UNITS) AS TOTAL_ONHAND,
	(CASE WHEN FISCAL_YEAR = 2025 AND WEEK_NUMBER_IN_FISCAL_YEAR = (SELECT EXTRACT (week FROM now())) THEN EXTRACT (dow FROM now()) ELSE 7 END) AS DAYOFWEEK
    FROM EDW_SPOKE..FACT_BPS_HISTORIC_ASSORTMENT HA
    JOIN EDW_SPOKE..DIM_PRODUCT_BPS P ON HA.PRODUCT_MEMBER_KEY = P.MEMBER_KEY
    JOIN EDW_SPOKE..DIM_DATE D ON D.DATE_VALUE >= HA.START_DATE AND D.date_value <= HA.END_DATE
    RIGHT JOIN EDW_SPOKE..DIM_STORE S ON HA.STORE_MEMBER_KEY = S.MEMBER_KEY
    WHERE FISCAL_YEAR >= 2022 AND date_value <= CURRENT_DATE AND S.CHANNEL_GROUP = 'RETAIL' AND ASSORTMENT_STATUS = 'A'
    AND P. DEPARTMENT_MEMBER_NUMBER in(350) --AND P.SUB_DEPARTMENT_MEMBER_NUMBER IN (430)
    AND (SKU_TRANSITION_START_DATE_YRWK = 0 OR SKU_TRANSITION_START_DATE_YRWK >=2430) 
    AND P.MEMBER_type = 'BPS PRODUCT' and P.SKU_TYPE_DESCRIPTION = 'Finished' --AND SKU_DISPLAY_NUMBER = 4028448
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8 --ORDER BY store_number,date_value desc
    ) TEMP1
    GROUP BY 1, 2, 3, 4, 5, 6
    ) TEMP2
    GROUP BY 1, 2, 3, 4,5),
TREND AS(
	SELECT SKU_DISPLAY_NUMBER AS skunbr, EXTRACT (WEEK FROM now()) AS week,EXTRACT (YEAR FROM now()) AS YEAR,
	SUM(ANNUAL_FORECAST) AS current_FORECAST,SUM(TRENDED_FCST) TRENDED_forecast,TRENDED_forecast/NULLIF(current_FORECAST,0)-1 AS trend
	FROM (
	SELECT SKU_DISPLAY_NUMBER,store_number,MTACTS/NULLIF(MTEXPS,0) AS store_trend,
	(CASE WHEN store_trend IS NULL THEN 1 ELSE 0 END) store_notrend, 
	ANNUAL_FORECAST,
 	(CASE WHEN store_trend IS NULL THEN annual_forecast else STORE_TREND * ANNUAL_FORECAST END) AS trended_fcst  FROM EDW_LANDING.NZ.DOMO_MRTRNM1P M
	RIGHT JOIN 
	(SELECT sku_display_number,store_number,ANNUAL_FORECAST FROM EDW_SPOKE.NZ.FACT_BPS_CURRENT_ASSORTMENT ha
	jOIN EDW_SPOKE..DIM_PRODUCT_BPS P
	ON	HA.PRODUCT_MEMBER_KEY = P.MEMBER_KEY
	JOIN EDW_SPOKE..DIM_STORE S ON HA.STORE_MEMBER_KEY = S.MEMBER_KEY
	WHERE ASSORTMENT_STATUS IN ('A','P') AND us_chain_price NOTNULL --AND SKU_DISPLAY_NUMBER IN  (3620398)
	AND P. DEPARTMENT_MEMBER_NUMBER in(350) --AND P.SUB_DEPARTMENT_MEMBER_NUMBER IN (430)
    AND (SKU_TRANSITION_START_DATE_YRWK = 0 OR SKU_TRANSITION_START_DATE_YRWK >=2430) 
    AND P.MEMBER_type = 'BPS PRODUCT' and P.SKU_TYPE_DESCRIPTION = 'Finished' 
	) t
	ON m.SKUNBR  = t.sku_display_number AND m.STRNBR = t.STORE_number --order BY store_number
	) t1
	GROUP BY 1),
SKU_DATA AS (
	--SELECT * FROM (
	SELECT EXTRACT (WEEK FROM now()) AS week,EXTRACT (YEAR FROM now()) AS YEAR,sub_class_display_number AS Sub_Class, style_display_number,style_name, 	sku_display_number,sku_name,sku_color,Sku_size,us_chain_price,sku_transition_start_date_yrwk T_DATE ,SUM(CASE WHEN ASSORTMENT_STATUS = 'A' THEN 1 ELSE 0 END) DOOR_COUNT , 
	SUM(on_hand_units)  + sum(on_order_units) TOTAL_OH_OO,SUM(annual_forecast) ANNUAL_FORECAST, SUM(DESIRED_ON_HAND_UNITS) AS MOD
	FROM	
	(SELECT sub_class_display_number,style_display_number,style_name, sku_display_number,sku_name,sku_color,Sku_size,us_chain_price,sku_transition_start_date_yrwk,
	ASSORTMENT_STATUS,on_hand_units,on_order_units,annual_forecast,DESIRED_ON_HAND_UNITS,store_number
	FROM EDW_SPOKE.NZ.FACT_BPS_CURRENT_ASSORTMENT ha
	jOIN EDW_SPOKE..DIM_PRODUCT_BPS P ON	HA.PRODUCT_MEMBER_KEY = P.MEMBER_KEY
	JOIN EDW_SPOKE..DIM_STORE S ON HA.STORE_MEMBER_KEY = S.MEMBER_KEY
	WHERE ASSORTMENT_STATUS IN ('A','N','P') AND --us_chain_price NOTNULL AND  on_hand_units >=0 AND  
	P. DEPARTMENT_MEMBER_NUMBER = 350 AND 
	(SKU_TRANSITION_START_DATE_YRWK = 0 OR SKU_TRANSITION_START_DATE_YRWK >=2430) AND P.MEMBER_type = 'BPS PRODUCT' And P.SKU_TYPE_DESCRIPTION = 'Finished' --AND sku_display_number = 3620398
	) temp1
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11 ),--ORDER BY 3) TEMP2
PROFILE AS (
    SELECT temp1.week, (CASE WHEN TEMP1.WEEK > (SELECT EXTRACT(WEEK FROM CURRENT_DATE)) THEN (SELECT EXTRACT(YEAR FROM CURRENT_DATE)) ELSE (SELECT EXTRACT(YEAR FROM CURRENT_DATE) + 1) END) AS fiscal_year, 
    CAST(fiscal_year % 100 || LPAD(TEMP1.WEEK,2,'0') AS INT) AS YYWW,
    null AS SUB_CLASS,
    CAST(SKUNBR AS INT) SKUNBR, 
    NULL AS style_display_number, 
    NULL AS SKU_NAME ,
    NULL AS SKU_COLOR,
    NULL AS SKU_SIZE,
    NULL AS us_chain_price,
    NULL AS T_DATE,
    TOTAL_OH_OO - mod AS OH,
    NULL AS SALE_PRICE, 
    WEEKLY_FORECAST, 
    NULL AS instock, 
    NULL AS DOOR_COUNT,
    ANNUAL_FORECAST AS ANNUAL_FORECAST,
    NULL AS trend, 
    sum(WEEKLY_FORECAST) OVER (PARTITION BY temp1.skunbr ORDER  BY temp1.skunbr,FISCAL_YEAR,temp1.week) AS REV, 
    (CASE WHEN rev > OH  THEN 1 ELSE 0 END ) AS SFC01,NULL AS SFC02,NULL AS SFC03,NULL AS SFC04,NULL AS SFC05,NULL AS SFC06,NULL AS SFC07,NULL AS SFC08,NULL AS SFC09,NULL AS SFC10,NULL AS SFC11,NULL AS SFC12,NULL AS SFC13,NULL AS 	SFC14,NULL AS 	SFC15,NULL 	AS SFC16,NULL AS SFC17,NULL AS SFC18,NULL AS SFC19,NULL AS SFC20,NULL AS SFC21,NULL AS SFC22,NULL AS SFC23,NULL AS SFC24,NULL AS SFC25,NULL AS SFC26,NULL AS SFC27,NULL AS SFC28,NULL AS SFC29,NULL 	AS 	SFC30,NULL AS 	SFC31,NULL AS SFC32,NULL AS SFC33,NULL AS SFC34,NULL AS SFC35,NULL AS SFC36,NULL AS SFC37,NULL AS SFC38,NULL AS SFC39,NULL AS SFC40,NULL AS SFC41,NULL AS SFC42,NULL AS SFC43,NULL AS SFC44,NULL AS 	SFC45,NULL AS 	SFC46,NULL AS SFC47,NULL AS SFC48,NULL AS SFC49,NULL AS SFC50,NULL AS SFC51,NULL AS SFC52
    FROM (
			  SELECT SKUNBR ,1 AS week, SUM(SFC01) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,2 AS week,SUM(SFC02) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,3 AS week,SUM(SFC03) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,4 AS week,SUM(SFC04) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,5 AS week,SUM(SFC05) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,6 AS week,SUM(SFC06) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,7 AS week,SUM(SFC07) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,8 AS week,SUM(SFC08) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,9 AS week,SUM(SFC09) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,10 AS week,SUM(SFC10) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,11 AS week,SUM(SFC11) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,12 AS week,SUM(SFC12) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,13 AS week,SUM(SFC13) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,14 AS week,SUM(SFC14) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,15 AS week,SUM(SFC15) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,16 AS week,SUM(SFC16) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,17 AS week,SUM(SFC17) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,18 AS week,SUM(SFC18) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,19 AS week,SUM(SFC19) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,20 AS week,SUM(SFC20) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,21 AS week,SUM(SFC21) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,22 AS week,SUM(SFC22) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,23 AS week,SUM(SFC23) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,24 AS week,SUM(SFC24) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,25 AS week,SUM(SFC25) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,26 AS week,SUM(SFC26) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,27 AS week,SUM(SFC27) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,28 AS week,SUM(SFC28) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,29 AS week,SUM(SFC29) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,30 AS week,SUM(SFC30) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,31 AS week,SUM(SFC31) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,32 AS week,SUM(SFC32) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,33 AS week,SUM(SFC33) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,34 AS week,SUM(SFC34) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,35 AS week,SUM(SFC35) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,36 AS week,SUM(SFC36) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,37 AS week,SUM(SFC37) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,38 AS week,SUM(SFC38) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,39 AS week,SUM(SFC39) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,40 AS week,SUM(SFC40) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,41 AS week,SUM(SFC41) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,42 AS week,SUM(SFC42) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,43 AS week,SUM(SFC43) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,44 AS week,SUM(SFC44) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,45 AS week,SUM(SFC45) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,46 AS week,SUM(SFC46) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,47 AS week,SUM(SFC47) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,48 AS week,SUM(SFC48) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,49 AS week,SUM(SFC49) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,50 AS week,SUM(SFC50) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,51 AS week,SUM(SFC51) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	UNION ALL SELECT SKUNBR ,52 AS week,SUM(SFC52) weekly_forecast FROM EDW_LANDING.NZ.SALES_BPS_FUT_MRSRQW1P GROUP BY SKUNBR
	) temp1
	LEFT JOIN SKU_DATA P ON p.sku_display_number = temp1.skunbr --AND temp1.week = p.week
	--LEFT JOIN EDW_SPOKE.NZ.FACT_BPS_CURRENT_ASSORTMENT ha ON HA.PRODUCT_MEMBER_KEY = P.MEMBER_KEY
	--WHERE SKU_DISPLAY_NUMBER  = (3620398)
	--GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14
	--ORDER BY WEEK
	)	
--main
SELECT * FROM (
SELECT WEEK_NUMBER_IN_FISCAL_YEAR,fiscal_year,YYWWW,Sub_Class,CAST(TEMPX.sku_display_number AS INT) AS sku_display_number,d.STYLE_DISPLAY_NUMBER,D.sku_name,trim(sku_coloR) AS sku_coloR,TRIM(Sku_size) AS Sku_size,us_chain_price,T_DATE, TOTAL_OH_OO,AVG_SALE_PRICE,
SALES_UNIT,
instock,STR_CNT,D.ANNUAL_FORECAST, TREND, CAST((AVG_SALE_PRICE * SALES_UNIT) AS INT) AS REV
,CAST(SFC01 AS int) SFC01,CAST(SFC02 AS INT )SFC02,CAST(SFC03 AS INT )SFC03,CAST(SFC04 AS INT )SFC04,CAST(SFC05 AS INT )SFC05,CAST(SFC06 AS INT )SFC06,CAST(SFC07 AS INT )SFC07,CAST(SFC08 AS INT )SFC08,CAST(SFC09 AS INT )SFC09,CAST(SFC10 AS INT )SFC10,CAST(SFC11 AS INT )SFC11,CAST(SFC12 AS INT )SFC12,CAST(SFC13 AS INT )SFC13,CAST(SFC14 AS INT )SFC14,CAST(SFC15 AS INT )SFC15,CAST(SFC16 AS INT )SFC16,CAST(SFC17 AS INT )SFC17,CAST(SFC18 AS INT )SFC18,CAST(SFC19 AS INT )SFC19,CAST(SFC20 AS INT )SFC20,CAST(SFC21 AS INT )SFC21,CAST(SFC22 AS INT )SFC22,CAST(SFC23 AS INT )SFC23,CAST(SFC24 AS INT )SFC24,CAST(SFC25 AS INT )SFC25,CAST(SFC26 AS INT )SFC26,CAST(SFC27 AS INT )SFC27,CAST(SFC28 AS INT )SFC28,CAST(SFC29 AS INT )SFC29,CAST(SFC30 AS INT )SFC30,CAST(SFC31 AS INT )SFC31,CAST(SFC32 AS INT )SFC32,CAST(SFC33 AS INT )SFC33,CAST(SFC34 AS INT )SFC34,CAST(SFC35 AS INT )SFC35,CAST(SFC36 AS INT )SFC36,CAST(SFC37 AS INT )SFC37,CAST(SFC38 AS INT )SFC38,CAST(SFC39 AS INT )SFC39,CAST(SFC40 AS INT )SFC40,CAST(SFC41 AS INT )SFC41,CAST(SFC42 AS INT )SFC42,CAST(SFC43 AS INT )SFC43,CAST(SFC44 AS INT )SFC44,CAST(SFC45 AS INT )SFC45,CAST(SFC46 AS INT )SFC46,CAST(SFC47 AS INT )SFC47,CAST(SFC48 AS INT )SFC48,CAST(SFC49 AS INT )SFC49,CAST(SFC50 AS INT )SFC50,CAST(SFC51 AS INT )SFC51,CAST( SFC52 AS INT ) SFC52
FROM
(
SELECT TEMP3.fiscal_year,TEMP3.WEEK_NUMBER_IN_FISCAL_YEAR,TEMP3.sku_display_number,DEPARTMENT_MEMBER_NUMBER,SUB_DEPARTMENT_MEMBER_NUMBER,CLASS_MEMBER_NUMBER,sub_class_display_number,TEMP3.STYLE_DISPLAY_NUMBER,
sku_name,AVG_SALE_PRICE,SALES_UNIT,
instock,STR_CNT,YYWWW,
sum(sfc01) SFC01,sum(sfc02) SFC02,sum(sfc03) SFC03,sum(sfc04) SFC04,sum(sfc05) SFC05,sum(sfc06) SFC06,sum(sfc07) SFC07,sum(sfc08) SFC08,sum(sfc09) SFC09,sum(sfc10) SFC10,
sum(sfc11) SFC11,sum(sfc12) SFC12,sum(sfc13) SFC13,sum(sfc14) SFC14,sum(sfc15) SFC15,sum(sfc16) SFC16,sum(sfc17) SFC17,sum(sfc18) SFC18,sum(sfc19) SFC19,sum(sfc20) SFC20,
sum(sfc21) SFC21,sum(sfc22) SFC22,sum(sfc23) SFC23,sum(sfc24) SFC24,sum(sfc25) SFC25,sum(sfc26) SFC26,sum(sfc27) SFC27,sum(sfc28) SFC28,sum(sfc29) SFC29,sum(sfc30) SFC30,
sum(sfc31) SFC31,sum(sfc32) SFC32,sum(sfc33) SFC33,sum(sfc34) SFC34,sum(sfc35) SFC35,sum(sfc36) SFC36,sum(sfc37) SFC37,sum(sfc38) SFC38,sum(sfc39) SFC39,sum(sfc40) SFC40,
sum(sfc41) SFC41,sum(sfc42) SFC42,sum(sfc43) SFC43,sum(sfc44) SFC44,sum(sfc45) SFC45,sum(sfc46) SFC46,sum(sfc47) SFC47,sum(sfc48) SFC48,sum(sfc49) SFC49,sum(sfc50) SFC50,
sum(sfc51) SFC51,sum(sfc52) SFC52
from(
--
SELECT CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR,DEPARTMENT_MEMBER_NUMBER,SUB_DEPARTMENT_MEMBER_NUMBER,CLASS_MEMBER_NUMBER,sub_class_display_number,CTE3.STYLE_DISPLAY_NUMBER,
cte3.SKU_DISPLAY_NUMBER ,sku_name,cte3.STORE_NUMBER,YYWWW,--TOTAL_FORECAST,--instock,
	LAST_VALUE(SFC01 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC01,
	LAST_VALUE(SFC02 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC02,
	LAST_VALUE(SFC03 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC03,
	LAST_VALUE(SFC04 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC04,
	LAST_VALUE(SFC05 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC05,
	LAST_VALUE(SFC06 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC06,
	LAST_VALUE(SFC07 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC07,
	LAST_VALUE(SFC08 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC08,
	LAST_VALUE(SFC09 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC09,
	LAST_VALUE(SFC10 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC10,
	LAST_VALUE(SFC11 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC11,
	LAST_VALUE(SFC12 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC12,
	LAST_VALUE(SFC13 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC13,
	LAST_VALUE(SFC14 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC14,
	LAST_VALUE(SFC15 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC15,
	LAST_VALUE(SFC16 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC16,
	LAST_VALUE(SFC17 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC17,
	LAST_VALUE(SFC18 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC18,
	LAST_VALUE(SFC19 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC19,
	LAST_VALUE(SFC20 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC20,
	LAST_VALUE(SFC21 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC21,
	LAST_VALUE(SFC22 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC22,
	LAST_VALUE(SFC23 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC23,
	LAST_VALUE(SFC24 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC24,
	LAST_VALUE(SFC25 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC25,
	LAST_VALUE(SFC26 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC26,
	LAST_VALUE(SFC27 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC27,
	LAST_VALUE(SFC28 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC28,
	LAST_VALUE(SFC29 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC29,
	LAST_VALUE(SFC30 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC30,
	LAST_VALUE(SFC31 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC31,
	LAST_VALUE(SFC32 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC32,
	LAST_VALUE(SFC33 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC33,
	LAST_VALUE(SFC34 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC34,
	LAST_VALUE(SFC35 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC35,
	LAST_VALUE(SFC36 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC36,
	LAST_VALUE(SFC37 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC37,
	LAST_VALUE(SFC38 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC38,
	LAST_VALUE(SFC39 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC39,
	LAST_VALUE(SFC40 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC40,
	LAST_VALUE(SFC41 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC41,
	LAST_VALUE(SFC42 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC42,
	LAST_VALUE(SFC43 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC43,
	LAST_VALUE(SFC44 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC44,
	LAST_VALUE(SFC45 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC45,
	LAST_VALUE(SFC46 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC46,
	LAST_VALUE(SFC47 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC47,
	LAST_VALUE(SFC48 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC48,
	LAST_VALUE(SFC49 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC49,
	LAST_VALUE(SFC50 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC50,
	LAST_VALUE(SFC51 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC51,
	LAST_VALUE(SFC52 IGNORE NULLS) OVER (PARTITION BY cte3.STORE_NUMBER,cte3.SKU_DISPLAY_NUMBER ORDER BY cte3.SKU_DISPLAY_NUMBER,cte3.STORE_NUMBER,CTE3.fiscal_year,CTE3.WEEK_NUMBER_IN_FISCAL_YEAR  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SFC52
FROM CTE3 
RIGHT JOIN CTE1
ON CTE3.FISCAL_YEAR = CTE1.FISCAL_YEAR AND CTE3.STORE_NUMBER = CTE1.STRNBR AND CTE3.SKU_DISPLAY_NUMBER = CTE1.SKUNBR AND CTE3.WEEK_NUMBER_IN_FISCAL_YEAR = CTE1.WEEK_NUMBER_IN_FISCAL_YEAR
) TEMP3 
LEFT JOIN SALES ON SALES.SKU_DISPLAY_NUMBER = TEMP3.SKU_DISPLAY_NUMBER AND SALES.WEEK_NUMBER_IN_FISCAL_YEAR = TEMP3.WEEK_NUMBER_IN_FISCAL_YEAR AND SALES.fiscal_YEAR= TEMP3.FISCAL_YEAR
LEFT JOIN INSTOCK ON INSTOCK.SKU_DISPLAY_NUMBER = TEMP3.SKU_DISPLAY_NUMBER AND INSTOCK.WEEK_NUMBER_IN_FISCAL_YEAR = TEMP3.WEEK_NUMBER_IN_FISCAL_YEAR AND INSTOCK.fISCAL_YEAR= TEMP3.FISCAL_YEAR
WHERE YYWWW >= 2200
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14
) AS TEMPX
LEFT JOIN SKU_DATA D ON D.sku_display_number = TEMPX.sku_display_number AND D.YEAR = TEMPX.fiscal_year AND D.WEEK = TEMPX.WEEK_NUMBER_IN_FISCAL_YEAR
LEFT JOIN TREND T ON T.SKUNBR = TEMPX.sku_display_number AND T.WEEK = TEMPX.WEEK_NUMBER_IN_FISCAL_YEAR AND T.YEAR = TEMPX.fiscal_year
WHERE TEMPX.YYWWW >= 2200 AND TEMPX.sku_display_number IN (SELECT SKU_DISPLAY_NUMBER  FROM sku_data)
UNION ALL (SELECT * FROM PROFILE)
) TEMP5
WHERE TEMP5.sku_display_number IN  (4017661,2392265,4017689,2446054,4261122,4017617,3940944,4261159,3923236,3510346,4026321,4026304,4026248,4026230,4017610,2904548,4261143,4261148,4017670,3997058,4017664,4261215,4261167,4017609,1755295,4261177,4261180,2446052,3923168,3831150,4017618,3997103,4261164,4261137,4261156,3923432,4017582,3997101,3997100,4261162,4020460,4017616,4261216,4026224,4026242,4261182,4261138,3923133,2392295,3923218,4261145,3923223,4020537,4261027,4143871,4026258,2392264,4149817,4261140,4261124,4261103,4261217,4261131,3516407,4018659,2101744,3941047,4026168,2776004,4261042,3510347,4026216,4026172,4260544,2446051,3576927,3997085,4261206,4261200,4260555,4260563,4261044,4261051,4261038,4260512,4260568,4024493,4105764,4017612,3923358,4035357,3923363,4026353,4261188,3940950,3426343,4261030,4018658,4020341,2189793,4261160,4260551,1545525,1895669,4261307,2856494,4035356,4020199,3923320,3510348,3923327,4026145,4260521,4020469,4261306,3923526,4254927,4020343,4149819,3923265,4254916,4261221,4261048,4020305,4028314,3516396,3230501,1545625,3576930,1895656,3576929,1545624,4017636,4026311,204160002,4024417,3576928,4019890,4019889,3576925,1755294,1537881,2579887,4254905,4256244,4024439,4261049,3997035,2579885,3576931,3745137,3577613,2856503,3577614
 )
--(271896,4075260,1626563,4045287,2515037,2515742,2515750,2834860,2966904,3032398,3620398,3620400,3624066,3624068,3624070,3685324,3685326,3954776,3954777,4028535,4111535,4278484,4310022,2512402,3473946,3491150,3491209,3878330,3896669,3986981,4078045,4078395,4078396,4078426,4078454,4078569,4242960,4296166,4296170,4374183,4374184,2359871,2504081,2504082,2504083,3292320,3292327,3292328,3292329,3292330,3292331,3491149,3491151,3491153,3491157,3491162,3491208,3491210,3491211,3491226,3878331,3896667,4070273,4078037,4078038,4078039,4078040,4078041,4078042,4078043,4078044)
--(3538835,3538836,3538837,3538838,3538840,3538841) 
ORDER BY TEMP5.SKU_DISPLAY_NUMBER, SUB_CLASS desc,FISCAL_YEAR DESC , week_number_in_fiscal_year desc;








