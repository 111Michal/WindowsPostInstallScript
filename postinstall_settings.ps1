### WITAJ W SKRYPCIE ###
########################

### NA START FUNKCJE POMOCNICZE ###
###################################
#Requires -RunAsAdministrator


function SprawdzIstnienieKlucza {
param (
    [parameter(Mandatory=$true)]
    [string]$registryPath
)

if (Test-Path -Path $registryPath) {
    # Klucz istnieje
    return $true
}
else {
    # Klucz nie istnieje
    return $false
}

}

function SprawdzIstnienieWartosci {
param (
    [parameter(Mandatory=$true)]
    [string]$registryPath,
    [parameter(Mandatory=$true)]
    [string]$valueName
)

$Value = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue
if ($value) {
    # Wartosc istnieje
    return $true
}
else {
    # Value does not exist
    return $false
}

}

function SprawdzWartosc {
param (
    [parameter(Mandatory=$true)]
    [string]$registryPath,
    [parameter(Mandatory=$true)]
    [string]$valueName,
    [parameter(Mandatory=$true)]
    $valueData
)

$Value = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

$comparisonResult = Compare-Object -ReferenceObject $Value.$ValueName -DifferenceObject $valueData -SyncWindow 0

if ($comparisonResult.Count -eq 0) {
        return $true
    } else {
        return $false
    }

}

function EdytujWartosc {
param (
    [parameter(Mandatory=$true)]
    [string]$registryPath,
    [parameter(Mandatory=$true)]
    [string]$valueName,
    [parameter(Mandatory=$true)]
    $valueData
)

 try {
        Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData   
        return $true
    } catch {
        return $false
    }

}

function UtworzWartosc {
param (
    [parameter(Mandatory=$true)]
    [string]$registryPath,
    [parameter(Mandatory=$true)]
    [string]$valueName,
    [parameter(Mandatory=$true)]
    $valueData,
    [parameter(Mandatory=$true)]
    $valueType
)

try {
        New-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -PropertyType $valueType -Force
        return $true
    } catch {
        return $false
    }
}

function PrzeprowadzEdycje {
param (
    [parameter(Mandatory=$true)]
    [string]$registryPath,
    [parameter(Mandatory=$true)]
    [string]$valueName,
    [parameter(Mandatory=$true)]
    $valueData,
    [parameter(Mandatory=$false)]
    $valueType
)

$checkKlucz = SprawdzIstnienieKlucza -registryPath $registryPath

if ($checkKlucz) {
    # klucz jest
    Write-host -f Green "Klucz istnieje"
    # sprawdzenie istnienia wartosci
    $checkWartosc = SprawdzIstnienieWartosci -registryPath $registryPath -valueName $valueName
    if($checkWartosc) {
        Write-host -f Green "Wartosc istnieje"
        # sprawdzenie wartosci
        $checkWartoscDane = SprawdzWartosc -registryPath $registryPath -valueName $valueName -valueData $valueData
        if($checkWartoscDane) {
            # nic nie rob
            Write-Host -f Green "Wartosc ok"
            return
        } else {
            Write-Host -f Yellow "Wartosc do zmiany"
            # edycja wartosci
            $checkEdycja = EdytujWartosc -registryPath $registryPath -valueName $valueName -valueData $valueData
            # sprawdz czy udalo sie edytowac
            if($checkEdycja) {
                Write-Host -f Green "Wartosc zmieniona"
                return
            } else {
                # no cos nie dziala XD
                Write-host -f Red "Wartosc sie nie edytowala!!!"
                return
            }
        }

    } else {
        Write-host -f Yellow "Wartosc nie istnieje!!!"
        $confirmation = Read-Host "Czy chcesz dodac? [y/n]"
        if ($confirmation -eq 'y') {
           $done = UtworzWartosc -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType
            if ($done) {
                Write-Host -f Green "Wartosc utworzona poprawnie"
                } else {
                Write-Host -f Red "Cos poszlo nie tak"
                }
                return
        } else {return}
    }
} else {
    Write-host -f Red "Klucz nie istnieje!"
    return
}

}

######################
# ANIMACJE, WYDAJNOSC#
######################

# wlaczenie opcji miniatur zamiast ikon
function MiniaturyZamiastIkon {
$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$valueName = 'IconsOnly'
$valueData = '0'

Write-Host -f Gray "Miniatury zamiast ikon"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# wybranie opcji niestandardowe -> konieczne do jakichkolwiek zmian
function KastomoweEfekty {
$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
$valueName = 'VisualFXSetting'
$valueData = '3'
$valueType = 'DWORD'

Write-Host -f Gray "Opcja niestandardowe ustawienia wydajnosci (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType
}

# wlacza wygladzenie krawedzi czcionek
function WygladzKrawedzieCzcionek {
$registryPath = 'HKCU:\Control Panel\Desktop'
$valueName = 'FontSmoothing'
$valueData = '2'

Write-Host -f Gray "Wygladz krawedzie czcionek"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# ustawia kilka atrybutow, nie pamietam jakich xddd
function Maska {
$registryPath = 'HKCU:\Control Panel\Desktop'
$valueName = 'UserPreferencesMask'
$valueData = [byte[]]@(0x90, 0x12, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00)

Write-Host -f Gray "Zmiana jakis atrybutow"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# wlacza podglad -> cokolwiek to znaczy
function Podglad {
$registryPath = 'HKCU:\Software\Microsoft\Windows\DWM'
$valueName = 'EnableAeroPeek'
$valueData = '1'

Write-Host -f Gray "Wlacz podglad"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# wlacza pokaz przezroczysty prostokat zaznaczenia
function PrzezroczystyProstokat {
$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$valueName = 'ListviewAlphaSelect'
$valueData = '1'

Write-Host -f Gray "Przezroczysty prostokat zaznaczenia"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# wlacza pokaz zawartosc okna podczas przeciagania
function ZawartoscOknaPodczasPrzeciagania {
$registryPath = 'HKCU:\Control Panel\Desktop'
$valueName = 'DragFullWindows'
$valueData = '1'

Write-Host -f Gray "Pokaz zawartosc okna podczas przeciagania"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# wylacza animacje przy minimalizacji i maksymalizacji
function AnimacjaMaksMin {
$registryPath = 'HKCU:\Control Panel\Desktop\WindowMetrics'
$valueName = 'MinAnimate'
$valueData = '0'

Write-Host -f Gray "Animacja przy min i max okna"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# wylacza zapisanie podgladu miniatur paska zadan
function PodgladMiniaturPaska {
$registryPath = 'HKCU:\Software\Microsoft\Windows\DWM'
$valueName = 'AlwaysHibernateThumbnails'
$valueData = '0'

Write-Host -f Gray "Zapisz podglad miniatur paska zadan"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# wylacza uzyj cieni dla etykiet ikon pulpitu
function CienieEtykietIkonPulpitu {
$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$valueName = 'ListviewShadow'
$valueData = '0'

Write-Host -f Gray "Uzycie cieni dla etykiet ikon pulpitu"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# wylacza wylacza animacje paska zadan
function AnimacjaPaska {
$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$valueName = 'TaskbarAnimations'
$valueData = '0'

Write-Host -f Gray "Animacje paska zadan"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# skraca czas w jakim pokaze sie menu (domyslnie 400 ms)
function czasMenu {
$registryPath = 'HKCU:\Control Panel\Desktop'
$valueName = 'MenuShowDelay'
$valueData = '5'
$valueType = 'SZ'

Write-Host -f Gray "Czas pojawienie sie menu"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType
}

# funkcja do wywolania funkcji dotyczacych wydajnosci, animacji
function wydajnosc {
KastomoweEfekty
MiniaturyZamiastIkon
WygladzKrawedzieCzcionek
Maska
Podglad
PrzezroczystyProstokat
ZawartoscOknaPodczasPrzeciagania
AnimacjaPaska
PodgladMiniaturPaska
CienieEtykietIkonPulpitu
AnimacjaMaksMin
czasMenu
}

##### USTAWIENIA EKSPLORATORA PLIKOW #####
##########################################

# wlacza widocznosc rozszerzen
function WlaczRozszerzeniePlikow {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$valueName = 'HideFileExt'
$valueData = '0'

Write-Host -f Gray "Widocznosc rozszerzen"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# eksplorator wlacza sie w ten komputer
function StartTenKomputer {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$valueName = 'LaunchTo'
$valueData = '1'
$valueType = 'DWORD'

Write-Host -f Gray "Gdzie ma odpalic sie ekskplorator (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType
}

# wylacza pokaz czesto uzywane foldery na pasku szybki dostep
function CzesteFoldery {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
$valueName = 'ShowFrequent'
$valueData = '0'
$valueType = 'DWORD'

Write-Host -f Gray "Pokaz czesto uzywane foldery na pasku szybki dostep (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType
}

# wylacza pokaz niedawno uzywane pliki na pasku szybki dostep
function NiedawnePliki {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
$valueName = 'ShowRecent'
$valueData = '0'
$valueType = 'DWORD'

Write-Host -f Gray "Pokaz niedawno uzywane pliki na pasku szybki dostep (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType
}

# funkcja do odpalenia ustawien eksploratora

function eksplorator{
NiedawnePliki
CzesteFoldery
StartTenKomputer
WlaczRozszerzeniePlikow
}

##### USTAWIENIA MYSZY #####
############################

# szybkosc kursora na 10
function SzybkoscKursora {
$registryPath = 'HKCU:\Control Panel\Mouse'
$valueName = 'MouseSensitivity'
$valueData = '7'

Write-Host -f Gray "Czulosc kursora"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# szybkosc myszy na 0 -> nie wiem czemu tak
function SzybkoscMyszy {
$registryPath = 'HKCU:\Control Panel\Mouse'
$valueName = 'MouseSpeed'
$valueData = '0'

Write-Host -f Gray "Szybkosc myszy"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# MouseThreshold1 na 0 -> nie wiem czemu tak
function MyszThreshold1 {
$registryPath = 'HKCU:\Control Panel\Mouse'
$valueName = 'MouseThreshold1'
$valueData = '0'

Write-Host -f Gray "MouseThreshold1"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# MouseThreshold2 na 0 -> nie wiem czemu tak
function MyszThreshold2 {
$registryPath = 'HKCU:\Control Panel\Mouse'
$valueName = 'MouseThreshold2'
$valueData = '0'

Write-Host -f Gray "MouseThreshold2"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# funkcja do ustawien myszy

function mysz {
SzybkoscKursora
MyszThreshold2
MyszThreshold1
SzybkoscMyszy
}

##### USTAWIENIA PRYWATNOSCI #####
##################################

# wylaczenie dostepu do lokalizacji (cale urzadzenie)
function lokalizacja {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do lokalizacji"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie aktywacji glosowej dla aplikacji
function aktywacjaGlosowa {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps'
$valueName = 'AgentActivationEnabled'
$valueData = '0'
$valueType = 'DWORD'

Write-Host -f Gray "Dostep do aktywacji glosowej przez aplikacje (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# wylaczenie dostepu do powiadomien
function dostepPowiadomienia {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do powiadomien"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do informacji o koncie
function dostepInfoKonto {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do informacji o koncie"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do kontaktow
function dostepKontakty {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do informacji o kontaktach"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do kalendarza
function dostepKalendarz {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do informacji o kalendarzu"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do polaczen telefonicznych
function dostepPolaczeniaTel {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do informacji o polaczeniach telefonicznych"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do historii polaczen
function dostepHistoriaPolaczen {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do informacji o historii polaczen"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do emaila
function dostepEmail {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do informacji o email'u"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do zadan
function dostepZadania {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do informacji o zadaniach"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do obslugi wiadomosci
function dostepWiadomosci {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do informacji o obsludze wiadomosci"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do urzadzen radiowych
function dostepRadio {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do informacji o urzadzeniach radiowych"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do polaczenia bt bez parowania
function dostepBTsynchro {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do polaczenia bt bez parowania"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do informacji diagnostycznych
function dostepDaneDiagnostyczne {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do informacji diagnostycznych"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do dokumentow
function dostepDokumenty {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do dokumentow"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do obrazow
function dostepObrazy {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do obrazow"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do wideo
function dostepWideo {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do wideo"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do systemu plikow
function dostepSystemPlikow {
$registryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess'
$valueName = 'Value'
$valueData = 'Deny'

Write-Host -f Gray "Dostep do systemu plikow"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData

}

# wylaczenie dostepu do historii dzialan na urzadzenia
# NOT WORKING !!!
function dostepHistoriaDzialan {
$registryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
$valueName = 'PublishUserActivities'
$valueData = '0'
$valueType = 'DWORD'

Write-Host -f Gray "Dostep do historii dzialan (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

function prywatnosc {
    lokalizacja
    aktywacjaGlosowa
    dostepPowiadomienia
    dostepInfoKonto
    dostepKontakty
    dostepKalendarz
    dostepPolaczeniaTel
    dostepHistoriaPolaczen
    dostepEmail
    dostepZadania
    dostepWiadomosci
    dostepRadio
    dostepBTsynchro
    dostepDaneDiagnostyczne
    dostepDokumenty
    dostepObrazy
    dostepWideo
    dostepSystemPlikow
    #dostepHistoriaDzialan
}

##### USTAWIENIA WYSZUKIWANIA #####
###################################

# wylacz safe search
function safeSearch {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings'
$valueName = 'SafeSearchMode'
$valueData = '0'

Write-Host -f Gray "Ustawienie safe search"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData
}

# wylacz wyszukiwanie ms cloud
function msCloudSearch {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings'
$valueName = 'IsMSACloudSearchEnabled'
$valueData = '0'
$valueType = 'DWORD'

Write-Host -f Gray "Windows Search konto MS (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType
}

# wylacz wyszukiwanie szkolna cloud
function szkolaCloudSearch {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings'
$valueName = 'IsAADCloudSearchEnabled'
$valueData = '0'
$valueType = 'DWORD'

Write-Host -f Gray "Windows Search konta szkole, sluzbowe (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType
}

# wylacz historie wyszukiwania
function historiaSearch {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings'
$valueName = 'IsDeviceSearchHistoryEnabled'
$valueData = '0'
$valueType = 'DWORD'

Write-Host -f Gray "Historia wyszukiwania (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType
}

function wyszukiwanie {
safeSearch
msCloudSearch
szkolaCloudSearch
historiaSearch
}

##### USTAWIENIA PASKA ZADAN ######
###################################

# wylaczenie wiadomosci i zainteresowan
function wiadomosciPasekZadan {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds'
$valueName = 'ShellFeedsTaskbarViewMode'
$valueData = '2'
$valueType = 'DWORD'

Write-Host -f Gray "Wiadomosci, zainteresowania na pasku zadan"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# tylko ikona wyszukiwania
function poleWyszukiwania {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'
$valueName = 'SearchboxTaskbarMode'
$valueData = '1'
$valueType = 'DWORD'


Write-Host -f Gray "Typ pola wyszukiwania (Utworzenie wartosci moze byc konieczne)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# wylacz przycisk widoku zadan
function przyciskWidokZadan {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$valueName = 'ShowTaskViewButton'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Przycisk widoku zadan (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

function pasekZadan {
wiadomosciPasekZadan
poleWyszukiwania
przyciskWidokZadan
}

##### USTAWIENIA TAPETY, MENU ITP ######
########################################

function ustawTapete {
$registryPath = 'HKCU:\Control Panel\Desktop'
$valueName = 'WallPaper'
$valueData = 'c:\windows\web\wallpaper\theme1\img13.jpg'
$valueType = 'SZ'


Write-Host -f Gray "Ustawienie tapety"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# wylaczenie koloru wiodacego menu start, pasek zadan, centrum akcji
function kolorWiodacyMenu {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$valueName = 'ColorPrevalence'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Ustawienie wlacz kolor wiodacy - menu start, pasek zadan, centrum akcji"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# wylaczenie koloru wiodacego paski tytulu i obramowania okien
function kolorWiodacyTytul {
$registryPath = 'HKCU:\Software\Microsoft\Windows\DWM'
$valueName = 'ColorPrevalence'
$valueData = '1'
$valueType = 'DWORD'


Write-Host -f Gray "Ustawienie wlacz kolor wiodacy - paski tytulu i obramowania okien"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# domyslny ciemny motyw aplikacji
function ciemnyMotyw {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$valueName = 'AppsUseLightTheme'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Ustawienie motywu aplikacji (jasny/ciemny)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# domyslny ciemny motyw systemu
function ciemnyMotywSystem {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$valueName = 'SystemUsesLightTheme'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Ustawienie motywu systemu (jasny/ciemny)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# wlaczenie efektow przezroczystosci
function efektyPrzezroczystosci {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'
$valueName = 'EnableTransparency'
$valueData = '1'
$valueType = 'DWORD'


Write-Host -f Gray "Ustawienie efektow przezroczystosci"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

function wyswietlacz {
efektyPrzezroczystosci
ciemnyMotyw
ciemnyMotywSystem
kolorWiodacyTytul
kolorWiodacyMenu
ustawTapete
}

##### POWIADOMIENIA ######
##########################

# wylaczenie powiadomien na ekranie blokady
function powiadomieniaEkranBlokady {
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications'
$valueName = 'LockScreenToastEnabled'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Powiadomienia na ekranie blokady (Moze byc konieczne utworzenie nowej wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# wylaczenie powiadomien po aktualizacji windowsa
function powiadomieniaPoAktualizacji{
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
$valueName = 'SubscribedContent-310093Enabled'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Powiadomienia po aktualizacji windowsa (Windows zapraszamy) (Moze byc konieczne utworzenie nowej wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

function powiadomienia {
powiadomieniaPoAktualizacji
powiadomieniaEkranBlokady
}

##### GAME BAR ######
#####################

# wylaczenie game bar opcja 1
function gameBar_1{
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'
$valueName = 'AppCaptureEnabled'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Wylaczenie game bar (opcja 1) (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# wylaczenie game bar opcja 2
function gameBar_2{
$registryPath = 'HKCU:\System\GameConfigStore'
$valueName = 'GameDVR_Enabled'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Wylaczenie game bar (opcja 2)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

function gameBar {
gameBar_1
gameBar_2
}

##### PISOWNIA ######
#####################

# wylaczenie automatycznego poprawiania bledow pisowni
function autoBledyPisownia{
$registryPath = 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7'
$valueName = 'EnableAutocorrection'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Wylaczenie automatycznego poprawiania bledow pisowni (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# wylaczenie wyrozniania poprawiania bledow pisowni
function autoWyroznianieBledyPisownia{
$registryPath = 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7'
$valueName = 'EnableSpellchecking'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Wylaczenie automatycznego wyrozniania bledow pisowni (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# pokazywanie sugestii tekstowych
function sugestieTekstowe{
$registryPath = 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7'
$valueName = 'EnableTextPrediction'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Wylaczenie pokazywania sugestii tekstowych (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# autospacja
function autoSpacja{
$registryPath = 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7'
$valueName = 'EnablePredictionSpaceInsertion'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Wylaczenie autospacji (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

# kropka pod dwukrotnej spacji
function kropkaDouble{
$registryPath = 'HKCU:\SOFTWARE\Microsoft\TabletTip\1.7'
$valueName = 'EnableDoubleTapSpace'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Wylaczenie kropki po dwukrotnym wcisnieciu spacji (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

function pisownia {
autoSpacja
kropkaDouble
autoBledyPisownia
sugestieTekstowe
autoWyroznianieBledyPisownia
}

# wylaczenie autoodtwarzania
function autoOdtwarzanie{
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers'
$valueName = 'DisableAutoplay'
$valueData = '1'
$valueType = 'DWORD'


Write-Host -f Gray "Wylaczenie autoodtwarzania (Moze byc konieczne utworzenie wartosci)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}

#### OPCJE DODATKOWE ####
#########################

# wylaczenie wyszukiwania bing w menu start
function bingMenuStart{
$registryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'
$valueName = 'BingSearchEnabled'
$valueData = '0'
$valueType = 'DWORD'


Write-Host -f Gray "Wyszukiwanie bing w menu start (Konieczne dodanie klucza)"
PrzeprowadzEdycje -registryPath $registryPath -valueName $valueName -valueData $valueData -valueType $valueType

}


Write-Host "Witaj w skrypcie postinstalacyjnym!"
# potwierdzenie startu
$confirmation = Read-Host "Czy chcesz rozpoczac?"
if ($confirmation -eq 'y') {
    # wywolanie funkcji
    #wydajnosc
    #eksplorator
    #mysz
    #prywatnosc
    #wyszukiwanie
    #pasekZadan
    #wyswietlacz
    #powiadomienia
    #gameBar
    #pisownia
    #autoOdtwarzanie
    bingMenuStart
    czasMenu

    # Potwierdzenie restartu
    $confirmation = Read-Host "Czy chcesz zrestartowaæ komputer? - konieczne dla niektórych zmian (Tak/Nie)"

    if ($confirmation -eq "Tak" -or $confirmation -eq "t") {
        # Uruchomienie ponownego uruchomienia komputera
        Shutdown.exe /r /t 0
    } else {
        Write-Host "Nie zrestartowano komputera."
        return "Koniec"
    }
} else {
    return "Koniec"
}




#C:\Users\111\Desktop