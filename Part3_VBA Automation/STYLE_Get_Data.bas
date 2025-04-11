Attribute VB_Name = "Get_Data"

Sub get_data()
    Dim sh3 As Worksheet
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim range_to_format As Range
    Application.ScreenUpdating = False
    
    
    ' Unfilter and delete current data
    Set sh4 = Sheet4
    
    sh4.ListObjects(1).AutoFilter.ShowAllData
    
    lastRow = sh4.Cells(sh4.Rows.Count, "A").End(xlUp).Row

    If lastRow > 2 Then
        sh4.Range("A2:BX" & lastRow).Delete Shift:=xlUp
    End If
    
    ' Delete Cover rows
    Dim wsCover As Worksheet
    Set wsCover = ThisWorkbook.Sheets("Cover")
    Dim lastrowC As Long
    
    lastrowC = wsCover.Cells(wsCover.Rows.Count, "C").End(xlUp).Row
    
    If lastrowC > 5 Then
        wsCover.Range("A6:U" & lastrowC).Delete Shift:=xlUp
    End If
    
    
    ' Get data
    
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
        GoTo Line1
    End If
    

    
    ' Open the data file
    Set wb = Workbooks.Open(filePath)
    
    Set dataWs = wb.Worksheets("data")
    
    lastRow = dataWs.Cells(dataWs.Rows.Count, "A").End(xlUp).Row
    
    Dim dataRange As Range
    Set dataRange = dataWs.Range("A2:BV" & lastRow)
    dataRange.Copy Destination:=sh4.Range("A2")
    sh4.Range("BW2").Formula2 = "=XLOOKUP(F2,Cover!$C$5:$C$1500,Cover!$A$5:$A$1500)"
    sh4.Range("BX2").Formula2 = "=INDEX(Data[@[1]:[52]],0,[@[FISCAL_WEEK]])"
    wb.Close SaveChanges:=False
    Kill filePath
    
Line1:


    
    Dim lastrowCafter As Long
    
    wsCover.Range("C5").Formula2 = "=UNIQUE(Data[STYLE_DISPLAY_NUMBER])"
    lastrowCafter = wsCover.Cells(wsCover.Rows.Count, "C").End(xlUp).Row
    'logger.Log lastrowC
    If lastrowCafter > 5 Then
        wsCover.Range("C5:C" & lastrowCafter).Copy
        wsCover.Range("C5:C" & lastrowCafter).PasteSpecial xlPasteValues
        wsCover.Range("D5:F5").AutoFill Destination:=wsCover.Range("D5:F" & lastrowCafter)
        wsCover.Range("A5:B5").AutoFill Destination:=wsCover.Range("A5:B" & lastrowCafter)
        
    End If
    
End Sub


