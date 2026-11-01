# Baixa capturas de tela oficiais da Steam de jogos de referência (pixel art, metroidvania, HUD).
# Uso (na pasta F:\GAME):
#   powershell -ExecutionPolicy Bypass -File pipeline\baixar-referencias.ps1
#   powershell -ExecutionPolicy Bypass -File pipeline\baixar-referencias.ps1 -PorJogo 10
# Resultado: referencias\imagens\<jogo>\01.jpg ... e referencias\imagens\INDICE.md
# As imagens são material de estudo interno: não vão para o git (ver .gitignore) e não entram no jogo.

param(
    [int]$PorJogo = 6,
    [string]$Destino = (Join-Path $PSScriptRoot "..\referencias\imagens")
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# nome exato como aparece na Steam | categoria
$jogos = @(
    # Metroidvanias em pixel art
    @("Blasphemous", "metroidvania"),
    @("Blasphemous 2", "metroidvania"),
    @("Dead Cells", "metroidvania"),
    @("Axiom Verge", "metroidvania"),
    @("Axiom Verge 2", "metroidvania"),
    @("Momodora: Reverie Under the Moonlight", "metroidvania"),
    @("Momodora: Moonlit Farewell", "metroidvania"),
    @("Timespinner", "metroidvania"),
    @("Chasm", "metroidvania"),
    @("La-Mulana 2", "metroidvania"),
    @("Iconoclasts", "metroidvania"),
    @("Owlboy", "metroidvania"),
    @("Record of Lodoss War: Deedlit in Wonder Labyrinth", "metroidvania"),
    @("Elderand", "metroidvania"),
    @("Souldiers", "metroidvania"),
    @("Gato Roboto", "metroidvania"),
    @("Haiku, the Robot", "metroidvania"),
    @("TEVI", "metroidvania"),
    @("Bloodstained: Curse of the Moon", "metroidvania"),
    @("Cave Story+", "metroidvania"),
    @("The Messenger", "metroidvania"),
    @("Kunai", "metroidvania"),
    @("Alwa's Awakening", "metroidvania"),
    # Brasileiros
    @("Dandara: Trials of Fear Edition", "brasileiro"),
    @("Kaze and the Wild Masks", "brasileiro"),
    # Plataforma de precisão (estilo Jump Quest)
    @("Celeste", "precisao"),
    @("Shovel Knight: Treasure Trove", "precisao"),
    @("Katana ZERO", "precisao"),
    # Chefes em pixel art
    @("Titan Souls", "chefes"),
    # Arte de natureza, luz e atmosfera em pixel art
    @("Hyper Light Drifter", "atmosfera"),
    @("Eastward", "atmosfera"),
    @("Sea of Stars", "atmosfera"),
    @("Rain World", "atmosfera"),
    @("Children of Morta", "atmosfera"),
    @("Moonlighter", "hud"),
    # Vistos na pesquisa do Gabriel (Google, "jogo pixel")
    @("Broforce", "acao"),
    @("METAL SLUG 3", "acao"),
    @("Terraria", "mundo"),
    @("FEZ", "atmosfera"),
    @("Stardew Valley", "atmosfera"),
    @("OCTOPATH TRAVELER", "atmosfera")
)

New-Item -ItemType Directory -Force -Path $Destino | Out-Null
$indice = @("# Índice das referências baixadas", "", "Gerado por pipeline/baixar-referencias.ps1 em $(Get-Date -Format 'dd/MM/yyyy HH:mm'). Confira se cada jogo encontrado é o certo.", "", "| Jogo pedido | Jogo encontrado | Categoria | Pasta | Página |", "|---|---|---|---|---|")

function Limpar-Nome([string]$t) {
    $s = $t.ToLower() -replace "[^a-z0-9]+", "-"
    return $s.Trim("-")
}

foreach ($j in $jogos) {
    $nome = $j[0]; $cat = $j[1]
    try {
        $busca = Invoke-RestMethod -Uri ("https://store.steampowered.com/api/storesearch/?term=" + [uri]::EscapeDataString($nome) + "&cc=us&l=english") -UseBasicParsing
        $item = $busca.items | Where-Object { $_.name -eq $nome } | Select-Object -First 1
        if (-not $item) { $item = $busca.items | Select-Object -First 1 }
        if (-not $item) { Write-Warning "Não encontrado: $nome"; $indice += "| $nome | (não encontrado) | $cat | — | — |"; continue }

        $id = [string]$item.id
        $det = Invoke-RestMethod -Uri "https://store.steampowered.com/api/appdetails?appids=$id&l=english" -UseBasicParsing
        $dados = $det.PSObject.Properties[$id].Value.data
        if (-not $dados) { Write-Warning "Sem dados: $nome ($id)"; continue }

        $pasta = Join-Path $Destino ("$cat-" + (Limpar-Nome $nome))
        New-Item -ItemType Directory -Force -Path $pasta | Out-Null

        if ($dados.header_image) {
            Invoke-WebRequest -Uri $dados.header_image -OutFile (Join-Path $pasta "00-capa.jpg") -UseBasicParsing
        }
        $n = 0
        foreach ($s in ($dados.screenshots | Select-Object -First $PorJogo)) {
            $n++
            $arq = Join-Path $pasta ("{0:D2}.jpg" -f $n)
            if (-not (Test-Path $arq)) { Invoke-WebRequest -Uri $s.path_full -OutFile $arq -UseBasicParsing }
        }
        $rel = Split-Path $pasta -Leaf
        $indice += "| $nome | $($dados.name) | $cat | ``$rel`` ($n imagens) | https://store.steampowered.com/app/$id |"
        Write-Host "OK  $($dados.name)  ->  $rel  ($n imagens)"
        Start-Sleep -Milliseconds 1500   # não sobrecarregar a API da Steam
    }
    catch {
        Write-Warning "Falhou em $nome : $($_.Exception.Message)"
        $indice += "| $nome | (falhou) | $cat | — | — |"
    }
}

$indice | Set-Content -Encoding UTF8 (Join-Path $Destino "INDICE.md")
Write-Host ""
Write-Host "Pronto. Abra referencias\imagens\INDICE.md e confira se cada jogo encontrado é o certo."
