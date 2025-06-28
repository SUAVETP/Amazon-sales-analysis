📊 E-commerce Sales Analysis (Amazon Fashion)
🧠 Scenario
A growing fashion-focused e-commerce brand sells clothing items both domestically (India) and to international customers. Management needs clarity on sales performance, returns, and regional demand to guide inventory decisions, product strategy, and expansion efforts. The goal of this project is to analyze sales trends, product performance, return behavior, and city-level revenue using real-world-style data — and visualize the insights through a clean, actionable Tableau dashboard.

🧹 Data Cleaning (SQL)
The original datasets were cleaned using MySQL. Steps included:

Removed duplicates and null rows

Fixed inconsistent entries (e.g., "Unship" vs "Unshipped")

Created Cleaned_Order_Status for better status analysis

Verified formats for dates, quantities, amounts

Removed corrupted columns like Ship_State

Cleaned datasets were saved and used for analysis and visualization.

🔍 Exploratory Analysis (SQL)
Several business questions were explored using SQL:

Total revenue, quantity, and order count by sales type (domestic vs international)

Monthly sales trends to analyze seasonality and growth

Style performance (e.g., Sets, Kurtas, Western Dress)

Top-selling categories in domestic market

Return and cancellation rates by category

Top regions (cities) by revenue and their share

Underperforming categories with low sales or high returns

📈 Tableau Dashboard
The Tableau dashboard visualizes key insights through:

KPIs: Total revenue, quantity, and orders by sales type

Line charts: Monthly sales trends (domestic vs international)

Bar charts: Style and category performance

Pie chart or stacked bars: Returns and cancellations

Map: Top 10 cities (domestic only) by revenue share

Color Scheme:

🟩 Domestic: Emerald Green #009966

🟦 International: Royal Blue #0066CC

🟥 Returns & Cancellations: Red #CC0000 / Amber #FF9900

Screenshot is included in /Screenshots.

📌 Key Findings
Domestic sales dominate, with higher revenue and quantity sold.

Top-selling styles: Set, Kurta, Western Dress.

Western Dress has the highest return rate (over 13%).

Returns + cancellations are more common in high-fashion categories.

Bengaluru, Hyderabad, and Mumbai are the top cities by revenue.

A few styles (e.g., Dupatta, Saree, Bottoms) underperform in both quantity and revenue.

✅ Recommendations
Focus more on Sets and Kurtas — they bring consistent revenue with lower return rates.

Investigate quality or sizing issues in Western Dresses to reduce returns.

Consider phasing out underperforming items (e.g., Dupatta, Saree) or reviewing their inventory strategy.

Double down on top cities with targeted ads or regional campaigns.

Introduce product-level feedback to reduce cancellation and return percentages.

