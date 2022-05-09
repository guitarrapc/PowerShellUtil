# ref: https://tech.guitarrapc.com/entry/2013/02/05/000226

#notes
$whole = 800 #全音符
$half = $whole / 2 #2分音符
$fter = $whole / 4 #4分音符
$qver = $whole / 8 #8分音符

$haft = $half + $fter #付点付2分音符
$ftqv = $fter + $qver #付点付4分音符

#rest
$fterrest = {sleep -m $fter} #4分休符
$qverrest = {sleep -m $qver} #8分休符

#keys
$do = 262
$dos = 277
$re = 294
$res = 311
$mi = 330
$fa = 349
$fas = 370
$so = 392
$sos = 415
$la = 440
$sif = 466
$si = 494
$doO = 523
$doOs = 554
$reO = 587

filter Get-Beep {

	param(
	[Parameter(ValueFromPipeline=$true)]
	    [int[]]$keyNote
	)

	[console]::Beep($keyNote[0],$keyNote[1])
}


function doremi-song {

    process{
		1..2 | %{
			(($do,$ftqv),($re,$qver),($mi,$ftqv),($do,$qver),($mi,$fter),($do,$fter),($mi,$half)) | Get-Beep
			(($re,$ftqv),($mi,$qver),($fa,$qver),($fa,$qver),($mi,$qver),($re,$qver),($fa,$whole)) | Get-Beep
			. $fterrest
			(($mi,$ftqv),($fa,$qver),($so,$ftqv),($mi,$qver),($so,$fter),($mi,$fter),($so,$half)) | Get-Beep
			(($fa,$ftqv),($so,$qver),($la,$qver),($la,$qver),($so,$qver),($fa,$qver),($la,$whole)) | Get-Beep
			. $fterrest
			(($so,$ftqv),($do,$qver),($re,$qver),($mi,$qver),($fa,$qver),($so,$qver),($la,$whole)) | Get-Beep
			. $fterrest
			(($la,$ftqv),($re,$qver),($mi,$qver),($fas,$qver),($so,$qver),($la,$qver),($si,$whole)) | Get-Beep
			. $fterrest
			(($si,$ftqv),($mi,$qver),($fas,$qver),($sos,$qver),($la,$qver),($si,$qver),($doO,$whole)) | Get-Beep
			(($si,$qver),($sif,$qver),($la,$fter),($fa,$fter),($si,$fter),($so,$fter),($doO,$haft)) | Get-Beep
			. $fterrest
		}

		. $fterrest
		(($do,$fter),($re,$fter),($mi,$fter)) | Get-Beep
		(($fa,$fter),($so,$fter),($la,$fter),($si,$fter),($doO,$fter),($doO,$fter),($si,$fter),($la,$fter)) | Get-Beep
		(($so,$fter),($fa,$fter),($mi,$fter),($re,$fter),($do,$fter),($mi,$fter),($mi,$half)) | Get-Beep
		(($mi,$fter),($so,$fter),($so,$half),($re,$fter),($fa,$fter),($fa,$half)) | Get-Beep
		(($la,$fter),($si,$fter),($si,$half),($do,$qver),($mi,$qver),($mi,$fter)) | Get-Beep
		. $qverrest
		(($mi,$qver),($so,$qver),($so,$fter)) | Get-Beep
		. $qverrest
		(($re,$qver),($fa,$qver),($fa,$fter)) | Get-Beep
		. $qverrest
		(($la,$qver),($si,$qver),($si,$fter)) | Get-Beep
		. $qverrest
		(($so,$half),($do,$half)) | Get-Beep
		(($la,$half),($fa,$half),($mi,$half),($do,$half),($re,$whole)) | Get-Beep
		(($so,$half),($do,$half),($la,$half),($si,$half),($doO,$half),($reO,$half),($doO,$whole)) | Get-Beep
    }
}

doremi-song
