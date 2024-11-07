param (
    [string]$FileName,
    [string]$VarName, 
    [string]$RainmeterPath,
    [string]$RefreshConfig
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Form Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "Rainmeter Hotkey Configuration"
$form.Size = New-Object System.Drawing.Size(420, 320)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

# Create Gradient Background as an Image
$gradientImage = New-Object System.Drawing.Bitmap(420, 320)
$graphics = [System.Drawing.Graphics]::FromImage($gradientImage)
$gradientBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    [System.Drawing.Rectangle]::FromLTRB(0, 0, $form.Width, $form.Height),
    [System.Drawing.Color]::RoyalBlue, [System.Drawing.Color]::LightSkyBlue,
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$graphics.FillRectangle($gradientBrush, 0, 0, $form.Width, $form.Height)
$gradientBrush.Dispose()
$graphics.Dispose()
$form.BackgroundImage = $gradientImage
$form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Configure Your Hotkey"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.BackColor = [System.Drawing.Color]::Transparent
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(100, 20)
$form.Controls.Add($titleLabel)

# Subtitle Label
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Choose modifiers and main key"
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$subtitleLabel.ForeColor = [System.Drawing.Color]::AliceBlue
$subtitleLabel.BackColor = [System.Drawing.Color]::Transparent
$subtitleLabel.AutoSize = $true
$subtitleLabel.Location = New-Object System.Drawing.Point(130, 50)
$form.Controls.Add($subtitleLabel)

# Tooltip
$tooltip = New-Object System.Windows.Forms.ToolTip
$tooltip.InitialDelay = 500
$tooltip.SetToolTip($subtitleLabel, "Selecting a modifier key is recommended.")

# Modifier Keys Label
$modifierLabel = New-Object System.Windows.Forms.Label
$modifierLabel.Text = "Modifier Keys:"
$modifierLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$modifierLabel.ForeColor = [System.Drawing.Color]::White
$modifierLabel.BackColor = [System.Drawing.Color]::Transparent
$modifierLabel.Location = New-Object System.Drawing.Point(20, 90)
$form.Controls.Add($modifierLabel)

# Dropdowns for Modifier Keys
$dropdownFont = New-Object System.Drawing.Font("Segoe UI", 9)
$modifierDropdown1 = New-Object System.Windows.Forms.ComboBox
$modifierDropdown1.Location = New-Object System.Drawing.Point(20, 120)
$modifierDropdown1.Size = New-Object System.Drawing.Size(120, 25)
$modifierDropdown1.Font = $dropdownFont
$modifierDropdown1.Items.AddRange(@("None", "Ctrl", "Alt", "Shift", "Win"))
$modifierDropdown1.SelectedIndex = 0
$form.Controls.Add($modifierDropdown1)

$modifierDropdown2 = New-Object System.Windows.Forms.ComboBox
$modifierDropdown2.Location = New-Object System.Drawing.Point(160, 120)
$modifierDropdown2.Size = New-Object System.Drawing.Size(120, 25)
$modifierDropdown2.Font = $dropdownFont
$modifierDropdown2.Items.AddRange(@("None", "Ctrl", "Alt", "Shift", "Win"))
$modifierDropdown2.SelectedIndex = 0
$form.Controls.Add($modifierDropdown2)

# Main Key Label
$mainKeyLabel = New-Object System.Windows.Forms.Label
$mainKeyLabel.Text = "Main Key:"
$mainKeyLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$mainKeyLabel.ForeColor = [System.Drawing.Color]::White
$mainKeyLabel.BackColor = [System.Drawing.Color]::Transparent
$mainKeyLabel.Location = New-Object System.Drawing.Point(20, 160)
$form.Controls.Add($mainKeyLabel)

# Textbox for Main Key with Single Character Restriction
$mainKeyTextbox = New-Object System.Windows.Forms.TextBox
$mainKeyTextbox.Size = New-Object System.Drawing.Size(120, 25)
$mainKeyTextbox.Location = New-Object System.Drawing.Point(20, 190)
$mainKeyTextbox.Font = $dropdownFont
$mainKeyTextbox.MaxLength = 1  # Restrict to a single character
$tooltip.SetToolTip($mainKeyTextbox, "Enter a single character key (e.g., T).")
$form.Controls.Add($mainKeyTextbox)

# Event Handler for KeyPress to allow only one character
$mainKeyTextbox.Add_KeyPress({
    param($sender, $e)

    if ($mainKeyTextbox.Text.Length -ge 1 -and $e.KeyChar -ne [char]::Backspace) {
        $e.Handled = $true  # Ignore further input if a character is already present
    }
})

# Save Button
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = "Save Hotkey"
$saveButton.Location = New-Object System.Drawing.Point(20, 240)
$saveButton.Size = New-Object System.Drawing.Size(360, 35)
$saveButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$saveButton.BackColor = [System.Drawing.Color]::DarkBlue
$saveButton.ForeColor = [System.Drawing.Color]::White
$saveButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$saveButton.FlatAppearance.BorderSize = 0

# Save Button Click Event
$saveButton.Add_Click({
    $modifiers = @($modifierDropdown1.Text, $modifierDropdown2.Text) | Where-Object { $_ -ne "None" }
    $mainKey = $mainKeyTextbox.Text.Trim()

    if ($modifiers.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Select at least one modifier key (e.g., Ctrl, Alt, Shift, or Win).", "Recommendation", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    if (-not $mainKey) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a main key.", "Input Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $hotkey = ($modifiers -join " ") + " " + $mainKey

    # Write to Rainmeter variable
    if (Test-Path $FileName) {
        $content = Get-Content -Path $FileName
        if ($content -match "$VarName=.*") {
            $content = $content -replace "$VarName=.*", "$VarName=$hotkey"
        } else {
            $content += "`n$VarName=$hotkey"
        }
        $content | Set-Content -Path $FileName

        if (Test-Path $RainmeterPath) {
            Start-Process -FilePath $RainmeterPath -ArgumentList "!Refresh", $RefreshConfig
            [System.Windows.Forms.MessageBox]::Show("Hotkey saved and skin refreshed successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } else {
            [System.Windows.Forms.MessageBox]::Show("Rainmeter executable not found.", "File Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Rainmeter skin file not found.", "File Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$form.Controls.Add($saveButton)
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
