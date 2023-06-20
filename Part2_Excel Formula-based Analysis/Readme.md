
# Get Data VBA Script

The Get Data VBA script is a tool designed to perform specific operations on an Excel worksheet. It enables users to clear and retrieve data from specific ranges, format the retrieved data, and interact with an external data file. This script can be particularly useful for data management and manipulation tasks within Excel.

## Prerequisites
- Microsoft Excel installed on your system.
- Basic knowledge of working with Excel worksheets and VBA macros.

## Usage
1. Open your Excel workbook.
2. Press **ALT + F11** to open the Visual Basic Editor.
3. Insert a new module and copy the DeleteAndRetrieveData script into the module.
4. Close the Visual Basic Editor.
5. Ensure that the worksheet you want to perform the operations on is active.
6. Run the macro by pressing **ALT + F8** to open the macro dialog, selecting **DeleteAndRetrieveData**, and clicking "Run."

## Functionality
The DeleteAndRetrieveData script performs the following actions:

- Deletes values and formulas in columns A to H from row 4 down to the last row.
- Deletes a specified range (J5:BI4) and the cells below it until the last row with data.
- Retrieves data from an external data file (data.csv) and copies it to cells A4 to H4 and downward.
- AutoFills formulas in columns J and M to BI, based on the retrieved data.
- Applies specific border formatting to ranges J4 to BI and other specified ranges.
- Closes the external data file without saving changes.
- Deletes the external data file from the specified path (C:\Users\hvle\Downloads\).

**Note:** Make sure to update the file path and name in the script to match the location of your data.csv file.

## License
This project is licensed under the MIT License. For more information, please refer to the [LICENSE](LICENSE) file.

## Contact
For any questions or feedback regarding this VBA script, please feel free to contact the author at your-email@example.com.
