# Integrationskontroll av valresultat(), 2026-09-10

Slutresultat: 16 kontroller av fil/nivå passerade, fördelade på 13 olika
val/nivå-kombinationer. Samtliga avser slutlig räkning. Inget produktionsfel
upptäcktes och ingen produktionskod ändrades.

## Lokala källor och täckning

Inventering av C:/valdata hittade följande resultatfiler under
`2026/genrep2026/s/`:

| Valområde | ZIP | Källtyper i ZIP |
|---|---|---|
| RD 00 | `rd/Genrep_2026_slutlig_00_RD.zip` | D, M, U |
| RF 01 | `rf/Genrep_2026_slutlig_01_RF.zip` | D, M, U |
| KF 0114 | `kf/Genrep_2026_slutlig_0114_KF.zip` | D, M |
| KF 0180 | `kf/Genrep_2026_slutlig_0180_KF.zip` | D, M |

D = individuell röstfördelning; M = röstfördelning i mandatfil;
U = underordnad summering. `index.md5` finns också lokalt.
Inga preliminära resultat-ZIP eller överordnade summeringar (OS) finns.
Kandidaturfilerna under val2026 är inte resultatkällor för denna kontroll.

RD omfattar hela valets lokala filurval. RF omfattar endast Stockholm (01),
och KF endast Upplands Väsby (0114) och Stockholm (0180). Övriga RF/KF-områden
är inte integrationstestade. Saknade filer har inte hämtats eller ersatts.

## Testade nivåer

Alla rader nedan passerade schema-, typ-, nyckel- och resultatkontrollerna.
Källvalet verifierades mot den beslutade matrisen.

| Val | Lokalt område | Nivå | Primärkälla | Rader | Geografiska enheter |
|---|---|---|---|---:|---:|
| RD | 00 | riket | M | 30 | 1 |
| RD | 00 | riksdagsvalkrets | M | 855 | 29 |
| RD | 00 | kommun | U | 7 353 | 290 |
| RD | 00 | kommunvalkrets | U | 1 114 | 41 |
| RD | 00 | valdistrikt | D | 92 876 | 6 626 |
| RF | 01 | region | M | 14 | 1 |
| RF | 01 | regionvalkrets | M | 168 | 12 |
| RF | 01 | kommun | U | 363 | 26 |
| RF | 01 | kommunvalkrets | U | 168 | 12 |
| RF | 01 | valdistrikt | D | 17 605 | 1 460 |
| KF | 0114 | kommun | M | 11 | 1 |
| KF | 0114 | kommunvalkrets | M | 0 | 0 |
| KF | 0114 | valdistrikt | D | 285 | 29 |
| KF | 0180 | kommun | M | 15 | 1 |
| KF | 0180 | kommunvalkrets | M | 89 | 6 |
| KF | 0180 | valdistrikt | D | 7 193 | 612 |

KF 0114 har ingen redovisad kommunvalkretsindelning. Resultatet är korrekt
en tom tibble med samma 83 kolumner och typer, inte en artificiell valkrets.

**Ej integrationstestat:** samtliga preliminära kombinationer; slutlig
RF/riket, KF/lan och KF/riket (OS saknas); övriga RF/KF-områden.
RD/lan och RF/lan är inte aktiverade i v1 och är inte positiva testfall.

## Metod och kontroller

`integration-valresultat.R` läser verkliga ZIP-poster med den nya läsaren.
Råobjekten återanvänds i minnet vid API-kontrollerna för att undvika upprepad
inläsning av stora JSON-filer. Testet begränsar indexet i minnet till den
aktuella lokala filen, utan att ändra index på disk. Detta är uttryckligen
en kontroll av lokalt täckta områden, inte en fallback i produktions-API:t.
RD:s urval är samtidigt fullständigt. Standardanrop testas dessutom med
det oförändrade lokala indexet och den verkliga läsaren.

- Exakt 83 kolumnnamn, ordning och typer enligt det frysta schemakontraktet.
- Unika val-/områdes-/partinycklar; inga listkolumner.
- Exakt överensstämmelse med motsvarande befintlig parser för gemensamma
  resultatfält, historik, differenser och relevanta spärrbesked.
- Total = giltiga + ogiltiga; partiernas summa = giltiga; ogiltiga = summan
  av publicerade underkategorier. Inga avvikelser bland jämförbara värden.
- Partiandelar motsvarar röster/giltiga × 100 med tolerans 0,011
  procentenheter för källans avrundning. Inga avvikelser.
- `over_sparr` är NA i D/U och på övriga-raderna. M följer parserns
  uttryckliga ja/nej-besked på rätt nivå.
- Antalet övriga-rader jämförs direkt med antalet närvarande rånoder.
  Alla undersökta existerande områden har en uttrycklig övriga-nod med
  noll röster; alla dessa nollor bevaras. Inga extra rader tillkommer.
  **Saknad/null övriga-nod förekommer inte i dessa råfiler** och den grenen
  kan därför endast hänföras till de deterministiska testerna, inte till
  ett observerat genrepsfall.

Elva jämförelser mellan officiella nivåer gav noll röstdifferenser och
inga ensidiga partinycklar: KF-distrikt till kommun (båda filerna),
KF-kommunvalkrets till kommun (0180), RD-distrikt/kommun/riksdagsvalkrets
till riket, RF-distrikt/kommun/regionvalkrets till region samt RD/RF:s
kommunvalkretsar till motsvarande valkretsindelade kommuner. Aggregation
görs endast i kontrollen, aldrig för att framställa API-resultatet.

## Defaults och förväntade fel

Anropen använder `source = "local"`, `data_dir = "C:/valdata"`,
`update = FALSE`, `archive = FALSE`, `progress = FALSE`, och lämnar
`niva` respektive `rakning` vid deras defaults.

| Anrop | Förväntat | Faktiskt | Klassificering |
|---|---|---|---|
| `valresultat(val = "RD", source = "local")` | Slutligt riksresultat | 30 rader, nivå riket, 83 kolumner | Godkänt |
| `valresultat(val = "RF", source = "local")` | Region/M, men fel om någon lokal fil saknas | Läser RF 01; ger fel för `s/rf/Genrep_2026_slutlig_03_RF.zip` | Saknad lokal råfil, inget parser-/adapterfel |
| `valresultat(val = "KF", source = "local")` | Kommun/M, men fel om någon lokal fil saknas | Läser KF 0114; ger fel för `s/kf/Genrep_2026_slutlig_0115_KF.zip` | Saknad lokal råfil, inget parser-/adapterfel |

Det lokala data_dir-värdet är satt via option i tabellens korta anrop.
Fullständiga RF/KF-defaultresultat kan inte verifieras med detta arkiv;
de lokala huvudnivåerna har verifierats enligt tabellen ovan. Ingen
automatisk reservkälla, nedladdning eller designändring används.

## Verkliga utdrag

Förkortat `glimpse()` från RD:s faktiska standardresultat:

```text
Rows: 30
Columns: 83
$ valtillfalle       <chr> "Genrep_2026", ...
$ rakningstillfalle  <chr> "slutlig", ...
$ valtyp            <chr> "RD", ...
$ test              <lgl> TRUE, ...
$ geografiniva      <chr> "riket", ...
$ antal_roster      <int> 1346623, 2104258, 307696, ...
$ andel_roster      <dbl> 19.72, 30.82, 4.51, ...
```

KF:s lokala urval, Upplands Väsby. Detta är inte ett fullständigt
`valresultat(val = "KF")`-resultat. Andelar nedan avrundade för visning:

| valomradeskod | valomradesnamn | partikod | partiforkortning | antal_roster | andel_roster |
|---|---|---|---|---:|---:|
| 0114 | Upplands Väsby | 0001 | M | 5 137 | 19,7 |
| 0114 | Upplands Väsby | 0002 | S | 8 610 | 33,0 |
| 0114 | Upplands Väsby | 0003 | L | 1 222 | 4,68 |

Fullständigt RD-glimpse och fler KF-rader finns i `VALRESULTAT_INTEGRATION.txt`.

## Filer och slutlig verifiering

Tillagt endast utvecklingsmaterial: detta dokument,
`integration-valresultat.R` och `VALRESULTAT_INTEGRATION.txt`.
Produktionskod, API, datamodell, personröstavailability och QMD är oförändrade.
Ingen commit har gjorts. Kontrollsummorna för index och samtliga fyra
genreps-ZIP är identiska före och efter körningen. Nedladdning och arkivering
är spärrade i integrationsskriptet; inga råfiler har kopierats till repot.

Slutversionen av integrationsskriptet avslutades med exitkod 0.
Första rapportkörningen hade ett tekniskt skriptfel efter sina kontroller;
slutversionen kördes därför om fullständigt. Detta var inget produktionsfel.

`R CMD check --no-manual --no-vignettes` kördes om på det oförändrade byggda
paketet: **0 errors, 0 warnings, 0 notes (Status: OK)**.
Hela testsuiten i paketkontrollen: **738 PASS, 0 FAIL, 0 WARN, 0 SKIP**.
Kontrollen kunde inte nå CRAN/Bioconductor-index, men den lokala
beroendekontrollen och slutstatusen var OK; inga beroenden hämtades.
Loggar: `.check/valresultat.Rcheck/00check.log` och
`.check/valresultat.Rcheck/tests/testthat.Rout`.
