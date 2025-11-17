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













