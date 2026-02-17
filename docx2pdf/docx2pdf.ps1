$word = NEW-OBJECT -COMOBJECT WORD.APPLICATION

Write-Host "[Generate PDFs from DOCX's in current directory]"
$files = Get-ChildItem | Where-Object{ $_.Name -match "docx$" }
Write-Host "[Start process]"
foreach ($file in $files)
{
    try
    {
        $result = (Test-Path $file.FullName.Replace(".docx", ".pdf"))
        if ($result)
        {
            Write-Host "$( $file.Name ) ... file exists. Skipping"
        }
        else
        {
            Write-Host "$( $file.Name ) ... processing"
            $doc = $word.Documents.OpenNoRepairDialog($file.FullName)
            $doc.SaveAs([ref] $file.FullName.Replace(".docx", ".pdf"), [ref]17)
#            $doc.Close()
            Write-Host "$($file.FullName.Replace(".docx", ".pdf") ) ... converted"
        }
    }
    catch
    {
        Write-Host "[ERROR]$( $file.Name ) ... conversion failed"
    }
}
Write-Host "[Process ended]"
$word.Quit()
