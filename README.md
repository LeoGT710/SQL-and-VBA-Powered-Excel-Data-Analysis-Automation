# SQL and VBA Powered Excel Data Analysis Automation
# Excel Data Analysis Automation

Welcome to my Excel Data Analysis Automation repository! This repository showcases a comprehensive workflow for data analysis and automation in Excel. The workflow consists of three parts: data consolidation, VBA automation, and formula-based analysis.

## Part 1: Data Consolidation
In this part, I used Dbeaver to consolidate multiple data sources into a single dataset. The consolidated data is stored in a standardized format for further analysis. The SQL queries, data transformation steps, and the final consolidated dataset can be found in the [Part1_Data Consolidation](./Part1_Data%20Consolidation) folder.

## Part 2: Excel Formula-based Analysis
In this part, I created various formulas and calculations to perform data analysis on the loaded and formatted data. The analysis includes statistical measures, trend analysis, and other relevant calculations. The Excel file with all the formulas and analysis can be found in the [Part2_Formula-based Analysis](./Part2_Excel%20Formula-based%20Analysis) folder.

## Part 3: VBA Automation
In this part, I developed a VBA script to automate the process of loading data into Excel and performing necessary formatting. The script retrieves data from the consolidated dataset and automatically formats it based on predefined rules. The VBA code, instructions, and sample data can be found in the [Part3_VBA Automation](./Part3_VBA%20Automation) folder.

## Usage

To utilize the Excel Data Analysis Automation workflow, follow these steps:

1. Start with the consolidated dataset obtained from Part 1 and save it as a CSV file, such as "data.csv". Save
2. Open the Excel file from Part 2.
3. Press `ALT + F11` to open the Visual Basic Editor.
4. In the Visual Basic Editor, locate the "Get Data" VBA script.
5. Within the VBA script, update the file path to the location in line 39 where you saved the "data.csv" file. For example, "C:\Users\hvle\Downloads\".
6. Close the Visual Basic Editor.
7. In the Excel file, click the designated button labeled "Get Data" to execute the VBA automation script.
8. The script will automatically load the data from the "data.csv" file, format it, and calculate all necessary analyses.
9. The results and analysis will be displayed in the Excel file.

By following these steps, you will be able to easily load and analyze the data from Part 1 using the VBA automation script in Part 2.


## Contact Information
If you have any questions or would like to discuss collaboration opportunities, feel free to reach out to me:

- Email: hung.le@wustl.edu
- LinkedIn: 

Thank you for exploring my Excel Data Analysis Automation repository. I hope you find the workflow useful and the provided examples insightful!
