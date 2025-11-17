# Support-Operations-Performance-Analytics
We will be doing a performance analytics using SQL and Power BI for more than 85,000 customer support tickets, analytics will help us improve optimize resolution time, improve SLA performance and identify any level inefficiencies.

# Project Overview
- This project analyzes customer support operations using a dataset of over 85,000 tickets collected across multiple channels inbound calls, outbound calls, and emails. The goal is to identify patterns that affect resolution time, customer satisfaction (CSAT), and SLA compliance, and to support smarter decision-making in support workflows.
- The dataset includes ticket metadata such as issue category, sub-category, timestamps, agent hierarchy, product details, and customer remarks. These were cleaned and transformed using SQL to create staging and enriched tables, with derived fields like resolution duration, SLA flags, and item price segments. The analysis covers channel efficiency, agent performance, customer impact, and process bottlenecks.
- Business KPIs were modeled through SQL views and aggregated using techniques like window functions, CTEs. These views were then connected to Power BI, where a multi-page dashboard visualizes trends across categories, agents and shifts, cities and pricing. The dashboard is designed for operational leaders to monitor performance, coach agents, and optimize ticket routing.
- This is a full-stack analytics project from raw data to business ready insights. It simulates a real world support environment and builds a reusable framework for continuous monitoring. Also, Gen AI extensions are planned to summarize customer remarks and auto-categorize tickets, further enhancing review speed and routing accuracy.

# Business Problem
Support teams handle thousands of tickets every day across phone, chat, email, and other digital channels. Even with trained employees and defined processes, companies still encounter common pain points such as long resolution times, inconsistent customer satisfaction, and uneven agent performance and many more to talk about.

The core business problem we talk about here is :
**“Reduce time-to-resolution and improve customer satisfaction by identifying high-impact issue categories, agent performance gaps, and ticket routing inefficiencies.”**

This is a technical challenge as well as an operational one too. When resolution times stretch too long or CSAT scores dip, it affects customer retention, brand trust, and internal efficiency. Managers need visibility into which and what areas are impacting such issues.

This dataset  with over 85,000 tickets gives us that visibility. By analyzing timestamps, agent hierarchy, product types, and customer feedback, we can find out patterns that aren’t obvious at first glance.

# Project Blueprint (Architecture & Approach)
This project follows a structured, multi-phase pipeline, starting from raw support ticket data and ending with a business-ready Power BI dashboard. Each phase builds on the previous one, ensuring the data is clean, meaningful, and aligned with real operational questions

**Raw Data → Staging Table → Enriched Table → Power BI Model → Dashboard Pages**

- **Raw to Staging:** The raw CSV file (85K+ records) is first imported into SQL Server. Here, we clean and standardize the data , parsing timestamps, handling missing values, and ensuring consistent formats. This gives us a stable base table: stg_support_tickets.
- **Staging to Enriched:** From the staging table, we derive new columns like resolution_hours, sla_flag, item_price_segment, and time-based fields (week, month, year). These enrichments are stored in a new table.
- **Power BI Modeling:** The enriched table is connected to Power BI, where relationships are modeled and DAX measures are created such as average CSAT, SLA compliance %, and resolution time. These measures power the visuals and KPIs across multiple dashboard pages.
- **Dashboard Pages:** Each page focuses on a specific business theme category/channel insights, agent performance, customer impact, SLA trends allowing stakeholders to explore the data from different angles and make informed decisions

# Dataset Description

The dataset contains over 85,000 customer support tickets, each representing a real interaction between a customer and the support team. It’s rich in detail, covering everything from issue type and communication channel to agent hierarchy and customer feedback. 
Here’s how the columns are organized:
- **Ticket Metadata**
Includes ticket_id, channel_name, category, and sub_category. These help us understand what kind of issue was raised and how it came in.
- **Customer Details**
Fields like customer_city and customer_remarks give us location based insights and raw feedback. Some cities are missing or marked by me as “Location Unknown,” which we account for in the analysis.
- **Product Details**
 product_category and item_price tell us what the ticket was about and the value of the item involved. A few entries have missing or unknown product categories, which are flagged during cleaning.
- **Timestamps**
We track order_date_time, issue_reported_date_time, issue_responded_date_time, and survey_response_date. These help us calculate resolution time, SLA compliance, and follow-up delays. Notably, many tickets have missing order_date_time, which limits order-related analysis.
- **Agent Hierarchy**
 Each ticket is linked to an agent_name, supervisor, and manager, along with tenure and agent_shift. This structure allows us to analyze performance across individuals, teams, and shifts.
- **CSAT Score**
 The csat_score column captures customer satisfaction on a scale of 1 to 5. It’s the key target variable used to evaluate service quality.
- **Price & Handling Time**
 item_price reflects customer expectations, while connected_handling_duration_time shows how long agents spent resolving the issue. Both are used to segment tickets and assess efficiency.

The dataset spans a short date range, which is important to keep in mind when interpreting trends. Despite some missing values, the data is well suited for operational analysis especially once cleaned and enriched through SQL.

# Phase 1 — Data Exploration & Cleaning (SQL)

This phase was all about understanding the raw dataset and preparing a clean, analysis ready staging table. The SQL script was structured to explore data quality, validate timestamps, and make thoughtful decisions about missing values and not just fill them blindly.

## 1.1 Profiling the Raw Data
We began by inspecting the raw structure and profiling each column

- Row Count
  A simple SELECT COUNT(*) confirmed the volume which is over 85,000 rows.
 
- Data Types & Structure
We reviewed column types manually and ensured they aligned with expected formats (e.g., datetime fields, numeric price, text remarks).

- Null Analysis Using Dynamic SQL
 You wrote a dynamic SQL script that looped through all columns to count nulls and calculate null percentages. This gave a clear snapshot of data quality across the board.
Example: SELECT COUNT(*) - COUNT(column_name) AS null_count FROM raw_support_tickets
(insert image)

- Distinct Counts
 You ran SELECT COUNT(DISTINCT column) across key fields like channel_name, category, product_category, agent_name, and customer_city to understand cardinality and segmentation potential.
(insert image)

- Timestamp Range Checks
 Using MIN() and MAX() on order_date_time, issue_reported_date_time, issue_responded_date_time, and survey_response_date, you validated the temporal scope and confirmed a short date range.

## 1.2 Handling Missing Values 

- customer_city → 'Unknown'
 Instead of dropping rows, you replaced missing cities with 'Location Unknown' to preserve volume and allow location based analysis.
```SQL
select 
	*,
	case 
		when Customer_City is null then 'Unknown'
		else Customer_City
	end as customer_city_filled
from support_ticket_data

- product_category → 'Product Unknown'
 Similar logic — missing product types were labeled explicitly so they could be tracked separately in dashboards.
```SQL
select 
	Product_category,
	case 
		when Product_category is null then 'Unknown'
		else Product_category
	end as product_category_filled
from support_ticket_data

- order_date_time left as NULL
 We chose not to impute this field since it wasn’t critical for SLA or CSAT analysis, and many tickets didn’t involve an order.
- connected_handling_duration_time not blindly filled
  We added logic to fill missing handling time only for non-call channels (e.g., email), where handling time isn’t tracked. This avoided skewing resolution metrics.
-  customer_remarks left untouched
 Since remarks are free-text and optional, We preserved them as-is for potential Gen AI use later (e.g., summarization or sentiment analysis).

## 1.3 Timestamp Logic & Sequence Checks
- Issue Reported Before Order Date
 We checked for cases where issue_reported_date_time < order_date_time, which could indicate data entry errors or post-order issues.
- Responded vs Reported
 We ensured that issue_responded_date_time always came after issue_reported_date_time , a key check for calculating resolution time.
- Time Sequence Validation
 These checks confirmed that the ticket lifecycle followed a logical order, and helped us avoid negative durations or misleading SLA flags.

## 1.4 Creating the Staging Table (stg_support_tickets)
Once the data was profiled and cleaned, we used a CTAS (Create Table As Select) approach to build the staging table

- We standardized column names for consistency.
- Applied transformations like:
  - COALESCE(item_price, 0) → to fill missing prices
  -  CASE logic for price segmentation (High, Medium, Low)
  -    Derived resolution_hours using DATEDIFF between reported and responded timestamps
  - Flagged SLA breaches (resolution_hours > 48 → 'SLA_BREACHED')

```SQL
-- creating CTAS with name stg_support_tickets
select
	Unique_id as ticket_id,
	channel_name, 
	category,
	Sub_category as sub_category, 
	Customer_Remarks as customer_remarks, 
	Order_id as order_id,
	order_date_time as ordered_date_time,
	Issue_reported_at as issue_reported_date_time,
	issue_responded as issue_responded_date_time,
	Survey_response_Date as survey_response_date_time,
	coalesce(Customer_City, 'Location Unknown') as customer_city, 
	coalesce(Product_category, 'Product Unknown') as product_category, 
	Item_price as item_price,
	connected_handling_time as connected_handling_duration_time,
	Agent_name as agent_name,
	Supervisor as supervisor,
	Manager as manager, 
	Tenure_Bucket as tenure,
	Agent_Shift as agent_shift,
	CSAT_Score as csat_score
into
stg_support_tickets
from 
support_ticket_data















