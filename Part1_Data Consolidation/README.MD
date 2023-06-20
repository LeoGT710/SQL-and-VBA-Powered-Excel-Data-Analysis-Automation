# Data Consolidation with SQL

This project aims to combine historical sales data, retail store instock percentage, historical assortment, and next 52 weeks profile at the SKU level using SQL. The data consolidation process allows for a comprehensive analysis of the sales performance and inventory status across different periods.

## Dataset Description

The project utilizes the following datasets:

1. Historical Sales Data: Contains weekly historical sales information for various SKUs from 2020.
2. Retail Instock Percentage: Provides the weekly instock percentage for each SKU in retail stores.
3. Historical Assortment: Includes the assortment details for SKUs in different time periods.
4. Next 52 Weeks Profile: Provides a profile of projected sales for the upcoming 52 weeks.

## Description of the Data Consolidation Process and its Significance

The data consolidation process plays a crucial role in saving time and effort by combining multiple datasets into a unified view. Previously, each dataset was located in different sources, requiring users to download and manipulate them individually. This manual process was time-consuming and prone to errors.

By consolidating the data using SQL, we can streamline the analysis process and save approximately 95% of the time. Instead of downloading and combining multiple datasets manually, users can now execute a single SQL script that performs the necessary joins, filters, and aggregations. This automated data consolidation significantly reduces the time and effort required to obtain a comprehensive view of sales performance and inventory status at the SKU level.

The significance of the data consolidation process lies in its ability to provide a holistic understanding of the business's performance and inform data-driven decision-making. By combining various datasets, we can identify patterns, trends, and correlations that were previously hidden within individual datasets. This consolidated view empowers stakeholders to make informed decisions regarding sales strategies, inventory management, and assortment planning.

Overall, the data consolidation process saves time, improves data accuracy, and enables better insights by bringing together disparate datasets into a single coherent analysis. It enhances the efficiency and effectiveness of data analysis, ultimately contributing to more informed business decisions and improved performance.

## SQL Code

To execute the SQL code and perform the data consolidation, follow these steps:

1. Ensure you have access to the required datasets.
2. Set up a database or data environment where you can run SQL queries.
3. Refer to the `data_consolidation.sql` file in this repository for the SQL code.
4. Copy the provided SQL code into your SQL editor or query interface.
5. Replace the placeholder comments (`-- SQL code here`) with the actual SQL statements based on your dataset structure.
6. Execute the SQL code to perform the data consolidation.

## Sample Data
After executing the SQL code, you will obtain a consolidated dataset that combines the historical sales data, retail instock percentage, historical assortment, and next 52 weeks profile. Here is a sample of the resulting dataset:

| FISCAL_WEEK | FISCAL YEAR | SKU_DISPLAY_NUMBER | STYLE_DISPLAY_NUMBER | PRICE | SALES_UNITS | INSTOCK | DOORS |
|-------------|-------------|--------------------|----------------------|-------|-------------|---------|-------|
| 22          | 2023        | 3098076            | 392BSCHAMBERBAG       | 21.4  | 37          | 99.4%   | 117   |
| 23          | 2023        | 3098076            | 392BSCHAMBERBAG       | 23.7  | 37          | 99.9%   | 117   |
| 24          | 2023        | 3098076            | 392BSCHAMBERBAG       | 19.5  | 37          | 99.1%   | 117   |
| 25          | 2023        | 3098076            | 392BSCHAMBERBAG       | 17.4  | 10          | 42.5%   | 117   |
| 26          | 2023        | 3098076            | 392BSCHAMBERBAG       | 0.0   | 42.52       | 0.0%    | 0     |
| 27          | 2023        | 3098076            | 392BSCHAMBERBAG       | 0.0   | 41.8        | 0.0%    | 0     |
| 28          | 2023        | 3098076            | 392BSCHAMBERBAG       | 0.0   | 44.56       | 0.0%    | 0     |
| 29          | 2023        | 3098076            | 392BSCHAMBERBAG       | 0.0   | 49.01       | 0.0%    | 0     |

The sample dataset includes columns such as SKU (Stock Keeping Unit), Week, Sales, Instock_Percent, Assortment, and Profile. Each row represents a specific SKU's sales data for a particular week, along with the corresponding instock percentage, assortment information, and projected profile for the next 52 weeks.

If the week and year in the dataset are greater than the current week and year, the data is  "Projected". The time I'm writing this is week 25 2023 . This indicates that the corresponding sales data and other metrics are projections for the upcoming weeks. On the other hand, if the week and year are before or equal to the current week and year, the data is "Historical," indicating that the data represents historical sales information.

Please note that this is just a sample, and the actual dataset will vary based on your specific data and SQL code execution.

## Usage

To use the consolidated data and perform analysis, refer to the following steps:

1. Review the consolidated dataset resulting from the SQL code execution.
2. Use SQL queries or analytics tools to extract insights, generate reports, or perform specific analyses.
3. Customize and modify the SQL code as needed to meet your specific analysis requirements.

Additional Information

- Make sure to customize the SQL code based on your specific dataset structure and column names.
- Ensure that the required datasets are available and accessible before executing the SQL code.
- Consider performing data validation and cleaning steps as necessary before the consolidation process.
- You may need to adjust the SQL code based on the specific business rules or calculations required for your analysis.

Feel free to modify the README file as needed to provide further details, instructions, or explanations specific to your project.

