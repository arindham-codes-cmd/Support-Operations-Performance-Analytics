
-- let us create a table from staging that we will have additional formulated columns that we use in dashboard. 

select 
	ticket_id,
	channel_name,
	category,
	sub_category,
	customer_remarks,
	case when customer_remarks is not null then 1 else 0 end as remarks_flag,
	order_id,
	ordered_date_time, 
	issue_reported_date_time, 
	issue_responded_date_time,
	convert(date, issue_reported_date_time) as reported_date,
	datepart(week, issue_reported_date_time) as reported_week, 
	DATEPART(month, issue_reported_date_time) AS reported_month,
	DATEPART(year, issue_reported_date_time) AS reported_year,
	convert(date, issue_responded_date_time) as responded_date,
	datepart(week, issue_responded_date_time) as responded_week,
	datepart(month, issue_responded_date_time) as responded_month,
	datepart(year, issue_responded_date_time) as responded_year,
	customer_city, 
	product_category,
	item_price, 
	coalesce(item_price,0) as item_price_filled,
	case 
		when item_price is null then 'Price Unknown'
		when item_price > 1500 then 'High'
		when item_price between 500 and 1499 then 'Medium'
		else 'Low'
	end as item_price_segment,
	connected_handling_duration_time, 
	case 
		when connected_handling_duration_time is null and channel_name not in ('Inbound','Outcall') then 0
		else connected_handling_duration_time 
	end as handling_time_filled,
	agent_name,
	supervisor,
	manager,
	tenure,
	agent_shift,
	csat_score,
	CASE 
		WHEN issue_reported_date_time IS NOT NULL AND issue_responded_date_time IS NOT NULL
		THEN CAST(DATEDIFF(MINUTE, issue_reported_date_time, issue_responded_date_time) / 60.0 AS DECIMAL(6,2))
		ELSE NULL
	END AS resolution_hours,
	CASE 
		WHEN issue_reported_date_time IS NULL OR issue_responded_date_time IS NULL THEN NULL
		WHEN DATEDIFF(HOUR, issue_reported_date_time, issue_responded_date_time) <= 48 THEN 'SLA_MET'
    ELSE 'SLA_BREACHED' END AS sla_flag
into enriched_support_data
from stg_support_tickets


select * from enriched_support_data

-- creating a view from the enriched table 


create or alter view vw_enriched_support_data AS
SELECT
  ticket_id,
  order_id,
  ordered_date_time,
  reported_date,
  responded_date,
  reported_week,
  reported_month,
  reported_year,
  responded_week,
  responded_month,
  responded_year,
  channel_name,
  category,
  sub_category,
  customer_city,
  product_category,
  item_price,
  item_price_filled,
  item_price_segment,
  connected_handling_duration_time,
  handling_time_filled,
  agent_name,
  supervisor,
  manager,
  tenure,
  agent_shift,
  csat_score,
  resolution_hours,
  sla_flag,
  remarks_flag
FROM enriched_support_data


select * from vw_enriched_support_data