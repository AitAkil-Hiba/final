# Script PowerShell pour configurer l'environnement Flutter
# Installation Java 17, configuration JAVA_HOME, nettoyage des caches

Write-Host "=== Configuration de l'environnement Flutter ===" -ForegroundColor Green

# Vérifier si exécuté en tant qu'administrateur
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Ce script nécessite des privilèges d'administrateur. Veuillez exécuter en tant qu'administrateur." -ForegroundColor Red
    pause
    exit 1
}

# 1. Installation de Java 17
Write-Host "`n1. Installation de Java 17..." -ForegroundColor Yellow

# Vérifier si Java est déjà installé
$javaInstalled = $false
try {
    $javaVersion = java -version 2>&1
    if ($javaVersion -match "version \"17") {
        Write-Host "Java 17 est déjà installé." -ForegroundColor Green
        $javaInstalled = $true
    }
} catch {
    Write-Host "Java n'est pas installé ou n'est pas dans le PATH." -ForegroundColor Yellow
}

if (-not $javaInstalled) {
    Write-Host "Téléchargement de Java 17..." -ForegroundColor Yellow
    
    # Créer un répertoire temporaire pour le téléchargement
    $tempDir = "C:\temp_java"
    if (!(Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force
    }
    
    # URL pour Java 17 (Adoptium/Eclipse Temurin)
    $javaUrl = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.12%2B7/OpenJDK17U-jdk_x64_windows_hotspot_17.0.12_7.msi"
    $javaInstaller = "$tempDir\java17.msi"
    
    try {
        Write-Host "Téléchargement depuis: $javaUrl" -ForegroundColor Cyan
        Invoke-WebRequest -Uri $javaUrl -OutFile $javaInstaller -UseBasicParsing
        
        Write-Host "Installation de Java 17..." -ForegroundColor Cyan
        Start-Process msiexec -ArgumentList "/i `"$javaInstaller`" /quiet /norestart" -Wait
        
        Write-Host "Java 17 installé avec succès." -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors du téléchargement/installation de Java. Installation manuelle requise." -ForegroundColor Red
        Write-Host "Téléchargez Java 17 depuis: https://adoptium.net/temurin/releases/?version=17" -ForegroundColor Yellow
        pause
    } finally {
        # Nettoyer le fichier d'installation
        if (Test-Path $javaInstaller) {
            Remove-Item $javaInstaller -Force
        }
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force
        }
    }
}

# 2. Configuration de JAVA_HOME
Write-Host "`n2. Configuration de JAVA_HOME..." -ForegroundColor Yellow

# Trouver le chemin d'installation de Java 17
$javaPaths = @(
    "C:\Program Files\Eclipse Adoptium\jdk-17.0.12.7-hotspot",
    "C:\Program Files\Java\jdk-17.0.12",
    "C:\Program Files\Java\jdk-17",
    "C:\Program Files\Eclipse Adoptium\jdk-17*"
)

$javaPath = $null
foreach ($path in $javaPaths) {
    if (Test-Path $path) {
        $javaPath = $path
        break
    }
}

if ($javaPath) {
    Write-Host "Java trouvé dans: $javaPath" -ForegroundColor Green
    
    # Configurer JAVA_HOME pour la session actuelle
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "User")
    $env:JAVA_HOME = $javaPath
    
    # Ajouter Java au PATH
    $javaBinPath = "$javaPath\bin"
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$javaBinPath*") {
        $newPath = $currentPath + ";$javaBinPath"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = $env:PATH + ";$javaBinPath"
        Write-Host "JAVA_HOME et PATH mis à jour." -ForegroundColor Green
    }
    
    # Vérifier l'installation
    try {
        $env:JAVA_HOME = $javaPath
        $javaVersion = & "$javaBinPath\java.exe" -version 2>&1
        Write-Host "Java version: $($javaVersion[0])" -ForegroundColor Green
    } catch {
        Write-Host "Erreur lors de la vérification de Java." -ForegroundColor Red
    }
} else {
    Write-Host "Java 17 non trouvé. Vérifiez l'installation manuelle." -ForegroundColor Red
    Write-Host "Chemins vérifiés:" -ForegroundColor Yellow
    $javaPaths | ForEach-Object { Write-Host "  - $_" }
}

# 3. Redirection des dossiers TEMP vers D: si disponible
Write-Host "`n3. Redirection des dossiers TEMP..." -ForegroundColor Yellow

if (Test-Path "D:\") {
    $dDrive = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "D:" }
    if ($dDrive.FreeSpace -gt 5GB) {
        Write-Host "Lecteur D: disponible avec $($dDrive.FreeSpace/1GB) GB libres." -ForegroundColor Green
        
        # Créer les dossiers TEMP sur D:
        $tempPathD = "D:\Temp"
        $userTempD = "D:\Temp\User"
        
        if (!(Test-Path $tempPathD)) {
            New-Item -ItemType Directory -Path $tempPathD -Force
        }
        if (!(Test-Path $userTempD)) {
            New-Item -ItemType Directory -Path $userTempD -Force
        }
        
        # Mettre à jour les variables d'environnement TEMP et TMP
        [Environment]::SetEnvironmentVariable("TEMP", $userTempD, "User")
        [Environment]::SetEnvironmentVariable("TMP", $userTempD, "User")
        $env:TEMP = $userTempD
        $env:TMP = $userTempD
        
        Write-Host "Dossiers TEMP redirigés vers D:\Temp\User" -ForegroundColor Green
    } else {
        Write-Host "Lecteur D: disponible mais pas assez d'espace libre." -ForegroundColor Yellow
    }
} else {
    Write-Host "Lecteur D: non disponible." -ForegroundColor Yellow
}

# 4. Nettoyage des caches Flutter/Gradle/Temp
Write-Host "`n4. Nettoyage des caches..." -ForegroundColor Yellow

# Fonction pour nettoyer un dossier si nécessaire
function Clean-Folder {
    param([string]$Folder, [string]$Description)
    
    if (Test-Path $Folder) {
        try {
            $size = (Get-ChildItem $Folder -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
            Write-Host "Nettoyage de $Description ($([math]::Round($size, 2)) MB)..." -ForegroundColor Cyan
            
            Remove-Item "$Folder\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "$Description nettoyé." -ForegroundColor Green
        } catch {
            Write-Host "Erreur lors du nettoyage de $Description: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "$Description n'existe pas." -ForegroundColor Gray
    }
}

# Nettoyer les dossiers
Clean-Folder "$env:LOCALAPPDATA\Pub\Cache\.tmp" "Cache temporaire Pub"
Clean-Folder "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev" "Cache Pub hosted"
Clean-Folder "$env:USERPROFILE\.gradle\caches" "Cache Gradle"
Clean-Folder "$env:USERPROFILE\.gradle\wrapper\dists" "Distributions Gradle Wrapper"
Clean-Folder "$env:TEMP" "Dossier TEMP système"
Clean-Folder "$env:USERPROFILE\.flutter-dart-cache" "Cache Dart Flutter"

# Nettoyer le cache Flutter
try {
    Write-Host "Nettoyage du cache Flutter..." -ForegroundColor Cyan
    flutter clean
    Write-Host "Flutter clean terminé." -ForegroundColor Green
} catch {
    Write-Host "Erreur lors de flutter clean: $_" -ForegroundColor Red
}

# 5. Installation des dépendances et exécution
Write-Host "`n5. Installation des dépendances et exécution..." -ForegroundColor Yellow

# Changer vers le répertoire du projet
$projectPath = "C:\Users\User\frontend_peeco"
if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Host "Répertoire de projet: $(Get-Location)" -ForegroundColor Cyan
    
    try {
        Write-Host "Exécution de flutter pub get..." -ForegroundColor Cyan
        flutter pub get
        Write-Host "Dépendances installées avec succès." -ForegroundColor Green
        
        Write-Host "`nPrêt à exécuter flutter run..." -ForegroundColor Green
        Write-Host "Appuyez sur Entrée pour exécuter flutter run, ou Ctrl+C pour annuler." -ForegroundColor Yellow
        pause
        
        flutter run
    } catch {
        Write-Host "Erreur lors de l'exécution des commandes Flutter: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Répertoire du projet non trouvé: $projectPath" -ForegroundColor Red
}

Write-Host "`n=== Script terminé ===" -ForegroundColor Green
Write-Host "Redémarrez votre terminal/IDE pour que les modifications d'environnement prennent effet." -ForegroundColor Yellow
pause
