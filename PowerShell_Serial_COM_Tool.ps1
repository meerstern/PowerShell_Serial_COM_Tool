<#
	Serial COM Tool
	https://github.com/meerstern/PowerShell_Serial_COM_Tool/
#>

Add-Type -AssemblyName System.Windows.Forms | Out-Null

$script:serialPort = $null
  
$form=New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(320, 330)
$form.Text="Serial COM Tool"
 
$label1=New-Object System.Windows.Forms.Label
$label1.Location=New-Object System.Drawing.Point(5,10)
$label1.Size=New-Object System.Drawing.Size(70,20)
$label1.Text="COM Port"
 
$label2=New-Object System.Windows.Forms.Label
$label2.Location=New-Object System.Drawing.Point(5,30)
$label2.Size=New-Object System.Drawing.Size(70,20)
$label2.Text="Send Data"
 
$textbox1=New-Object System.Windows.Forms.TextBox
$textbox1.Location=New-Object System.Drawing.Point(75,30)
$textbox1.Size=New-Object System.Drawing.Size(110,20)
$textbox1.Text=""

$button1=New-Object System.Windows.Forms.Button
$button1.Location=New-Object System.Drawing.Point(210,10)
$button1.Size=New-Object System.Drawing.Size(70,20)
$button1.Text="OPEN"
$button1.Add_Click({openSerialPort})
 
$button2=New-Object System.Windows.Forms.Button
$button2.Location=New-Object System.Drawing.Point(210,30)
$button2.Size=New-Object System.Drawing.Size(70,20)
$button2.Text="SEND"
$button2.Add_Click({sendCom})

$button3=New-Object System.Windows.Forms.Button
$button3.Location=New-Object System.Drawing.Point(210,50)
$button3.Size=New-Object System.Drawing.Size(70,20)
$button3.Text="CLEAR"
$button3.Add_Click({clearString})
 
$textbox2=New-Object System.Windows.Forms.TextBox
$textbox2.Location=New-Object System.Drawing.Point(5,80)
$textbox2.Size=New-Object System.Drawing.Size(295,200)
$textbox2.MultiLine=$true
$textbox2.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Location=New-Object System.Drawing.Point(75,10)
$comboBox.Size=New-Object System.Drawing.Size(110,20)

[System.IO.Ports.SerialPort]::GetPortNames() |
    Sort-Object |
    ForEach-Object {
        $null=$comboBox.Items.Add($_)
    }

if ($comboBox.Items.Count -gt 0) {
	$comboBox.SelectedIndex = 0
}


function sendCom(){
	if ($null -ne $script:serialPort) {
		$script:serialPort.WriteLine($textbox1.Text)
		$textbox1.Text=""
	}
}

function clearString(){
	$textBox2.Text = ""
}

function openSerialPort {

    if ($null -ne $script:serialPort) {
        $script:serialPort.Close()
        $script:serialPort.Dispose()
		$script:serialPort = $null
		$button1.Text="OPEN"
		Write-Host "COM Port is closed."
		return
    }

    $portName = $comboBox.SelectedItem

    if ($null -eq $portName) {
        [System.Windows.Forms.MessageBox]::Show("No COM Port")
        return
    }

    $script:serialPort = New-Object System.IO.Ports.SerialPort(
        $portName,
        9600,
        [System.IO.Ports.Parity]::None,
        8,
        [System.IO.Ports.StopBits]::One
    )
	

    try {		
        $script:serialPort.Open()
		$button1.Text="CLOSE"
		Write-Host "[$portName] is opened."
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "COM Open ERR:`n$($_.Exception.Message)"
        )
	
        if($null -ne $script:serialPort){
			$script:serialPort.Dispose()
		}
        $script:serialPort = $null
    }
}

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 50

$timer.Add_Tick({
    if ($null -ne $script:serialPort -and $script:serialPort.IsOpen) {
        if ($script:serialPort.BytesToRead -gt 0) {
            $data = $script:serialPort.ReadExisting()
            $textBox2.AppendText($data)
        }
    }
})

$timer.Start() 
$form.Controls.Add($label1)
$form.Controls.Add($label2)
$form.Controls.Add($textbox1)
$form.Controls.Add($button1)
$form.Controls.Add($button2)
$form.Controls.Add($button3)
$form.Controls.Add($textbox2)
$form.Controls.Add($comboBox)

Write-Host "App is Opened."
$form.ShowDialog()
Write-Host "App is Closed."



