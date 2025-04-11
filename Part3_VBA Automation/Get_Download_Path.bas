Attribute VB_Name = "Get_Download_path"
Function GetDownloadsPath() As String
    GetDownloadsPath = Environ$("USERPROFILE") & "\Downloads\"
End Function
