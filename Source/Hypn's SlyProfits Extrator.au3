$filename = FileOpenDialog('Please select your SlyProfits data file', "*.*", "All Files (*.*)", 1)

If (StringLen($filename) > 0) Then
	
	; read the contents in from the user-selected file
	$file = FileOpen($filename, 0)
	$file_contents = ""
	While 1
		$line = FileReadLine($file)
		If @error = -1 Then ExitLoop
		$file_contents = $file_contents & "|" & $line
	Wend
	FileClose($file)
	
	; split the file data into an array
	$file_data = StringSplit($file_contents, "|")
	
	; create the CSV file and write headers
	$file = FileOpen(@ScriptDir & "\SlyProfits.csv", 2)
	FileWrite($file, 'Item,Buyout Per Item,Cost Total,Profit Total' & @CRLF)
	
	; used for filtering out duplicate records
	$already_processed  = "|"
	
	For $i = 2 to UBound($file_data, 1) - 1
		$line = StringStripWS($file_data[$i], 3)
		
		
		If $line == 'click "Scan"' Then
			$i = $i + 22
		Else
			If NOT StringIsInt($line) Then
				If  $line == 'OLD:' OR $line  == 'Mats' OR $line  == 'Mats:' OR $line  == 'Recipes' OR $line  == '[No Auctions Found]' OR $line  == '[No Auctions Found]' OR $line  == '[No Cost Calculated]' OR $line  == '[No Profit Calculated]' OR $line  == 'Buy' OR $line  == 'Cost Total' Then
					; do nothing :D
				Else
					$name = $line;
					$sale_price = ($file_data[$i+3]/100) + $file_data[$i+4];
					$cost_price = ($file_data[$i+9]/100) + $file_data[$i+10];
					
					; check that we have a sale and cost price, if not reset the profit to 0
					If $sale_price > 0 AND $cost_price > 0 Then
						$profit = Round((($file_data[$i+12]/100) + $file_data[$i+13]), 2);
					Else
						$profit = 0
					EndIf
					
					; check if we've already processed this item
					If StringInStr($already_processed, '|' & $line & '|', 2) Then
						; do nothing :D
					Else
						; write the data to the CSV file
						FileWrite($file, $line & ',' & $sale_price & ',' & $cost_price & ',' & $profit & @CRLF)
						$already_processed = $already_processed & $line & "|"
					EndIf
					
					$i = $i +13
				EndIf
			EndIf
		EndIF
	Next

	FileClose($file)
	MsgBox (4096, 'Done!', "Done exporting SlyProfits data to a CSV file (open with Excel)")
EndIf