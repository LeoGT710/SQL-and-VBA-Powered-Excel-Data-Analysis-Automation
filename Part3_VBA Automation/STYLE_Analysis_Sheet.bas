Attribute VB_Name = "Analysis_sheet"
Sub main()
    DeleteAndRetrieveData
    SKUPercentProfile
End Sub




Sub DeleteAndRetrieveData()
    Dim sh3 As Worksheet
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim range_to_format As Range
    ' Application.ScreenUpdating = True
       
    
    ' Delete the range J5:BJ4 and the cells below it until the last row with data
    
    Set ws = Sheet3
    
    Dim lastRowA As Long
    lastRowA = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    Set rangetoformat = Union(ws.Range("A4:J" & lastRowA), ws.Range("K4:L" & lastRowA), ws.Range("N4:Y" & lastRowA), ws.Range("AA4:AD" & lastRowA), ws.Range("AF4:AI" & lastRowA), ws.Range("AK4:AN" & lastRowA), ws.Range("AP4:AS" & lastRowA), ws.Range("AU4:AW" & lastRowA))
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
    
   
    
    ' Disable screen updating to speed up the code execution
    Application.ScreenUpdating = False
    
    
    'sh4.Range("BT2").Formula2 = "=IFERROR(INDEX(U2:BS2,0,A2),0)"
    'sh4.Range("BT2:BT" & lastRow).Copy
    'sh4.Range("BT2:BT" & lastRow - 1).PasteSpecial xlPasteValues
    
    ws.Range("B4").Formula2 = "=iferror(UNIQUE(FILTER(Data[SKU_DISPLAY_NUMBER],Data[53]=TRUE)),0)"
    ws.Range("A4").Formula2 = "=iferror(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[STYLE_DISPLAY_NUMBER]),0)"
    ws.Range("C4").Formula2 = "=TRIM(IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[SKU_NAME]:Data[SKU_NAME]),0))"
    ws.Range("D4").Formula2 = "=IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[SKU_COLOR]),0)"
    ws.Range("E4").Formula2 = "=IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[SKU_SIZE]),0)"
    ws.Range("F4").Formula2 = "=IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[T_DATE]),0)"
    ws.Range("G4").Formula2 = "=IFERROR(XLOOKUP(B4,Data[SKU_DISPLAY_NUMBER],Data[OH]),0)"
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
    
    
    
'Copy the formulas from row 4 down to the last row of column K
    Dim lastRowB As Long
    lastRowB = ws.Cells(ws.Rows.Count, "B").End(xlUp).Row
    If lastRowB >= 4 Then
        ws.Range("B4:B" & lastRowB).Copy
        ws.Range("B4:B" & lastRowB).PasteSpecial xlPasteValues
    End If
    
    If lastRowB > 4 Then
        'ws.Range("B4:B" & lastRowB).Copy
        'ws.Range("B4:B" & lastRowB).PasteSpecial xlPasteValues
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
  '
        ws.Range("R4:S" & lastRowB).Copy
        ws.Range("R4:S" & lastRowB).PasteSpecial xlPasteValues
        ws.Range("U4:V" & lastRowB).Copy
        ws.Range("U4:V" & lastRowB).PasteSpecial xlPasteValues
  '
        ws.Range("X4:Y" & lastRowB).Copy
        ws.Range("X4:Y" & lastRowB).PasteSpecial xlPasteValues
  
    End If

    Dim last_row_format As Integer
    last_row_format = ws.Cells(ws.Rows.Count, "B").End(xlUp).Row
If last_row_format < 4 Then
    last_row_format = 4
End If

Set rangetoformat = Union(ws.Range("A4:J" & last_row_format), ws.Range("K4:L" & last_row_format), ws.Range("N4:Y" & last_row_format), ws.Range("AA4:AD" & last_row_format), ws.Range("AF4:AI" & last_row_format), ws.Range("AK4:AN" & last_row_format), ws.Range("AP4:AS" & last_row_format), ws.Range("AU4:AW" & last_row_format))
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

'Apply outline border to the entire range
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
    
    ' Kill filePath
    
    ' Enable screen updating
    Application.ScreenUpdating = False
    
End Sub
