Attribute VB_Name = "Cover_sheet"
Sub SumDynamicColumns()
    'On Error GoTo ErrorHandler
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationManual


    '=============== SETUP ================
    Dim wsCover As Worksheet, wsData As Worksheet
    Dim coverArr As Variant, dataArr As Variant, results() As Double, result1() As Double
    Dim lastCoverRow As Long, lastDataRow As Long
    Dim i As Long, j As Long, startCol As Integer, endCol As Integer
    Dim CurrentWeek As Long
    Dim lastrowC As Long
    
    Set wsCover = ThisWorkbook.Sheets("Cover")
    Set wsData = ThisWorkbook.Sheets("Data")
    
    CurrentWeek = 22 + DatePart("ww", Date, vbSunday, vbFirstFourDays) - 1
    If CurrentWeek < 22 Or CurrentWeek > 73 Then
        MsgBox "CurrentWeek is out of range: " & CurrentWeek, vbCritical
        Exit Sub
    End If



    '=============== READ DATA ================
    lastCoverRow = wsCover.Cells(wsCover.Rows.Count, "C").End(xlUp).Row
    coverArr = wsCover.Range("C5:F" & lastCoverRow).Value
    lastDataRow = wsData.Cells(wsData.Rows.Count, "A").End(xlUp).Row
    dataArr = wsData.Range("A2:BU" & lastDataRow).Value

    '=============== PROCESS ================
    ReDim results(1 To UBound(coverArr, 1), 1 To 1)
    ReDim result1(1 To UBound(coverArr, 1), 1 To 1)

    For i = 1 To UBound(coverArr, 1)
        Application.StatusBar = "Processing row " & i & " of " & UBound(coverArr, 1) & "..."
        Dim total As Double: total = 0
        Dim remaining As Double: remaining = 0
    
        Dim targetStyle As String: targetStyle = CStr(coverArr(i, 1))
        Dim targetWeek As Integer: targetWeek = CInt(coverArr(i, 3)) Mod 100
        startCol = 23 + (targetWeek - 1)
        endCol = startCol + (CInt(coverArr(i, 4)) Mod 100 - 1)
    
        ' Validate column range
        'If startCol < 22 Or startCol > endCol Then
        '    results(i, 1) = 0
        '    result1(i, 1) = 0
        '    GoTo NextIteration
        'End If
    
        For j = 1 To UBound(dataArr, 1)
            If Not IsEmpty(dataArr(j, 6)) And Not IsEmpty(dataArr(j, 1)) Then
                If CStr(dataArr(j, 6)) = targetStyle And CLng(dataArr(j, 1)) = targetWeek Then
                    If endCol > 74 Then
                        ' Sum from startCol to 74
                        total = total + Application.Sum(wsData.Range(wsData.Cells(j + 1, startCol), wsData.Cells(j + 1, 74)))
                        ' Sum from 23 to targetWeek
                         total = total + Application.Sum(wsData.Range(wsData.Cells(j + 1, 23), wsData.Cells(j + 1, 23 + (CInt(coverArr(i, 4)) Mod 100 - 1))))
                        
                        ' Remaining logic for CurrentWeek
                        remaining = remaining + Application.Sum(wsData.Range(wsData.Cells(j + 1, CurrentWeek), wsData.Cells(j + 1, 23 + (CInt(coverArr(i, 4)) Mod 100 - 1))))
                    Else
                        ' Normal sum range
                        total = total + Application.Sum(wsData.Range(wsData.Cells(j + 1, startCol), wsData.Cells(j + 1, endCol)))
                        remaining = remaining + Application.Sum(wsData.Range(wsData.Cells(j + 1, CurrentWeek), wsData.Cells(j + 1, endCol)))
                    End If
                End If
            End If
        Next j
    
        ' Store the total in the results array
        results(i, 1) = total
        result1(i, 1) = remaining
    
NextIteration:
    Next i

    '=============== WRITE RESULTS ================
    wsCover.Range("G5:G" & lastCoverRow).Value = results
    wsCover.Range("H5:H" & lastCoverRow).Value = result1

    Application.StatusBar = False
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    ' MsgBox "Processed " & lastCoverRow - 4 & " rows in Cover sheet!", vbInformation
    GoTo Line1
    

ErrorHandler:
    MsgBox "An error occurred: " & Err.Description, vbCritical
    Application.StatusBar = False
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    
    
Line1:
    Dim lastrowCafter As Long
    lastrowCafter = wsCover.Cells(wsCover.Rows.Count, "C").End(xlUp).Row
    'logger.Log lastrowC
    If lastrowCafter > 5 Then
        wsCover.Range("I5:U5").AutoFill Destination:=wsCover.Range("I5:U" & lastrowCafter)
        
    End If
End Sub
