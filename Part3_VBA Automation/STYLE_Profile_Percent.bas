Attribute VB_Name = "SKU_Profile_percent"
Sub SKUPercentProfile()
    'On Error GoTo ErrorHandler
    'Application.ScreenUpdating = True
    Application.Calculation = xlCalculationManual

    '=============== SETUP ================
    Dim wsAnalysis As Worksheet, wsData As Worksheet
    Dim coverArr As Variant, dataArr As Variant, results() As Double, result1() As Double
    Dim lastAnalysisRow As Long, lastDataRow As Long
    Dim i As Long, j As Long, startCol As Integer, endCol As Integer
    Dim CurrentWeek As Long
    Dim lastrowC As Long
    
    Set wsAnalysis = ThisWorkbook.Sheets("Analysis")
    Set wsData = ThisWorkbook.Sheets("Data")
    
    CurrentWeek = 22 + DatePart("ww", Date, vbSunday, vbFirstFourDays) - 1
    If CurrentWeek < 22 Or CurrentWeek > 73 Then
        MsgBox "CurrentWeek is out of range: " & CurrentWeek, vbCritical
        Exit Sub
    End If


    '=============== READ DATA ================
    lastAnalysisRow = wsAnalysis.Cells(wsAnalysis.Rows.Count, "B").End(xlUp).Row
    coverArr = wsAnalysis.Range("B4:L" & lastAnalysisRow).Value
    lastDataRow = wsData.Cells(wsData.Rows.Count, "A").End(xlUp).Row
    dataArr = wsData.Range("A2:BU" & lastDataRow).Value

    '=============== PROCESS ================
    ReDim results(1 To UBound(coverArr, 1), 1 To 1)
    ReDim result1(1 To UBound(coverArr, 1), 1 To 1)
    ReDim result2(1 To UBound(coverArr, 1), 1 To 1)

    For i = 1 To UBound(coverArr, 1)
        Application.StatusBar = "Processing row " & i & " of " & UBound(coverArr, 1) & "..."
        Dim total As Double: total = 0
        Dim remaining As Double: remaining = 0
        Dim Percent As Double: Percent = 0
    
        Dim targetSKU As Long: targetSKU = CStr(coverArr(i, 1))
        Dim targetWeek As Integer: targetWeek = DatePart("ww", Date, vbSunday, vbFirstFourDays)
        startCol = 23 + (CStr(coverArr(i, 10)) - 1)
        endCol = startCol + (CInt(coverArr(i, 11)) - 1)
        'Debug.Print "startColxx:"; startCol
        'Debug.Print "endColxx:"; endCol
        
        'Debug.Print "targetWeek:"; targetWeek
    
        For j = 1 To UBound(dataArr, 1)
            If Not IsEmpty(dataArr(j, 5)) And Not IsEmpty(dataArr(j, 1)) Then
                If CStr(dataArr(j, 5)) = targetSKU And CLng(dataArr(j, 1)) = targetWeek Then
                    If endCol > 74 Then
                        ' Sum from startCol to 74
                        total = total + Application.Sum(wsData.Range(wsData.Cells(j + 1, startCol), wsData.Cells(j + 1, 74)))
                        ' Sum from 23 to targetWeek
                        total = total + Application.Sum(wsData.Range(wsData.Cells(j + 1, 23), wsData.Cells(j + 1, 23 + (CInt(coverArr(i, 7)) - 1))))
                        
                        ' Remaining logic for CurrentWeek
                        remaining = remaining + Application.Sum(wsData.Range(wsData.Cells(j + 1, 23), wsData.Cells(j + 1, 23 + 52 - 1)))
                        If remaining = 0 Then
                            Percent = 0
                        Else
                            Percent = total / remaining
                        End If
                    Else
                        ' Normal sum range
                        'total = total + Application.Sum(wsData.Range(wsData.Cells(j + 1, 23), wsData.Cells(j + 1, 23 + 52 - 1)))
                        total = total + Application.Sum(wsData.Range(wsData.Cells(j + 1, startCol), wsData.Cells(j + 1, endCol)))
                        remaining = remaining + Application.Sum(wsData.Range(wsData.Cells(j + 1, 23), wsData.Cells(j + 1, 23 + 52 - 1)))
                        If remaining = 0 Then
                            Percent = 0
                        Else
                            Percent = total / remaining
                        End If
                    End If
                End If
            End If
        Next j
    
        ' Store the total in the results array
        results(i, 1) = total
        result1(i, 1) = remaining
        result2(i, 1) = Percent
        
    
NextIteration:
    Next i

    '=============== WRITE RESULTS ================
    wsAnalysis.Range("AS4:AS" & lastAnalysisRow).Value = result2
    'wsCover.Range("H5:H" & lastCoverRow).Value = result1

    'Application.StatusBar = False
    'Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    ' MsgBox "Processed " & lastCoverRow - 4 & " rows in Cover sheet!", vbInformation
    'GoTo Line1
    

ErrorHandler:
    ' MsgBox "An error occurred: " & Err.Description, vbCritical
    'Application.StatusBar = False
    'Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    
    
End Sub

