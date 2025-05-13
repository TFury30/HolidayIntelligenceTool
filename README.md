---


# Holiday Intelligence Tool - PowerShell

This PowerShell script provides a flexible and extensible way to track upcoming public holidays across multiple regions. It supports dynamic holiday calculations, live data from APIs, notifications, GUI interaction, and calendar file exports.

## Features

- Multi-region support: US, EU (Germany/France), Asia (India/China/Japan)
- Live holiday data via the Nager.Date public API
- Local fallback for static and calculated holidays (e.g., Thanksgiving)
- Export holidays to `.ics` calendar files (compatible with Outlook, Google Calendar, Proton, etc.)
- Windows Toast notifications for upcoming holidays
- Interactive GUI with `Out-GridView` (Windows only)
- Option to schedule a weekly reminder using Windows Task Scheduler

## Supported Regions

The script maps region aliases to country codes for API compatibility:

| Region | Country Code | Description                     |
|--------|--------------|---------------------------------|
| US     | US           | United States                   |
| EU     | DE           | Sample: Germany/France          |
| Asia   | IN           | Sample: India/China/Japan       |

You can easily extend support for more regions by modifying the region-to-country mapping function.

## Getting Started

### Clone the Repository

```powershell
git clone https://github.com/TFury30/HolidayIntelligenceTool.git
cd HolidayIntelligenceTool
```

### Run the Script

Example: Get upcoming holidays in the US using the API, notify user, and export calendar:

```powershell
.\Get-NextHoliday.ps1 -Region US -UseApi -Notify -ExportIcs
```

## Parameters

| Parameter           | Description                                       |
| ------------------- | ------------------------------------------------- |
| `-Region`           | Region code (`US`, `EU`, `Asia`)                  |
| `-UseApi`           | Enable live data from Nager.Date API              |
| `-Notify`           | Trigger a toast notification for the next holiday |
| `-ExportIcs`        | Save upcoming holidays to an `.ics` calendar file |
| `-ShowGui`          | Display all holidays in a grid view               |
| `-RegisterReminder` | Create a scheduled task to run the script weekly  |

## Proton Calendar Integration

Proton Calendar does not currently provide a public API. However, it supports importing `.ics` files:

1. Run the script with `-ExportIcs`
2. Upload the resulting `.ics` file manually to your Proton Calendar
3. (Optional for ProtonMail Plus/Visionary users) Host the `.ics` file online and subscribe to it via URL

## Requirements

* PowerShell 5.1+ or PowerShell Core (7+)
* Internet access (for `-UseApi`)
* `BurntToast` module (for `-Notify`, auto-installed)
* `Out-GridView` (for `-ShowGui`, Windows only)

## Extending the Script

This project is modular by design. You can extend it by:

* Adding new countries or holidays
* Replacing the API with Calendarific or other sources
* Integrating with web dashboards or productivity tools
* Writing tests and coverage reports

## License

MIT License

---

