-- To view the entire table
select * from dim_campaigns;

-- To Join the campaign name and facts table
select count(*) from dim_campaigns cn inner join fact_events fe
on	cn.campaign_id=fe.campaign_id;

select * from dim_campaigns cn inner join fact_events fe
on	cn.campaign_id=fe.campaign_id;

-- Calculating revenue (Total revenue before and after promo)
SELECT 
    SUM(base_price * quantity_sold_before_promo) AS total_revenue_before_promo
FROM
   dim_campaigns cn inner join fact_events fe
on	cn.campaign_id=fe.campaign_id;
-- After promo
SELECT 
    SUM(base_price * quantity_sold_after_promo) AS total_revenue_after_promo
FROM
   dim_campaigns cn inner join fact_events fe
on	cn.campaign_id=fe.campaign_id;

select * from fact_events 
where base_price > 500 and promo_type='BOGOF'
order by base_price desc;

-- List of product greater than 500 and promo type BOGOF
select * from fact_events;

select count(*) from fact_events;

SELECT 
    campaign_name, 
    SUM(base_price * quantity_sold_after_promo) AS revenue_after_promo,
    SUM(base_price * quantity_sold_before_promo) AS revenue_before_promo,
    SUM(base_price * quantity_sold_after_promo) + SUM(base_price * quantity_sold_before_promo) AS total_revenue,
    CASE 
        WHEN SUM(base_price * quantity_sold_after_promo) + SUM(base_price * quantity_sold_before_promo) = 0 THEN 0
        ELSE 
            (SUM(base_price * quantity_sold_after_promo) / 
             (SUM(base_price * quantity_sold_after_promo) + SUM(base_price * quantity_sold_before_promo))) * 100
    END AS percentage_revenue_after_promo,
    CASE 
        WHEN SUM(base_price * quantity_sold_after_promo) + SUM(base_price * quantity_sold_before_promo) = 0 THEN 0
        ELSE 
            (SUM(base_price * quantity_sold_before_promo) / 
             (SUM(base_price * quantity_sold_after_promo) + SUM(base_price * quantity_sold_before_promo))) * 100
    END AS percentage_revenue_before_promo
FROM
    dim_campaigns cn 
    INNER JOIN fact_events fe 
    ON cn.campaign_id = fe.campaign_id
GROUP BY 
    campaign_name;


select * from dim_stores;

select count(store_id) from dim_stores;

-- To Calculate number of stores in each city
select count(store_id),city from dim_stores
group by city
order by count(store_id) desc;


-- List of products with base price greater than 500 and with promotype BOGOF
select distinct(product_code) from fact_events 
where base_price > 500 and promo_type='BOGOF';

-- Campaignwise total revenue
select campaign_name, SUM(base_price * quantity_sold_after_promo) as revenue_after_promo,
  SUM(base_price * quantity_sold_before_promo) as revenue_before_promo
FROM
   dim_campaigns cn inner join fact_events fe
on	cn.campaign_id=fe.campaign_id
group by campaign_name;

-- ISU %
SELECT 
    category,((quantity_sold_after_promo - quantity_sold_before_promo) /
    quantity_sold_before_promo) * 100 AS isu_percentage,
    RANK() OVER (ORDER BY ((quantity_sold_after_promo - quantity_sold_before_promo) 
    / quantity_sold_before_promo) * 100 DESC) AS ranking
FROM
    dim_campaigns cn inner join fact_events fe
on	cn.campaign_id=fe.campaign_id
inner join dim_products dp
on fe.product_code=dp.product_code
where campaign_name='Diwali'
group by category;

-- IR %
SELECT 
    product_name,category,(( (base_price * quantity_sold_after_promo) - 
    (base_price * quantity_sold_before_promo) ) / 
    (base_price * quantity_sold_before_promo)) * 100 AS ir_percentage,
    RANK() OVER (ORDER BY ((base_price * quantity_sold_after_promo) - 
    (base_price * quantity_sold_before_promo) ) /
    (base_price * quantity_sold_before_promo) * 100) AS ranking
FROM
    dim_campaigns cn inner join fact_events fe
on	cn.campaign_id=fe.campaign_id
inner join dim_products dp
on fe.product_code=dp.product_code
order by ir_percentage
limit 5;



  SELECT 
    product_name,category,base_price,
    quantity_sold_after_promo,quantity_sold_before_promo, 
    (base_price * quantity_sold_after_promo) as revenue_after_promo,
	(base_price * quantity_sold_before_promo) as revenue_before_promo,
    (( (base_price * quantity_sold_after_promo) - 
    (base_price * quantity_sold_before_promo) ) /
    (base_price * quantity_sold_before_promo)) * 100 AS ir_percentage,
    RANK() OVER (ORDER BY ((base_price * quantity_sold_after_promo) - 
    (base_price * quantity_sold_before_promo) ) / 
    (base_price * quantity_sold_before_promo) * 100) AS ranking
FROM
    dim_campaigns cn inner join fact_events fe
on	cn.campaign_id=fe.campaign_id
inner join dim_products dp
on fe.product_code=dp.product_code
order by ir_percentage desc
limit 5;