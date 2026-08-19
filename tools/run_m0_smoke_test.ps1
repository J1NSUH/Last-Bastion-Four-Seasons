param(
	[string]$GodotPath = "",
	[ValidateSet("m0", "scene", "scene_startup", "scene_map", "scene_alpha", "scene_combat_hud", "scene_reward_ui", "scene_shop_artifact", "scene_shop_service", "scene_wave_tempo", "scene_tactical_signals", "scene_planned_collapse", "scene_full", "autoplay", "autoplay_boss", "alpha_coverage")]
	[string]$Suite = "m0",
	[switch]$VerboseSearch,
	[switch]$ShowGodotOutput,
	[int]$TimeoutSeconds = 120
)

$ErrorActionPreference = "Stop"

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$TestScripts = @{
	m0 = "res://scripts/m0/M0SmokeTest.gd"
	scene = "res://scripts/m0/M0SceneStartupSmokeTest.gd"
	scene_startup = "res://scripts/m0/M0SceneStartupSmokeTest.gd"
	scene_map = "res://scripts/m0/M0SceneMapBadgeSmokeTest.gd"
	scene_alpha = "res://scripts/m0/M0SceneAlphaSmokeTest.gd"
	scene_combat_hud = "res://scripts/m0/M0SceneCombatHudSmokeTest.gd"
	scene_reward_ui = "res://scripts/m0/M0SceneRewardSmokeTest.gd"
	scene_shop_artifact = "res://scripts/m0/M0SceneShopArtifactSmokeTest.gd"
	scene_shop_service = "res://scripts/m0/M0SceneShopServiceSmokeTest.gd"
	scene_wave_tempo = "res://scripts/m0/M0SceneWaveTempoSmokeTest.gd"
	scene_tactical_signals = "res://scripts/m0/M0SceneTacticalSignalsSmokeTest.gd"
	scene_planned_collapse = "res://scripts/m0/M0ScenePlannedCollapseSmokeTest.gd"
	scene_full = "res://scripts/m0/M0SceneSmokeTest.gd"
	autoplay = "res://scripts/m0/M0AutoplaySmokeTest.gd"
	autoplay_boss = "res://scripts/m0/M0AutoplayBossSmokeTest.gd"
	alpha_coverage = "res://scripts/m0/M0AlphaCoverageSmokeTest.gd"
}
$TestUserRoot = Join-Path $ProjectRoot ".godot-test-user"
$TestLogDir = Join-Path $TestUserRoot "logs"

function Add-Candidate {
	param(
		[System.Collections.ArrayList]$Candidates,
		[string]$Path,
		[string]$Source
	)

	if ([string]::IsNullOrWhiteSpace($Path)) {
		return
	}

	$resolved = $null
	if (Test-Path -LiteralPath $Path -PathType Leaf) {
		$resolved = (Resolve-Path -LiteralPath $Path).Path
	} else {
		$command = Get-Command $Path -ErrorAction SilentlyContinue
		if ($null -ne $command) {
			$resolved = $command.Source
		}
	}

	if ([string]::IsNullOrWhiteSpace($resolved)) {
		return
	}

	foreach ($candidate in $Candidates) {
		if ($candidate.Path -eq $resolved) {
			return
		}
	}

	[void]$Candidates.Add([pscustomobject]@{
		Path = $resolved
		Source = $Source
	})
}

function Add-Directory-Candidates {
	param(
		[System.Collections.ArrayList]$Candidates,
		[string]$Directory,
		[string]$Source
	)

	if ([string]::IsNullOrWhiteSpace($Directory) -or -not (Test-Path -LiteralPath $Directory -PathType Container)) {
		return
	}

	$patterns = @("Godot_v4*_console.exe", "Godot*_console.exe", "godot4*_console.exe", "godot*_console.exe", "Godot_v4*.exe", "Godot*.exe", "godot4*.exe", "godot*.exe")
	foreach ($pattern in $patterns) {
		$matches = Get-ChildItem -LiteralPath $Directory -Filter $pattern -File -ErrorAction SilentlyContinue
		foreach ($match in $matches) {
			Add-Candidate -Candidates $Candidates -Path $match.FullName -Source $Source
		}
	}
}


function Add-ChildDirectory-Candidates {
	param(
		[System.Collections.ArrayList]$Candidates,
		[string]$Directory,
		[string]$Source
	)

	if ([string]::IsNullOrWhiteSpace($Directory) -or -not (Test-Path -LiteralPath $Directory -PathType Container)) {
		return
	}

	$patterns = @("Godot*", "godot*")
	foreach ($pattern in $patterns) {
		$matches = Get-ChildItem -LiteralPath $Directory -Filter $pattern -Directory -ErrorAction SilentlyContinue
		foreach ($match in $matches) {
			Add-Directory-Candidates -Candidates $Candidates -Directory $match.FullName -Source $Source
		}
	}
}


function Join-IfSet {
	param(
		[string]$Base,
		[string]$Child
	)

	if ([string]::IsNullOrWhiteSpace($Base)) {
		return ""
	}

	return Join-Path $Base $Child
}

function Quote-ProcessArgument {
	param([string]$Argument)

	if ($null -eq $Argument) {
		return '""'
	}

	if ($Argument -notmatch '[\s"]') {
		return $Argument
	}

	return '"' + ($Argument -replace '"', '\"') + '"'
}

function Join-ProcessArguments {
	param([string[]]$Arguments)

	return ($Arguments | ForEach-Object { Quote-ProcessArgument -Argument $_ }) -join " "
}

function Find-Godot {
	param([string]$ExplicitPath)

	$candidates = [System.Collections.ArrayList]::new()

	Add-Candidate -Candidates $candidates -Path $ExplicitPath -Source "argument -GodotPath"
	Add-Candidate -Candidates $candidates -Path $env:GODOT4_BIN -Source "environment GODOT4_BIN"
	Add-Candidate -Candidates $candidates -Path $env:GODOT_BIN -Source "environment GODOT_BIN"
	Add-Candidate -Candidates $candidates -Path "godot4" -Source "PATH godot4"
	Add-Candidate -Candidates $candidates -Path "godot" -Source "PATH godot"

	Add-Directory-Candidates -Candidates $candidates -Directory $ProjectRoot -Source "repo root"
	Add-ChildDirectory-Candidates -Candidates $candidates -Directory $ProjectRoot -Source "repo root Godot folder"
	Add-Directory-Candidates -Candidates $candidates -Directory (Join-Path $ProjectRoot "tools\godot") -Source "repo tools\godot"
	Add-ChildDirectory-Candidates -Candidates $candidates -Directory (Join-Path $ProjectRoot "tools") -Source "repo tools Godot folder"
	Add-Directory-Candidates -Candidates $candidates -Directory (Join-IfSet $env:LOCALAPPDATA "Programs\Godot") -Source "LocalAppData Godot"
	Add-Directory-Candidates -Candidates $candidates -Directory (Join-IfSet $env:ProgramFiles "Godot") -Source "Program Files Godot"
	Add-Directory-Candidates -Candidates $candidates -Directory (Join-IfSet ${env:ProgramFiles(x86)} "Godot") -Source "Program Files x86 Godot"
	Add-Directory-Candidates -Candidates $candidates -Directory (Join-IfSet $env:ProgramFiles "Steam\steamapps\common\Godot Engine") -Source "Steam Godot"
	Add-Directory-Candidates -Candidates $candidates -Directory (Join-IfSet ${env:ProgramFiles(x86)} "Steam\steamapps\common\Godot Engine") -Source "Steam Godot x86"
	Add-Directory-Candidates -Candidates $candidates -Directory (Join-IfSet $env:USERPROFILE "Desktop") -Source "Desktop"
	Add-Directory-Candidates -Candidates $candidates -Directory (Join-IfSet $env:USERPROFILE "Downloads") -Source "Downloads"

	if ($VerboseSearch) {
		if ($candidates.Count -eq 0) {
			Write-Host "[Godot] no executable candidates found"
		} else {
			foreach ($candidate in $candidates) {
				Write-Host "[Godot] candidate: $($candidate.Path) ($($candidate.Source))"
			}
		}
	}

	foreach ($candidate in $candidates) {
		$versionOutput = & $candidate.Path --version 2>&1
		if ($LASTEXITCODE -ne 0) {
			if ($VerboseSearch) {
				Write-Host "[Godot] rejected: $($candidate.Path)"
			}
			continue
		}

		$versionText = ($versionOutput | Select-Object -First 1).ToString()
		if ($versionText -notmatch "^4\.") {
			Write-Warning "Found Godot but version is not 4.x: $versionText"
		}

		return [pscustomobject]@{
			Path = $candidate.Path
			Source = $candidate.Source
			Version = $versionText
		}
	}

	return $null
}

$Godot = Find-Godot -ExplicitPath $GodotPath
if ($null -eq $Godot) {
	Write-Host @"
Godot executable was not found.

Use one of these:
  .\tools\run_m0_smoke_test.ps1 -GodotPath "C:\Path\To\Godot_v4.x-stable_win64.exe"
  `$env:GODOT4_BIN = "C:\Path\To\Godot_v4.x-stable_win64.exe"
  Put Godot_v4.x-stable_win64.exe inside .\tools\godot\
"@
	exit 2
}

$ScriptPath = $TestScripts[$Suite]
$LogPath = Join-Path $TestLogDir "$Suite.log"
Write-Host "[Godot] using $($Godot.Path)"
Write-Host "[Godot] source $($Godot.Source)"
Write-Host "[Godot] version $($Godot.Version)"
Write-Host "[Test] $ScriptPath"
Write-Host "[Log] $LogPath"
Write-Host "[Timeout] ${TimeoutSeconds}s"

New-Item -ItemType Directory -Path $TestLogDir -Force | Out-Null

Push-Location $ProjectRoot
$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
try {
	$env:APPDATA = $TestUserRoot
	$env:LOCALAPPDATA = $TestUserRoot
	$godotArgs = @("--headless", "--log-file", $LogPath, "--path", $ProjectRoot, "--script", $ScriptPath)
	if (-not $ShowGodotOutput) {
		$godotArgs = @("--quiet") + $godotArgs
	}

	$processInfo = [System.Diagnostics.ProcessStartInfo]::new()
	$processInfo.FileName = $Godot.Path
	$processInfo.UseShellExecute = $false
	$processInfo.CreateNoWindow = $true
	$processInfo.Arguments = Join-ProcessArguments -Arguments $godotArgs

	$process = [System.Diagnostics.Process]::Start($processInfo)
	if ($null -eq $process) {
		throw "Failed to start Godot."
	}

	if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
		Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
		$process.WaitForExit()
		$exitCode = 124
		Write-Host "[FAIL] Godot smoke test timed out after ${TimeoutSeconds}s"
	} else {
		$exitCode = $process.ExitCode
	}
} finally {
	$env:APPDATA = $oldAppData
	$env:LOCALAPPDATA = $oldLocalAppData
	Pop-Location
}

if ($exitCode -eq 0) {
	Write-Host "[PASS] Godot smoke test completed"
} else {
	Write-Host "[FAIL] Godot smoke test failed with exit code $exitCode"
}

exit $exitCode
