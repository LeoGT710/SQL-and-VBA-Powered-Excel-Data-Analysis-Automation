Attribute VB_Name = "Module1"
Sub DeleteAndRetrieveData()
    Dim sh3 As Worksheet
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim range_to_format As Range
    
    
    ' Get a reference to the active worksheet
    Set sh4 = Sheet4
    sh4.ListObjects(1).AutoFilter.ShowAllData
    
    ' Find the last row with data in column A
    lastRow = sh4.Cells(sh4.Rows.Count, "A").End(xlUp).Row
    
    ' Clear the values and formulas in columns A to H from row 4 down to the last row
    If lastRow > 2 Then
        sh4.Range("A2:BT" & lastRow).Delete Shift:=xlUp
    End If
    
    
    ' Delete the range J5:BJ4 and the cells below it until the last row with data
    
    Set ws = Sheet3
    
    Dim lastRowA As Long
    lastRowA = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    Set rangetoformat = Union(ws.Range("A4:J" & lastRowA), ws.Range("K4:L" & lastRowA), ws.Range("N4:W" & lastRowA), ws.Range("AA4:AD" & lastRowA), ws.Range("AF4:AI" & lastRowA), ws.Range("AK4:AN" & lastRowA), ws.Range("AP4:AQ" & lastRowA), ws.Range("AS4:AV" & lastRowA), ws.Range("AX4:BA" & lastRowA))
    rangetoformat.Borders.LineStyle = xlNone
    'rangetoformat.ClearFormats
    
    Set rangetoCLEARformatY = ws.Range("Z4:Z" & lastRowA)
    rangetoCLEARformatY.Borders.LineStyle = xlNone ' Remove existing borders
    rangetoCLEARformatY.ClearFormats
    
    If lastRowA > 4 Then
        ws.Range("A5:BH" & lastRowA).ClearContents
    End If
    

    Dim dataWs As Worksheet
    Dim filePath As String
    Dim fileName As String
    Dim wb As Workbook
    
    ' Set the path and filename of the data file
    filePath = GetDownloadsPath()
    fileName = "data.csv"
    
    ' Construct the full file path
    filePath = filePath & fileName
    
    ' Check if thefile exists
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
    Set dataRange = dataWs.Range("A2:BT" & lastRow)
    
    ' For example, you can copy the data to another location in the active worksheet:
    dataRange.Copy Destination:=sh4.Range("A2")
    
    sh4.Range("BT2").Formula2 = "=IFERROR(INDEX(T2:BS2,0,A2),0)"
    'sh4.Range("BT2:BT" & lastRow).Copy
    'sh4.Range("BT2:BT" & lastRow - 1).PasteSpecial xlPasteValues
    
    ws.Range("B4").Formula2 = _
    "=SORTBY(UNIQUE(Data[SKU_DISPLAY_NUMBER])," & _
    "XLOOKUP(UNIQUE(Data[SKU_DISPLAY_NUMBER]),Data[SKU_DISPLAY_NUMBER],Data[US_CHAIN_PRICE]),1," & _
    "XLOOKUP(UNIQUE(Data[SKU_DISPLAY_NUMBER]),Data[SKU_DISPLAY_NUMBER],Data[SKU_NAME]),1)"
    
    ws.Range("A4").Formula2 = "=iferror(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[STYLE_DISPLAY_NUMBER]),0)"
    ws.Range("C4").Formula2 = "=TRIM(IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[SKU_NAME]:Data[SKU_NAME]),0))"
    ws.Range("D4").Formula2 = "=IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[SKU_COLOR]),0)"
    ws.Range("E4").Formula2 = "=IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[SKU_SIZE]),0)"
    ws.Range("F4").Formula2 = "=IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[T_DATE]),0)"
    ws.Range("G4").Formula2 = "=IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[OH_OO]),0)"
    ws.Range("H4").Formula2 = "=IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[US_CHAIN_PRICE]),0)"
    ws.Range("I4").Formula2 = "=IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[ANNUAL FCST]),0)"
    ws.Range("J4").Formula2 = "=SUMIF(Data[SKU_DISPLAY_NUMBER],B4,Data[TREND])"
    ws.Range("O4").Formula2 = "=MINIFS(Data[FISCAL_WEEK],Data[SKU_DISPLAY_NUMBER],$B4,Data[FISCAL YEAR],N$3,Data[PRICE],""<>"" & """")"
    ws.Range("P4").Formula2 = "=MAXIFS(Data[FISCAL_WEEK],Data[SKU_DISPLAY_NUMBER],$B4,Data[FISCAL YEAR],N$3,Data[PRICE],""<>"" & """")"
     
    ws.Range("R4").Formula2 = "=MINIFS(Data[FISCAL_WEEK],Data[SKU_DISPLAY_NUMBER],$B4,Data[FISCAL YEAR],Q$3,Data[PRICE],""<>"" & """")"
    ws.Range("S4").Formula2 = "=MAXIFS(Data[FISCAL_WEEK],Data[SKU_DISPLAY_NUMBER],$B4,Data[FISCAL YEAR],Q$3,Data[PRICE],""<>"" & """")"
    
    ws.Range("U4").Formula2 = "=MINIFS(Data[FISCAL_WEEK],Data[SKU_DISPLAY_NUMBER],$B4,Data[FISCAL YEAR],T$3,Data[PRICE],""<>"" & """")"
    ws.Range("V4").Formula2 = "=MAXIFS(Data[FISCAL_WEEK],Data[SKU_DISPLAY_NUMBER],$B4,Data[FISCAL YEAR],T$3,Data[PRICE],""<>"" & """")"
    
    ws.Range("X4").Formula2 = "=MINIFS(Data[FISCAL_WEEK],Data[SKU_DISPLAY_NUMBER],$B4,Data[FISCAL YEAR],W$3,Data[SALES_UNITS],"">0"",Data[FISCAL_WEEK],""<="" & WEEKNUM(TODAY()))"
    ws.Range("Y4").Formula2 = "=MaxIFS(Data[FISCAL_WEEK],Data[SKU_DISPLAY_NUMBER],$B4,Data[FISCAL YEAR],W$3,Data[SALES_UNITS],"">0"",Data[FISCAL_WEEK],""<="" & WEEKNUM(TODAY()))"
    
    
    
  ' Copy the formulas from row 4 down to the last row of column K
    Dim lastRowB As Long
    lastRowB = ws.Cells(ws.Rows.Count, "B").End(xlUp).Row
    If lastRowB > 4 Then
        ws.Range("B4:B" & lastRowB).Copy
        ws.Range("B4:B" & lastRowB).PasteSpecial xlPasteValues
        ' AutoFill column J from J4 to lastRowK
        ws.Range("A4").AutoFill Destination:=ws.Range("A4:A" & lastRowB)
        ws.Range("A4:A" & lastRowB).Copy
        ws.Range("A4:A" & lastRowB).PasteSpecial xlPasteValues
        
        ' AutoFill columns M to BJ from M4 to lastRowK
        ws.Range("C4:BJ4").AutoFill Destination:=ws.Range("C4:BJ" & lastRowB)
        ws.Range("C4:J" & lastRowB).Copy
        ws.Range("C4:J" & lastRowB).PasteSpecial xlPasteValues
        ws.Range("O4:P" & lastRowB).Copy
        ws.Range("O4:P" & lastRowB).PasteSpecial xlPasteValues
        
        ws.Range("R4:S" & lastRowB).Copy
        ws.Range("R4:S" & lastRowB).PasteSpecial xlPasteValues
        ws.Range("U4:V" & lastRowB).Copy
        ws.Range("U4:V" & lastRowB).PasteSpecial xlPasteValues
        
        ws.Range("X4:Y" & lastRowB).Copy
        ws.Range("X4:Y" & lastRowB).PasteSpecial xlPasteValues
        
    End If
    
    Dim last_row_format As Integer
    last_row_format = ws.Cells(ws.Rows.Count, "B").End(xlUp).Row
If last_row_format < 4 Then
    last_row_format = 4
End If

Set rangetoformat = Union(ws.Range("A4:J" & last_row_format), ws.Range("K4:L" & last_row_format), ws.Range("N4:Y" & last_row_format), ws.Range("AA4:AD" & last_row_format), ws.Range("AF4:AI" & last_row_format), ws.Range("AK4:AN" & last_row_format), ws.Range("AP4:AQ" & last_row_format), ws.Range("AS4:AV" & last_row_format), ws.Range("AX4:BA" & last_row_format))
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

'With rangetoformat.Borders(xlEdgeTop)
 '   .LineStyle = xlContinuous
  '  .Weight = xlThick
  '  .Color = RGB(0, 0, 0)
'End With

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

Set rangetoformatY = ws.Range("Z2:Z" & last_row_format)

With rangetoformatY.Borders(xlEdgeLeft)
    .LineStyle = xlContinuous
    .Weight = xlThick
    .Color = RGB(0, 0, 0)
End With
    
    
    ' Close the data file without saving changes
    wb.Close SaveChanges:=False
    
    Kill filePath
    
    ' Enable screen updating
    Application.ScreenUpdating = True
    
End Sub



