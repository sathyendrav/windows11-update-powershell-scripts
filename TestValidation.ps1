function Test-StringParsing {
    $lines = @()
    $lines += "Line 1"
    $lines += "Line 2"
    
    $output = $lines -join [Environment]::NewLine
    Write-Host "Output:"
    Write-Host $output
}

Test-StringParsing

Write-Host "`nTesting error variable:"
try {
    throw "Test error"
} catch {
    Write-Host "Error: $_"
}
