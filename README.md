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

<img src="05.visuals/01.Null Values.png" alt="Null Values" width="400"/>

- Distinct Counts
 You ran SELECT COUNT(DISTINCT column) across key fields like channel_name, category, product_category, agent_name, and customer_city to understand cardinality and segmentation potential.
<img src="05.visuals/02.Distinct Count.png" alt="Distinct Values" width="400"/>

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
```

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
```
- order_date_time left as NULL
 We chose not to impute this field since it wasn’t critical for SLA or CSAT analysis, and many tickets didn’t involve an order.
- connected_handling_duration_time not blindly filled
  We added logic to fill missing handling time only for non-call channels (e.g., email), where handling time isn’t tracked. This avoided skewing resolution metrics.
-  customer_remarks left untouched
 Since remarks are free-text and optional, We preserved them as-is for potential Gen AI use later (e.g., summarization or sentiment analysis).

## 1.3 Timestamp Logic & Sequence Checks
- Issue Reported Before Order Date:
 We checked for cases where issue_reported_date_time < order_date_time, which could indicate data entry errors or post-order issues.
<img src="05.visuals/03.Timestamp Logic.png" alt="Timestamp Logic" width="800"/>

- Responded vs Reported:
 We ensured that issue_responded_date_time always came after issue_reported_date_time , a key check for calculating resolution time.
- Time Sequence Validation:
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
```

# Phase 2 — KPI Views & Analysis (SQL)
With the staging table (stg_support_tickets) in place, Phase 2 focused on extracting operational KPIs and identifying patterns that directly impact resolution time and customer satisfaction. Rather than explaining every query, we focused on high-impact metrics that support the core business problem.

## Key Insights
- Channel Performance
 Inbound tickets dominated volume (~79%), but Outcall consistently showed faster resolution times and higher CSAT scores. Email lagged behind on both fronts, highlighting a need for channel-specific process improvements.
- Category & Sub-Category Trends
 Top categories and sub-categories were ranked per channel and product, helping identify which issue types drive the most volume and where resolution delays are concentrated.
<img src="05.visuals/04.Top 5 categories.png" alt="Top 5 Categories" width="800"/>
- SLA Compliance
 Tickets resolved within 48 hours were flagged as SLA_MET, while others were marked SLA_BREACHED. This binary flag enabled quick filtering and performance tracking across teams, shifts, and product lines.
- Price Band vs Resolution & CSAT
 Higher-priced items tended to receive faster resolution and better CSAT, suggesting prioritization logic or customer expectation

**How we decided the price band logic:**
To segment tickets by item value, we created three price bands: Low, Medium, and High. Instead of choosing arbitrary thresholds, we used a percentile-based approach

- We sorted all 85,000 tickets by item_price.
- The bottom 33% (first ~28,000 rows) were labeled Low.
- The middle 33% (rows ~28,001 to ~56,000) were labeled Medium.
- The top 33% (remaining ~28,000 rows) were labeled High.

This method ensures that each bucket has a roughly equal number of tickets, making comparisons fair and statistically balanced. It also adapts to the actual price distribution in the dataset, rather than relying on fixed thresholds
```
-- Check if when item price is high then resolution time taken is low ? 
select 
	case
		when item_price >= 25000 then 'High Price'
		when item_price between	5000 and 24999 then 'Medium Price'
		else 'Low Price'
	end as price_band,
	count(*) as total_tickets,
	cast(avg(DATEDIFF(minute, issue_reported_date_time, issue_responded_date_time)/60)as decimal(5,2)) as avg_resolution_hours,
	avg(csat_score) as csat_score
from stg_support_tickets
where item_price is not null
group by
	case
		when item_price >= 25000 then 'High Price'
		when item_price between	5000 and 24999 then 'Medium Price'
		else 'Low Price'
	end
order by avg_resolution_hours
```

- Agent Hierarchy & Tenure
 Resolution time and CSAT were analyzed across managers, supervisors, and agent shifts. More tenured agents showed slightly better performance, and certain shifts consistently outperformed others.
- City-Level Impact
 We identified top cities by ticket volume and purchase value, helping localize support strategies and understand regional demand.

## Enriched table 	
To streamline dashboarding and avoid repetitive logic, we created an enriched table using CTAS:
- enriched_support_data includes derived fields like:
 - resolution_hours, sla_flag, item_price_segment
 - Time breakdowns (week, month, year)
 - Flags for missing remarks and filled handling time
   
This table acts as a clean, business-ready layer for Power BI, reducing load time, simplifying DAX, and making the model easier to maintain.

We also created SQL view to pre-aggregate KPIs like SLA compliance, CSAT trends, and resolution summaries. This enriched view will be loaded in the Power BI for further use in reporting and dashboard. 

# Phase 3 — Interactive Dashboard Development (Power BI)

## Dashboard Pages Overview
### 1. Ticket Volume & Resolution Trends
- Total Tickets by Week
Line chart showing weekly ticket volume (~86K total), helping track operational load.
- Avg Resolution Hours by Week
Trend line showing resolution time fluctuations, it is useful for spotting any seasonal delays or any process caused delays.
- SLA % and CSAT Score by Week
KPI cards and line charts showing SLA compliance (~98.88%) and CSAT trends (~4.24 average), helping monitor service quality over time.
<img src="05.visuals/05.Ticket Vol-Resolution.png" alt="Ticket Volumn" width="800"/>

### 2. Category Level Insights
- Ticket Volume by Category
Bar chart showing top categories like Returns, Order Related, Refunds, etc.
- Avg Resolution & CSAT by Category
Table comparing resolution hours and CSAT across categories , e.g., App/ Websites, Payments and Returns had high CSAT, while “Others” had low csat scores and long resolution times.
- SLA Breach % by Category
Visual flagging categories with higher breach rates, it useful for prioritizing process fixes.
<img src="05.visuals/06.Category Insights.png" alt="Category Insights" width="800"/>

### 3. Channel Performance
- Ticket Volume by Channel
Inbound dominated (~60K+), followed by Outcall and Email.
- Avg Resolution & CSAT by Channel
Outcall had the fastest resolution; Email was slowest. CSAT scores varied slightly across channels.
- SLA Breach % by Channel
Email showed the highest breach rate, reinforcing the need for channel specific SLA monitoring.
<img src="05.visuals/07.channel performance.png" alt="chanel performance" width="800"/>

### 4. Agent & Manager Performance
- Agent-Level Table
KPIs for each agent: ticket count, resolution time, CSAT, SLA %. Helps identify top and bottom performers.
- Manager-Level Summary
Aggregated metrics by manager for e.g., William Kim’s team had the fastest resolution and highest SLA compliance.
- Shift vs Performance
Bar chart showing resolution time by shift (Morning, Evening, Night, etc.). Useful for staffing decisions.
<img src="05.visuals/08. Agent Performance.png" alt="Agent performance" width="800"/>

### 5. Customer & Price Insights
- Top Cities by Purchase Value
Cities like Hyderabad, Mumbai, Bangalore led both metrics. It is useful for regional strategy.
- CSAT vs Item Price Segment
Higher-priced items showed better CSAT, validating the price band logic.
- Price Band vs Resolution Time
Tickets were segmented into Low, Medium, High using percentile logic, helping analyze service prioritization.
<img src="05.visuals/09.cust and price insight.png" alt="cust and price insight" width="800"/>


# Key Insights & Business Outcomes

**1. Inbound Dominates Volume but Not Efficiency**
- Inbound tickets made up ~79% of total volume, but had longer resolution times compared to Outcall.
- Email, while low in volume, had the highest SLA breach rate and slowest response. This indicates a need for process optimization or automation.

**2. Certain Categories Drive Delays & Low CSAT**
- Categories like “Others” and “App/Website” had longer resolution times and lower CSAT scores.
- In contrast, Payments and Returns were resolved faster and had higher satisfaction, suggesting clearer SOPs or better trained agents in those areas.

**3. SLA Compliance Is High but Breaches Are Concentrated**
- Overall SLA compliance was 98.88%, but 964 tickets breached the 48-hour threshold.
- These breaches were not random, they clustered around specific channels (Email) and categories (Others, App/Website), making them fixable through targeted interventions.

**4. Agent & Shift-Level Performance Gaps Exist**
- Agent performance varied widely. Some agents had resolution times >8 hours with CSAT <3.5.
- Shift analysis showed that Morning and Evening shifts performed better than Night or Split shifts, suggesting potential staffing or training gaps

**5. Price Band Influences Resolution & Satisfaction**
- Tickets were bucketed into Low, Medium, and High price bands using a percentile-based approach.
- Higher-priced items were resolved faster and received better CSAT scores, indicating either prioritization or higher customer expectations.

**6. City Level Trends Inform Regional Strategy**
- Cities like Hyderabad, Mumbai, and Bangalore led in both ticket volume and total purchase value.
- This insight can guide resource allocation, regional training, or localized support strategies.

# Conclusion & Roadmap

This project successfully identified key operational inefficiencies, agent performance gaps, and SLA risks across 85K+ support tickets. The enriched SQL pipeline and Power BI dashboard now serve as a decision-ready tool for support leaders, enabling faster diagnosis, smarter routing, and targeted performance management.

The dashboard provides:
- A clear view of ticket volume, resolution time, and CSAT trends across channels, categories, and shifts
- SLA breach tracking with drilldowns by agent, manager, and product
- Price-band and city-level segmentation for prioritizing high-value customers
- A scalable framework for future automation and predictive analytics

### Future Enhancements
To extend the impact and make the dashboard smarter, the following enhancements can be planned:

- NLP for Remarks → Sentiment analysis and auto-tagging of customer feedback
- AI-Based Category Prediction → Suggest likely issue types based on ticket text
- Automated SLA Breach Alerts → Real-time notifications for at-risk tickets
- Power BI Service Integration → Scheduled refresh, role-based access, and cloud sharing
- Incremental Refresh Logic → Efficient data updates without full reloads
- Drillthrough Agent Pages → Personalized dashboards for agent-level coaching and review














