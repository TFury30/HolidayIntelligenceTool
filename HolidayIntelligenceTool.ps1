param (
    [ValidateSet("US", "EU", "Asia")]
    [string]$Region = "US",

    [switch]$UseApi,

    [switch]$Notify,

    [switch]$ExportIcs,

    [switch]$ShowGui,

    [switch]$RegisterReminder
)

# region === Mapping Region to Country Codes ===
function Get-CountryCodeFromRegion {
    param ($Region)

    switch ($Region.ToUpper()) {
        "US"   { return "US" }
        "EU"   { return "DE" } # Germany as a sample for EU
        "Asia" { return "IN" } # India for Asia
        default { return "US" }
    }
}
# endregion

# region === API Integration ===
function Get-ApiHolidays {
    param (
        [string]$CountryCode,
        [int]$Year
    )

    $url = "https://date.nager.at/api/v3/PublicHolidays/$Year/$CountryCode"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
        $response | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.localName
                Date = [datetime]$_.date
                Type = $_.types -join ", "
            }
        }
    } catch {
        Write-Warning " API request failed: $_"
        return @()
    }
}
# endregion

# region === ICS Export ===
function Export-HolidaysToIcs {
    param ($Holidays)

    $sb = @()
    $sb += "BEGIN:VCALENDAR"
    $sb += "VERSION:2.0"
    $sb += "PRODID:-//PowerShell Holidays//EN"

    foreach ($h in $Holidays) {
        $date = $h.Date.ToString("yyyyMMdd")
        $sb += "BEGIN:VEVENT"
        $sb += "SUMMARY:$($h.Name)"
        $sb += "DTSTART;VALUE=DATE:$date"
        $sb += "DTEND;VALUE=DATE:$date"
        $sb += "DESCRIPTION:$($h.Type)"
        $sb += "END:VEVENT"
    }

    $sb += "END:VCALENDAR"
    $sb -join "`r`n" | Set-Content -Path "./Holidays-$Region.ics" -Encoding UTF8

    Write-Host " Exported to Holidays-$Region.ics"
}
# endregion

# region === Notification ===
function Send-Notification {
    param ($Holiday)

    if (-not (Get-Module -ListAvailable -Name BurntToast)) {
        Install-Module BurntToast -Force -Scope CurrentUser
    }

    Import-Module BurntToast
    New-BurntToastNotification -Text "Next Holiday", "$($Holiday.Name) is in $((($Holiday.Date - (Get-Date)).Days)) day(s)!"
}
# endregion

# region === Task Scheduler Setup ===
function Register-HolidayReminderTask {
    $scriptPath = $MyInvocation.MyCommand.Path
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"$scriptPath`" -Region $Region -UseApi -Notify"
    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 9am
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

    Register-ScheduledTask -TaskName "HolidayNotifier" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force

    Write-Host "📅 Scheduled weekly holiday reminder (every Monday at 9am)." -ForegroundColor Cyan
}
# endregion

# region === GUI ===
function Show-Gui {
    param ($Holidays)
    $Holidays | Out-GridView -Title "📅 All Upcoming Holidays"
}
# endregion

# region === Execution ===

$year = (Get-Date).Year
$cc = Get-CountryCodeFromRegion -Region $Region

if ($UseApi) {
    $allHolidays = Get-ApiHolidays -CountryCode $cc -Year $year
} else {
    Write-Host "⚠ API Mode not enabled. Use -UseApi to enable online holiday data."
    exit
}

$today = Get-Date
$next = $allHolidays | Where-Object { $_.Date -gt $today } | Sort-Object Date | Select-Object -First 1

if ($null -eq $next) {
    Write-Host " No upcoming holidays found." -ForegroundColor Yellow
    exit
}

Write-Host "`n Next Holiday: $($next.Name) on $($next.Date.ToString("D")) ($($next.Type))"
Write-Host " In $((($next.Date - $today).Days)) day(s)`n"

if ($Notify) {
    Send-Notification -Holiday $next
}
if ($ExportIcs) {
    Export-HolidaysToIcs -Holidays $allHolidays
}
if ($ShowGui) {
    Show-Gui -Holidays $allHolidays
}
if ($RegisterReminder) {
    Register-HolidayReminderTask
}

# endregion
