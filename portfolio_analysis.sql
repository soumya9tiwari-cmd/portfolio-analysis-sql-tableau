-- ============================================================
-- SQL PORTFOLIO ANALYSIS
-- Soumya Tiwari
-- ============================================================


-- ============================================================
-- STEP 1: Pull full portfolio for client 128
-- ============================================================
SELECT
    a.customer_id,
    a.full_name,
    b.client_id,
    b.account_id,
    b.main_account,
    c.ticker,
    c.date,
    c.value,
    c.price_type,
    c.quantity,
    d.sec_type,
    d.major_asset_class,
    d.minor_asset_class
FROM invest.customer_details AS a
LEFT JOIN invest.account_dim AS b ON a.customer_id = b.client_id
LEFT JOIN invest.holdings_current AS c ON b.account_id = c.account_id
LEFT JOIN invest.security_masterlist AS d ON c.ticker = d.ticker
WHERE a.customer_id = 128;


-- ============================================================
-- STEP 2: Save the client's portfolio as a reusable view
-- ============================================================
CREATE OR REPLACE VIEW invest.soumya_tiwari_final AS
SELECT
    a.customer_id,
    a.full_name,
    b.client_id,
    b.account_id,
    b.main_account,
    c.ticker,
    c.date,
    c.value,
    c.price_type,
    c.quantity,
    d.sec_type,
    d.major_asset_class,
    d.minor_asset_class
FROM invest.customer_details AS a
LEFT JOIN invest.account_dim AS b ON a.customer_id = b.client_id
LEFT JOIN invest.holdings_current AS c ON b.account_id = c.account_id
LEFT JOIN invest.security_masterlist AS d ON c.ticker = d.ticker
WHERE a.customer_id = 128;

SELECT *
FROM invest.soumya_tiwari_final;


-- ============================================================
-- STEP 3 - PART 1: Continuous returns per security
-- ============================================================

-- 12 MONTHS
SELECT
    z.*,
    LN(z.P1 / z.P0) * 100 AS continuous_return
FROM (
    SELECT
        a.ticker,
        b.date,
        a.value AS P1,
        LAG(b.value, 250) OVER (PARTITION BY b.ticker ORDER BY b.date) AS P0
    FROM invest.soumya_tiwari_final AS a
    LEFT JOIN invest.pricing_daily_new AS b ON a.ticker = b.ticker
    WHERE a.ticker IN (
        'UNG','TSCO','SGOL','ROK','RLY','RINF','OTIS',
        'MSVX','MARB','LBAY','IAUM','GOOGL','GLDM','GIGB','FLSP','DJP','DIS',
        'DBC','DBA','CTA','CEG','CDNS','BNDX','BIL','BIDU','BCI','ARB'
    )
    AND b.price_type = 'Adjusted'
    AND b.date > '2021-08-09'
) AS z
WHERE date = '2022-09-09';


-- 24 MONTHS
SELECT
    z.*,
    LN(z.P1 / z.P0) * 100 AS continuous_return
FROM (
    SELECT
        a.ticker,
        b.date,
        a.value AS P1,
        LAG(b.value, 500) OVER (PARTITION BY b.ticker ORDER BY b.date) AS P0
    FROM invest.soumya_tiwari_final AS a
    LEFT JOIN invest.pricing_daily_new AS b ON a.ticker = b.ticker
    WHERE a.ticker IN (
        'UNG','TSCO','SGOL','ROK','RLY','RINF','OTIS',
        'MSVX','MARB','LBAY','IAUM','GOOGL','GLDM','GIGB','FLSP','DJP','DIS',
        'DBC','DBA','CTA','CEG','CDNS','BNDX','BIL','BIDU','BCI','ARB'
    )
    AND b.price_type = 'Adjusted'
    AND b.date > '2020-08-09'
) AS z
WHERE date = '2022-09-09';


-- 36 MONTHS
SELECT
    z.*,
    LN(z.P1 / z.P0) * 100 AS continuous_return
FROM (
    SELECT
        a.ticker,
        b.date,
        a.value AS P1,
        LAG(b.value, 750) OVER (PARTITION BY b.ticker ORDER BY b.date) AS P0
    FROM invest.soumya_tiwari_final AS a
    LEFT JOIN invest.pricing_daily_new AS b ON a.ticker = b.ticker
    WHERE a.ticker IN (
        'UNG','TSCO','SGOL','ROK','RLY','RINF','OTIS',
        'MSVX','MARB','LBAY','IAUM','GOOGL','GLDM','GIGB','FLSP','DJP','DIS',
        'DBC','DBA','CTA','CEG','CDNS','BNDX','BIL','BIDU','BCI','ARB'
    )
    AND b.price_type = 'Adjusted'
    AND b.date > '2019-08-09'
) AS z
WHERE date = '2022-09-09';


-- ============================================================
-- ENTIRE PORTFOLIO RETURN (weighted by quantity)
-- ============================================================

-- 12 MONTHS
SELECT
    SUM(w.P1 * h.quantity) AS portfolio_P1,
    SUM(w.P0 * h.quantity) AS portfolio_P0,
    LN(SUM(w.P1 * h.quantity) / SUM(w.P0 * h.quantity)) AS portfolio_cont_return
FROM (
    SELECT
        b.ticker,
        b.date,
        b.value AS P1,
        LAG(b.value, 250) OVER (PARTITION BY b.ticker ORDER BY b.date) AS P0
    FROM invest.pricing_daily_new b
    WHERE b.ticker IN (
        'UNG','TSCO','SGOL','ROK','RLY','RINF','OTIS','MSVX','MARB','LBAY','IAUM','GOOGL','GLDM','GIGB','FLSP','DJP','DIS',
        'DBC','DBA','CTA','CEG','CDNS','BNDX','BIL','BIDU','BCI','ARB'
    )
    AND b.price_type = 'Adjusted'
    AND b.date > '2021-08-09'
) w,
invest.holdings_current h,
invest.account_dim a,
invest.customer_details c
WHERE w.date = '2022-09-09'
  AND h.ticker = w.ticker
  AND a.account_id = h.account_id
  AND c.customer_id = a.client_id
  AND c.customer_id = 128;


-- 24 MONTHS
SELECT
    SUM(w.P1 * h.quantity) AS portfolio_P1,
    SUM(w.P0 * h.quantity) AS portfolio_P0,
    LN(SUM(w.P1 * h.quantity) / SUM(w.P0 * h.quantity)) AS portfolio_cont_return
FROM (
    SELECT
        b.ticker,
        b.date,
        b.value AS P1,
        LAG(b.value, 500) OVER (PARTITION BY b.ticker ORDER BY b.date) AS P0
    FROM invest.pricing_daily_new b
    WHERE b.ticker IN (
        'UNG','TSCO','SGOL','ROK','RLY','RINF','OTIS','MSVX','MARB','LBAY','IAUM','GOOGL','GLDM','GIGB','FLSP','DJP','DIS',
        'DBC','DBA','CTA','CEG','CDNS','BNDX','BIL','BIDU','BCI','ARB'
    )
    AND b.price_type = 'Adjusted'
    AND b.date > '2020-08-09'
) w,
invest.holdings_current h,
invest.account_dim a,
invest.customer_details c
WHERE w.date = '2022-09-09'
  AND h.ticker = w.ticker
  AND a.account_id = h.account_id
  AND c.customer_id = a.client_id
  AND c.customer_id = 128;


-- 36 MONTHS
SELECT
    SUM(w.P1 * h.quantity) AS portfolio_P1,
    SUM(w.P0 * h.quantity) AS portfolio_P0,
    LN(SUM(w.P1 * h.quantity) / SUM(w.P0 * h.quantity)) AS portfolio_cont_return
FROM (
    SELECT
        b.ticker,
        b.date,
        b.value AS P1,
        LAG(b.value, 750) OVER (PARTITION BY b.ticker ORDER BY b.date) AS P0
    FROM invest.pricing_daily_new b
    WHERE b.ticker IN (
        'UNG','TSCO','SGOL','ROK','RLY','RINF','OTIS','MSVX','MARB','LBAY','IAUM','GOOGL','GLDM','GIGB','FLSP','DJP','DIS',
        'DBC','DBA','CTA','CEG','CDNS','BNDX','BIL','BIDU','BCI','ARB'
    )
    AND b.price_type = 'Adjusted'
    AND b.date > '2019-08-09'
) w,
invest.holdings_current h,
invest.account_dim a,
invest.customer_details c
WHERE w.date = '2022-09-09'
  AND h.ticker = w.ticker
  AND a.account_id = h.account_id
  AND c.customer_id = a.client_id
  AND c.customer_id = 128;


-- ============================================================
-- QUESTION 2: 12-month volatility (sigma) and average daily return per security
-- ============================================================
SELECT
    t.ticker,
    STDDEV_SAMP(t.daily_return) AS sigma_12m,
    AVG(t.daily_return) AS avg_daily_return
FROM (
    SELECT
        p.ticker,
        p.date,
        LOG(p.value / LAG(p.value, 1) OVER (PARTITION BY p.ticker ORDER BY p.date)) AS daily_return
    FROM invest.pricing_daily_new p
    WHERE p.price_type = 'Adjusted'
      AND p.ticker IN (
          'UNG','TSCO','SGOL','ROK','RLY','RINF','OTIS',
          'MSVX','MARB','LBAY','IAUM','GOOGL','GLDM','GIGB','FLSP','DJP','DIS',
          'DBC','DBA','CTA','CEG','CDNS','BNDX','BIL','BIDU','BCI','ARB'
      )
      AND p.date >= (
          SELECT DATE_SUB(MAX(date), INTERVAL 365 DAY)
          FROM invest.pricing_daily_new
          WHERE price_type = 'Adjusted'
      )
) AS t
WHERE t.daily_return IS NOT NULL
GROUP BY t.ticker
ORDER BY t.ticker;


-- ============================================================
-- QUESTION 3: Expected return, risk, and Sharpe ratio across
-- the full security universe (candidate new investments)
-- ============================================================
SELECT
    ticker,
    AVG(y.cont_ror) AS exp_ror,
    STD(y.cont_ror) AS std_ror,
    AVG(y.cont_ror) / STD(y.cont_ror) AS sharpe
FROM (
    SELECT z.*, LN(z.P1 / z.P0) AS cont_ror
    FROM (
        SELECT
            ticker,
            date,
            value AS P1,
            LAG(value, 1) OVER (
                PARTITION BY ticker
                ORDER BY date
            ) AS P0
        FROM invest.pricing_daily_new
        WHERE price_type = 'Adjusted'
          AND date > '2021-08-09'
    ) z
) y
GROUP BY ticker;


-- ============================================================
-- QUESTION 4: Annualized volatility and Sharpe ratio for
-- securities held in the client's accounts (160, 16001)
-- ============================================================
SELECT
    ticker,
    STD(y.cont_ror) AS std_daily,
    STD(y.cont_ror) * SQRT(250) AS std_year,
    AVG(y.cont_ror) / STD(y.cont_ror) AS sharpe_ratio
FROM (
    SELECT z.*, LN(z.P1 / z.P0) AS cont_ror
    FROM (
        SELECT
            ticker,
            date,
            value AS P1,
            LAG(value, 1) OVER (
                PARTITION BY ticker
                ORDER BY date
            ) AS P0
        FROM invest.pricing_daily_new
        WHERE price_type = 'Adjusted'
          AND date > '2021-09-09'
          AND ticker IN (
              SELECT DISTINCT ticker
              FROM invest.holdings_current
              WHERE account_id IN ('160', '16001')
          )
    ) z
) y
GROUP BY ticker
ORDER BY std_year DESC;


-- ============================================================
-- PORTFOLIO REBALANCING: count tickers by major/minor asset class
-- ============================================================
SELECT
    sec_type,
    major_asset_class,
    minor_asset_class,
    COUNT(ticker) AS count_ticker
FROM invest.soumya_tiwari_final
GROUP BY major_asset_class, minor_asset_class
ORDER BY count_ticker DESC;
