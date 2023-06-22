Sub DeleteAndRetrieveData()
    Dim ws As Worksheet
    Dim lastRow As Integer
    Dim range_to_format As Range
    
    
    ' Get a reference to the active worksheet
    Set ws = ActiveSheet
    
    ' Find the last row with data in column A
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' Clear the values and formulas in columns A to H from row 4 down to the last row
    If lastRow > 4 Then
        ws.Range("A4:H" & lastRow).Delete Shift:=xlUp
    End If
    
    
    ' Delete the range J5:BI4 and the cells below it until the last row with data
    
    Dim lastRowJ As Long
    lastRowJ = ws.Cells(ws.Rows.Count, "J").End(xlUp).Row
    
    Set rangetoformat = Union(ws.Range("J4:K" & lastRowJ), ws.Range("M4:N" & lastRowJ), ws.Range("P4:AA" & lastRowJ), ws.Range("AC4:AF" & lastRowJ), ws.Range("AH4:AK" & lastRowJ), ws.Range("AM4:AP" & lastRowJ), ws.Range("AR4:AU" & lastRowJ), ws.Range("AY4:BB" & lastRowJ), ws.Range("BF4:BI" & lastRowJ), ws.Range("AW4:AW" & lastRowJ), ws.Range("BD4:BD" & lastRowJ))
    rangetoformat.Borders.LineStyle = xlNone
    'rangetoformat.ClearFormats
    
    If lastRowJ >= 5 Then
        ws.Range("J5:BI" & lastRowJ).ClearContents
    End If
    

    Dim dataWs As Worksheet
    Dim filePath As String
    Dim fileName As String
    Dim wb As Workbook
    
    ' Set the path and filename of the data file
    filePath = "C:\Users\hvle\Downloads\"
    fileName = "data.csv"
    
    ' Construct the full file path
    filePath = filePath & fileName
    
    ' Check if the file exists
    If Dir(filePath) = "" Then
        MsgBox "The file 'data.csv' does not exist in the Downloads folder!", vbExclamation
        Exit Sub
    End If
    
    ' Disable screen updating to speed up the code execution
    Application.ScreenUpdating = False
    
    ' Open the data file
    Set wb = Workbooks.Open(filePath)
    
    ' Set the worksheet from which to retrieve the data
    Set dataWs = wb.Worksheets("data") ' Assuming the data is in the first worksheet
    
    ' Find the last row with data in column A of the data worksheet
    lastRow = dataWs.Cells(dataWs.Rows.Count, "A").End(xlUp).Row
    
    ' Retrieve the data from cells A2 to H2 down until the last row
    Dim dataRange As Range
    Set dataRange = dataWs.Range("A2:H" & lastRow)
    
    ' Now you can use the 'dataRange' variable to work with the retrieved data as needed
    ' For example, you can copy the data to another location in the active worksheet:
    dataRange.Copy Destination:=ws.Range("A4")
    
    
  ' Copy the formulas from row 4 down to the last row of column K
    Dim lastRowK As Long
    lastRowK = ws.Cells(ws.Rows.Count, "K").End(xlUp).Row
    If lastRowK >= 5 Then
        ' AutoFill column J from J4 to lastRowK
        ws.Range("J4").AutoFill Destination:=ws.Range("J4:J" & lastRowK)
        
        ' AutoFill columns M to BI from M4 to lastRowK
        ws.Range("M4:BI4").AutoFill Destination:=ws.Range("M4:BI" & lastRowK)
    End If
    
    Dim last_row_format As Integer
    last_row_format = ws.Cells(ws.Rows.Count, "J").End(xlUp).Row
If last_row_format < 4 Then
    last_row_format = 4
End If

Set rangetoformat = Union(ws.Range("J4:K" & last_row_format), ws.Range("M4:N" & last_row_format), ws.Range("P4:R" & last_row_format), ws.Range("S4:U" & last_row_format), ws.Range("V4:X" & last_row_format), ws.Range("Y4:AA" & last_row_format), ws.Range("AC4:AF" & last_row_format), ws.Range("AH4:AK" & last_row_format), ws.Range("AM4:AP" & last_row_format), ws.Range("AR4:AU" & last_row_format), ws.Range("AY4:BB" & last_row_format), ws.Range("BF4:BI" & last_row_format), ws.Range("AW4:AW" & last_row_format), ws.Range("BD4:BD" & last_row_format))
rangetoformat.Borders.LineStyle = xlNone ' Remove existing borders

With rangetoformat.Borders(xlEdgeLeft)
    .LineStyle = xlContinuous
    .Weight = xlThick
    .Color = RGB(0, 0, 0)
End With

With rangetoformat.Borders(xlEdgeRight)
    .LineStyle = xlContinuous
    .Weight = xlThick
    .Color = RGB(0, 0, 0)
End With

With rangetoformat.Borders(xlEdgeTop)
    .LineStyle = xlContinuous
    .Weight = xlThick
    .Color = RGB(0, 0, 0)
End With

With rangetoformat.Borders(xlEdgeBottom)
    .LineStyle = xlContinuous
    .Weight = xlThick
    .Color = RGB(0, 0, 0)
End With

' Apply outline border to the entire range
With rangetoformat.Borders(xlInsideHorizontal)
    .LineStyle = xlNone
End With

With rangetoformat.Borders(xlInsideVertical)
    .LineStyle = xlNone
End With
    
    
    ' Close the data file without saving changes
    wb.Close SaveChanges:=False
    
    Kill filePath
    
    ' Enable screen updating
    Application.ScreenUpdating = True
    
End Sub


