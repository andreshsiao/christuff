DECLARE @id VARCHAR(6) = 'DIO31';
DECLARE @d DATETIME = '20240531';
DECLARE @period VARCHAR(25) = 'YTD';

WITH max_date AS (
    SELECT name, MAX(date_) AS date_ FROM 
    (
        SELECT 
            SUBSTRING(ticker, 0, CHARINDEX(' ', ticker, 0)) AS name, date_ 
        FROM char_float_bond
    )
    GROUP BY name
),

SELECT TOP(5) 
    a.name, '', b.short_name, '', a.port_end_wgt, a.port_ctr, a.diff_ctr, b.cntry, b.sector, '',
    b.issuer_group, f.duration, brh.ratings, f.dflt_prob, f.dflt_risk
FROM 
    port_attribution
LEFT JOIN max_date md
ON a.name = md.name
LEFT JOIN 
(
    SELECT 
        SUBSTRING(ticker, 0, CHARINDEX(' ', ticker, 0)) AS name,
        MAX(short_name) AS short_name, MAX(cntry) AS cntry, MAX(sector) AS sector, MAX(inds_group) AS inds_group
        GROUP BY SUBSTRING(ticker, 0, CHARINDEX(' ', ticker, 0))
) b
ON a.name = b.name
LEFT JOIN 
(   
    SELECT 
        name, MAX(oad) AS duration, MAX(dflt_rate_1y) AS dflt_prob, MAX(dflt_risk_1y) AS dflt_risk
    FROM
    (
        SELECT
            SUBSTRING(ticker, 0, CHARINDEX(' ', ticker, 0)) AS name, 
            * 
        FROM char_float_bond cf
        LEFT JOIN max_date md
        ON cf.name = md.name AND cf.date_ = md.date_
    )
    GROUP BY name
) f
ON a.name = f.name
LEFT JOIN 
(
    SELECT 
        SUBSTRING(bond_name, 0, CHARINDEX(' ', ticker, 0)) AS name,
        MAX(date_) AS date_,
        MAX(rating) AS rating
    FROM bond_ratings_hodings
    GROUP BY SUBSTRING(bond_name, 0, CHARINDEX(' ', ticker, 0))
) brh
ON a.name = brh.name
WHERE
    date_ = @d
    AND jepun_id = @id
    AND period = @period
    AND classification = 'FI issuer'
    AND port_avg_wgt != 0
ORDER BY
    port_ctr 

