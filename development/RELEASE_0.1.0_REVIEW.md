# Granskning inför valresultat 0.1.0

Datum: 2026-09-10

## Slutstatus 2026-09-11

De godkända måste- och bör-punkterna är genomförda. Livefilnamnen har
verifierats, standardinsamlingen är `val2026`, `genrep2026` kräver ett
uttryckligt val och paketversionen är 0.1.0. Slutlig releasegrind redovisas i
`RELEASE_0.1.0_INTEGRATION.md`.

## Tillägg: korrigerade livefilnamn 2026-09-10

Valmyndighetens uppdaterade tekniska beskrivning anger liveprefixet
`Val_2026` och visar bland annat `Val_2026_slutlig_00_RD.zip` samt den interna
filen `Val_2026_slutlig_summering_00_RD.json`. ZIP-valet använder fortsatt de
relativa sökvägarna från den valda samlingens `index.md5` och är oberoende av
prefixet. En kontroll inför 0.1.0 identifierade och rättade däremot stöd för
områdeskoden i liveversionen av den underordnade summeringsfilens JSON-namn.
Deterministiska tester täcker nu både `Val_2026_*` och genrepsformen.

## Samlad bedömning

2026-delen är nära en första version, men bör inte märkas `0.1.0` riktigt än.
Paketet har en normal och fungerande R-paketstruktur, sex tydliga exporter,
strikt och vältestad `valresultat()`-logik, genomarbetad hantering av
personrösternas availability och en helt grön paketkontroll. Ett rent
källpaket kan byggas, installeras och laddas utan utvecklingsfiler eller
`C:/valdata`.

Det som återstår före versionsbumpen är framför allt att frysa och validera
det gemensamma argumentkontraktet, rätta två återstående fall där okänd
kandidatinformation kan bli `FALSE`, göra `mandat()` strikt för kombinationer
och nycklar samt beskriva observationerna och den faktiska källtäckningen
tydligare. Dessa är små och avgränsade ändringar, men de berör beteenden som
blir betydligt dyrare att ändra efter den första publika versionen.

Ingen produktionskod, publikt API, Rd-fil eller README har ändrats i denna
granskning.

## Underlag och avgränsning

Granskningen omfattar nuvarande Git-historik till och med:

- `c5ec2a7 Add 2026 election results API`
- `32af2cb Handle person vote result availability`
- `61758b6 Expand package README`

`AGENTS.md`, all produktionskod i `R/`, samtliga exporterade hjälpsidor,
README, paketmetadata, tester och spårad utvecklingsdokumentation har
inspekterats. Bedömningen av verklig källtäckning bygger på de reproducerbara
redovisningarna i `VALRESULTAT_INTEGRATION.md` och
`PERSONROSTER_IMPLEMENTATION.md`. QMD-filen har inte använts som normativ
dokumentation och har inte ändrats.

Historiska val, mandatperiodsförändringar och nya större funktioner ingår inte.

## Publikt API

### Nuvarande kontrakt

| Funktion | `val` | Räkning | Geografi/default | Resultatkälla |
| --- | --- | --- | --- | --- |
| `valresultat()` | exakt en; default `"RD"`; inte `NULL` | exakt en; default `"slutlig"` | exakt en; `NULL` ger RD=`riket`, RF=`region`, KF=`kommun` | D/U/M/O enligt fast källmatris |
| `mandat()` | `NULL` ger alla; kod accepterar flera | en; default `"slutlig"` | `NULL` ger alla nivåer; kod accepterar flera | individuell mandatfil |
| `kandidaturer()` | `NULL` ger alla; kod accepterar flera | inte tillämpligt | källnära kandidaturer på flera områden/listor | kandidat-CSV |
| `kandidater()` | `NULL` ger alla; kod accepterar flera | kandidatresultat är slutliga | aggregerad kandidatnyckel | kandidat-CSV och slutliga individuella resultatfiler när `resultat=TRUE` |
| `valda()` | som `kandidater()` | slutlig | samma rad- och kolumnmodell som resultatkompletterade kandidater | filtrerad vy av `kandidater()` |
| `ersattare()` | `NULL` ger alla; kod accepterar flera | endast slutlig | relationer från valområdes- eller valkretsnivå | slutlig individuell mandatfil |

De gemensamma argumenten `ar`, `val`, `source`, `data_dir`, `update` och
`archive` ligger i samma grundordning. `progress` finns där flera
resultatfiler kan läsas men saknas rimligt nog i den enkla CSV-läsningen
`kandidaturer()`. `source = "local", update = TRUE` avvisas före filåtkomst
för alla sex funktioner.

Skillnaderna för `val` och `niva` är delvis sakligt motiverade:
`valresultat()` har ett uttryckligen beslutat kontrakt med ett val, en
räkning och en nivå, medan kandidat- och mandattabeller kan vara praktiska
över flera valtyper. De är ändå lätta att missa. Dokumentationen säger
"Valtyp" i singular för funktioner som faktiskt accepterar en vektor, och
`niva = NULL` betyder huvudnivå i `valresultat()` men alla nivåer i
`mandat()`. Detta måste vara ett medvetet och uttryckligt 0.1.0-kontrakt.

### Konkreta inkonsekvenser

- `valresultat()` kräver ett numeriskt skalärt år som exakt är 2026. De fem
  andra funktionerna använder `as.integer(ar)` och accepterar därmed bland
  annat `2026.9` och texten `"2026"`; en vektor kan ge ett internt bas-R-fel.
- `valresultat()` validerar `update`, `archive` och `progress` som exakta,
  icke-saknade logiska skalärer. Övriga funktioner har inte motsvarande
  gemensamma kontroll. Fel kan därför komma sent och från exempelvis `if`
  eller `purrr` i stället för från API:t.
- `kandidater(resultat = NA)`, och andra värden än exakt `TRUE`, behandlas
  i praktiken som `resultat = FALSE` genom `if (!isTRUE(resultat))`. Ett
  felaktigt argument kan alltså tyst ändra returtypen.
- `.valtyper()` normaliserar gemener och tar bort dubletter, vilket är bra,
  men accepterar flera valtyper utan att Rd-filerna säger det tydligt och
  saknar ett tydligt skalär-/vektorkontrakt för tomma eller saknade värden.
- `valresultat()` har egna svenska fel för de flesta argument medan flera
  andra funktioner lämnar `match.arg()`-fel. Det är inte ett modellfel, men
  gör närliggande funktioner mindre konsekventa.
- `mandat()` validerar nivåer mot en global lista och först efter inläsning
  filtreras utfallet. Exempelvis RD/`kommun` eller KF/`region` avvisas inte
  före I/O utan kan ge en tom tabell. Dokumentationen anger inte den giltiga
  valtyp/nivå-matrisen.
- `mandat()` ger fel om inga filer alls hittas, men kan tyst utelämna en
  valtyp om flera begärts och bara vissa filer finns. `ersattare()` saknar
  motsvarande kontroll och ger vid helt tomt filurval en 0-raders data.frame
  med 0 kolumner i stället för ett tydligt fel eller ett stabilt tomt schema.

## Datamodell och observationsnivåer

| Tabell | Avsedd rad | Dokumentationsläge |
| --- | --- | --- |
| `valresultat()` | val × räkning × geografiskt område × parti/kategori | tydligt beskriven, inklusive upprepade områdestotaler och 83-kolumnsschema |
| `mandat()` | val × räkning × geografiskt område × parti | antyds i returtexten, men nyckel, nivåmatris, typer och upprepade totaler beskrivs inte tillräckligt |
| `kandidaturer()` | en källnära kandidatur/listplacering | att data är källnära och inkluderar ogiltiga kandidaturer framgår, men den exakta raden/nyckeln och kolumnerna framgår inte |
| `kandidater()` | kandidatnummer × valtyp × partikod | tydligt beskriven, inklusive flervalssituationer och personrösternas 0/NA-regel |
| `valda()` | samma rad som `kandidater()`, filtrerad till `invald == TRUE` | tydligt beskriven |
| `ersattare()` | relation mellan en vald ledamot och en ersättare i ett geografiskt resultat | relationen framgår, men exakt relationsnyckel och kolumntyper framgår inte |

### Saknat, noll och falskt

Följande delar följer den beslutade principen väl:

- `valresultat()` använder typade `NA`, bevarar explicita nollor, skapar inte
  en artificiell övriga-rad och fyller `over_sparr` endast från ett
  uttryckligt relevant besked.
- Personrösttotalen är 0 endast när kandidaten saknas i verifierat komplett
  underlag för alla relevanta områden. Saknat, partiellt eller motsägelsefullt
  underlag ger `NA_integer_`.
- `kvalificerad_personval` och `invald` är avsedda att vara `FALSE` först när
  motsvarande information är tillgänglig; `valda()` filtrerar korrekt endast
  explicita `TRUE`.

Två återstående availability-bedömningar är för svaga för detta kontrakt:

- `.valda_available_2026()` använder `purrr::some()` över valkretsar. Om en
  valkrets har `valda` men en annan saknar eller har null-struktur bedöms hela
  valområdet som tillgängligt. Kandidater utan träff kan då få `invald=FALSE`
  trots att deras del av underlaget är okänd.
- `parse_personval_2026()` använder samma `some()`-princip för
  `kvalificeradeForPersonvalLista`. Partiell valkretstäckning kan därför ge
  `kvalificerad_personval=FALSE` och 0 personvalsområden där `NA` krävs.

Mandatparserns interna `sum_int_na()` ger dessutom en känd delsumman när en
del av partivärdena är `NA` och endast alla saknade värden ger `NA`. Om
källans uttryckliga områdestotal saknas kan en ofullständig partifördelning
därmed presenteras som en fullständig total. Fallbacksummeringen bör kräva
att samtliga komponenter är kända.

`antal_tomma_stolar` behöver ett litet källrepresentativt test: en frånvarande
`valda`-struktur ger korrekt `NA`, men det är inte verifierat om ett parti som
saknas i en i övrigt tillgänglig `partiLedamoterLista` betyder 0 eller okänt.
Det ska avgöras från råstrukturen innan någon utfyllnad införs.

### Namnstandard

Ingen förekomst av `valkrets_kod`, `valkrets_namn`,
`kommunvalkrets_kod` eller `kommunvalkrets_namn` finns i produktionskod,
tester, man-sidor eller README. De beslutade formerna `valkretskod`,
`valkretsnamn`, `kommunvalkretskod`, `kommunvalkretsnamn`,
`valomradeskod`, `valdistriktskod`, `kommunkod`, `lankod`, `partikod` och
`kandidatnummer` används.

Namn som `ledamot_namn` och `ersattare_namn` är rollkvalificerade fält och
inte sönderdelade svenska sammansättningar. Inga nya namnändringar behövs
inför 0.1.0 utifrån den beslutade standarden.

## 2026-källtäckning

### Implementerat i produktionskod

`valresultat()` har en fast primärkällmatris för både preliminär och slutlig
räkning:

| Val | Implementerade nivåer | Primärkällor |
| --- | --- | --- |
| RD | `valdistrikt`, `kommun`, `kommunvalkrets`, `riksdagsvalkrets`, `riket` | D, U, M |
| RF | `valdistrikt`, `kommun`, `kommunvalkrets`, `region`, `regionvalkrets`, `riket` | D, U, M, O |
| KF | `valdistrikt`, `kommun`, `kommunvalkrets`, `lan`, `riket` | D, M, O |

D är individuell röstfördelning, U underordnad summering, M röstfördelning
i mandatfil och O överordnad summering. RD/`lan` stöds inte. RF/`lan` har
förberedd O-källklass men avvisas uttryckligen i v1 tills den slutliga källan
är verifierad. Ingen automatisk fallback används.

`mandat()` läser preliminär eller slutlig mandatfördelning för RD, RF och KF.
De meningsfulla nivåerna som parsern faktiskt producerar är RD:
`riket`/`riksdagsvalkrets`, RF: `region`/`regionvalkrets` och KF:
`kommun`/`kommunvalkrets`.

`kandidaturer()` läser 2026 års kandidat-CSV. `kandidater(resultat=TRUE)`,
`valda()` och `ersattare()` använder endast slutliga individuella
resultatfiler. Kandidatflödet kan hämta personröster, personval och valda när
källstrukturerna är tillgängliga. Detaljerade list- och personrösttabeller
parsas internt men är inte separata publika exporter.

### Integrationstestat mot verkliga genrepfiler

Den spårade integrationsredovisningen visar följande faktiska täckning:

- Slutlig RD 00: D, U och M. `valresultat()` testades för `valdistrikt`,
  `kommun`, `kommunvalkrets`, `riksdagsvalkrets` och `riket`.
- Slutlig RF 01: D, U och M. `valresultat()` testades för `valdistrikt`,
  `kommun`, `kommunvalkrets`, `regionvalkrets` och `region`.
- Slutlig KF 0114 och 0180: D och M. `valresultat()` testades för
  `valdistrikt`, `kommunvalkrets` och `kommun` där nivån fanns.
- Kandidat-CSV:n lästes i den verkliga personröstintegrationen.
- Personröstavailability och kandidatresultatens interna filpipeline testades
  mot samma fyra slutliga ZIP-filer. Det omfattade verkliga personröster för
  åtta kompletta partier per fil samt 0/NA-utfall i kandidaturernas lokala
  områdesurval.
- Mandatfiler och parsern för valda/ersättare berördes av kandidatflödets
  filintegration, men det finns ingen separat dokumenterad end-to-end-körning
  av de publika `mandat()`, `valda()` eller `ersattare()` med frysta schema-
  och nyckelkontroller.

Följande är implementerat eller dokumenterat men inte integrationstestat mot
verkliga lokala filer i den redovisade körningen:

- alla preliminära `valresultat()`-kombinationer;
- O-källan: slutlig RF/`riket` samt KF/`lan` och KF/`riket`;
- övriga RF- och KF-valområden samt fullständiga defaultanrop för RF och KF;
- den publika `mandat()`-matrisen för preliminär och slutlig räkning;
- fullständiga publika kandidat-, valda- och ersättaranrop över alla områden.

Detta behöver inte blockera en experimentell 0.1.0 om README och Rd tydligt
skiljer implementerat från verifierat. Det får däremot inte beskrivas som
empiriskt verifierad full täckning. Inga saknade råfiler ska ersättas med
fallbacklogik.

## README och användardokumentation

README har tydliga GitHub-instruktioner för både `pak` och `remotes`, listar
alla sex huvudfunktioner och visar enkla anrop för var och en. Exemplen för
`valresultat()` stämmer med dess defaults och valda nivåer. Avsnittet om
lokal/remote data stämmer med implementationen och säger uttryckligen att
`source="local"` aldrig använder nätet.

Följande luckor bör täppas till före release:

- README:s geografiska lista utelämnar `lan`, trots att KF/`lan` är
  implementerat. Formuleringen om att ytterligare summeringar inte exponeras
  kan därför ge fel intryck.
- README säger generellt att preliminär och slutlig räkning stöds och att
  implementerade 2026-vägar har kontrollerats mot genrepfiler. Den bör kort
  säga att de verkliga integrationsfilerna hittills endast varit slutliga
  D/U/M-filer och att O/preliminärt är fixturetestat men inte empiriskt
  verifierat i den lokala körningen.
- Paketets egen hjälpsida säger "Läs kandidaturer, kandidater, mandat och
  ersättarrelationer" men nämner inte den centrala exporten `valresultat()`.
- `mandat()` behöver per-val-nivåer och en tydlig förklaring av att `NULL`
  returnerar flera geografiska nivåer vars totaler inte ska summeras ihop.
- Kandidatfunktionernas `val`-dokumentation behöver ange om vektorer är ett
  avsiktligt publikt kontrakt. `kandidater()` bör uttryckligen säga att
  `resultat=TRUE` använder slutlig räkning.
- `kandidaturer()` och `ersattare()` behöver en exakt raddefinition och
  nyckel. För alla tabeller utom `valresultat()` saknas en kompakt men
  tillräcklig beskrivning av publika kolumner, typer och strukturella `NA`.
- `mandat()`, `kandidaturer()`, `kandidater()`, `valda()` och `ersattare()`
  saknar användningsexempel i sina Rd-sidor. Eftersom dataåtkomst krävs kan
  korta `\dontrun{}`-exempel användas.

README:s installationssökväg `richardohrvall/valresultat` är konsekvent i
båda installationsalternativen. Inför publicering bör den verifieras mot den
faktiska publika GitHub-adressen; repot innehåller ingen metadata som ensam
kan bekräfta fjärråtkomst.

## Paketstruktur

| Del | Bedömning inför 0.1.0 |
| --- | --- |
| `DESCRIPTION` | giltig och check-grön; titel/beskrivning passar syftet men Description bör säga att paketet exponerar valresultat, inte bara har parsers; `URL` och `BugReports` saknas |
| `NAMESPACE` | genererad av roxygen2; exakt de sex avsedda funktionerna exporteras; beroendeanrop är namespacade |
| `man/` | sju spårade Rd-filer finns och ingår i bygget; ingen saknad exportdokumentation enligt check |
| `.Rbuildignore` | utesluter AGENTS, referenser, QMD, utvecklingsmapp, Git/RStudio och lokala checkbibliotek; rent bygginnehåll verifierat |
| `.gitignore` | täcker paketbyggen, checks, lokalt bibliotek och temporärdata; endast `VALRESULTAT_INTEGRATION.txt` ignoreras explicit |
| Tester | standardstruktur med `tests/testthat.R`, deterministiska fixtures och 810 godkända kontroller |
| Licens | korrekt `MIT + file LICENSE`; COPYRIGHT HOLDER Richard Öhrvall, år 2026 |
| Version | fortfarande `0.0.0.9000`; ska bumpas först efter godkända releasefixar |

`DESCRIPTION` deklarerar de paket som produktionskoden faktiskt använder:
`dplyr`, `janitor`, `jsonlite`, `purrr`, `readr`, `stringr`, `tibble`, `tools`
och `utils`. `roxygen2` och `testthat` ligger korrekt i Suggests. Kravet
R >= 4.1.0 motsvarar användningen av native pipe och kort lambda-syntax.

`PERSONROSTER_AVAILABILITY.md` länkar till
`PERSONROSTER_INTEGRATION.txt`, och implementationsrapporten säger att filen
är skapad, men den finns inte i repot. `STATUS.md` är också äldre och säger
fortfarande att availability bara är ett förslag. Development ingår inte i
källpaketet, så detta bryter inte installationen, men spårad projektstatus bör
inte motsäga nuvarande historik.

## Tester, check, bygge och installation

### Utfört i granskningen

- Hela testsuiten kördes från arbetsytan: **810 PASS, 0 FAIL, 0 WARN,
  0 SKIP**.
- Ett rent källträd skapades av endast `DESCRIPTION`, `NAMESPACE`, `LICENSE`,
  `README.md`, `.Rbuildignore`, `R/`, `man/` och `tests/`.
- `R CMD build --no-build-vignettes` skapade
  `valresultat_0.0.0.9000.tar.gz`.
- Tar-arkivet inspekterades. Det innehåller paketkod, metadata, README,
  hjälpsidor och tester; det innehåller inte `development/`, `references/`,
  AGENTS, QMD, Git-data eller någon `C:/valdata`-sökväg.
- `R CMD check --no-manual --no-vignettes` på detta arkiv gav
  **0 errors, 0 warnings, 0 notes (`Status: OK`)**. Pakettesterna kördes även
  inne i checken.
- Samma rena tar-arkiv installerades i ett tomt lokalt bibliotek med
  `R CMD INSTALL`. Paketet laddades med `valresultat.data_dir = NULL`,
  versionen och exakt de sex exporterna kunde läsas, utan utvecklingsfiler
  eller rådata.

En direkt `R CMD build .` med `TEMP` placerad under repot avbröts eftersom R
på Windows började kopiera temporärkatalogen rekursivt innan build-ignore
tillämpades. Den genererade katalogen togs bort och det etablerade rena
stagingflödet användes. Detta är inte ett paketfel och berör inte en normal
användare vars temporärkatalog ligger utanför källträdet.

Pakettesterna gör ingen nätåtkomst. Checkmiljön kunde inte läsa
CRAN/Bioconductors paketindex och skrev vanliga anslutningsmeddelanden under
beroendekontrollen; alla deklarerade beroenden fanns lokalt och den formella
checkstatusen förblev helt ren. Inga rådata lästes från `C:/valdata` i denna
releasegranskning.

### Betydande testluckor

Testmängden är inte problemet; den är redan stor. De relevanta luckorna är:

- inga tester för partiell valkretstäckning i `valda` och personval;
- inga konsekventa gränstester för `ar`, `val`, `data_dir`, `resultat`,
  `update`, `archive` och `progress` över alla sex exporter;
- ingen offentlig happy-path-matris för `mandat()`, inklusive giltiga och
  ogiltiga valtyp/nivå-par, stabilt schema, typer och unik nyckel;
- ingen offentlig happy-path för `ersattare()` med relationsnyckel och tomt
  stabilt schema;
- inget fryst schema-/typkontrakt för `kandidaturer()`, `kandidater()`,
  `valda()`, `mandat()` eller `ersattare()` motsvarande 83-kolumnskontraktet;
- mandatens fallbacksummering med blandning av kända värden och `NA` saknar
  test, liksom betydelsen av uteblivna partier i `antal_tomma_stolar`.

Integrationstesterna bör även fortsättningsvis vara separata från den vanliga
testsuiten och inte kräva nätverk eller hundratals externa filer.

## Måste åtgärdas före 0.1.0

### 1. Frys och validera argumentkontraktet

**Varför:** Felaktiga logiska värden kan tyst ändra resultatet och årsvalidering
skiljer sig mellan närliggande funktioner. Multipliciteten för `val` och
`niva` blir del av det publika API som användare bygger kod mot.

**Minsta ändring:** Inför små interna gemensamma validatorer för exakt år 2026,
logiska skalärer och valfri skalär sökväg. Låt `resultat`, `update`, `archive`
och `progress` kräva `TRUE` eller `FALSE`. Behåll den redan godkända regeln att
`valresultat()` tar exakt ett `val` och en nivå. Besluta uttryckligen om
vektorstöd i övriga funktioner; rekommendationen är att behålla det där det
redan är användbart men dokumentera och testa det. Dokumentera särskilt de
olika avsiktliga betydelserna av `niva=NULL` i `valresultat()` och `mandat()`.

### 2. Gör `mandat()` strikt för valtyp, nivå, filer och nyckel

**Varför:** Ett nonsenspar kan nu se ut som ett legitimt tomt resultat, och
saknade eller dubbla områdesfiler kan ge partiella eller duplicerade data.
Det gör resultat svåra att skilja från ett verkligt tomt valutfall.

**Minsta ändring:** Lägg in den sex par stora giltighetsmatris som parsern
redan uttrycker, validera begärda par före I/O, kontrollera exakt en fil per
förväntad filidentitet och avvisa saknade valtyper. Kontrollera därefter en
uttalad mandatnyckel, lämpligen val/räkning/geografinivå/områdesidentitet/parti.
Om vektorfiltrering ska få välja endast kompatibla par måste detta beskrivas
och testas explicit i stället för att uppstå genom efterhandsfiltrering.

### 3. Bevara `NA` vid partiell valda-/personvalstäckning och mandatsummor

**Varför:** Nuvarande `some()` kan omvandla partiellt okända kandidatuppgifter
till `FALSE`/0. Mandatens fallback kan omvandla en ofullständig fördelning
till en skenbart fullständig total. Båda strider mot paketets beslutade
informationsmodell.

**Minsta ändring:** Bedöm `valda` och personval över samtliga relevanta
valområdes-/valkretsnoder med tre tillstånd: komplett, uttryckligen tomt och
okänt/partiellt. Använd `FALSE`/0 endast vid verifierat komplett underlag.
Låt fallback för mandatens totaler summera endast när alla komponenter är
kända; annars typat `NA`. Lägg till små deterministiska fixtures för exakt
dessa fall. Avgör `antal_tomma_stolar` från en källrepresentativ fixture innan
frånvarande partier eventuellt fylls med noll.

### 4. Slutför minsta publika datakontrakt i dokumentationen

**Varför:** Paketet kan installeras och funktionerna är dokumenterade, men en
ny användare kan ännu inte säkert avgöra radnyckel, typer och strukturella
`NA` i fem av sex huvudtabeller. README skiljer inte tillräckligt tydligt
mellan implementerad och verkligt integrationstestad källtäckning.

**Minsta ändring:** Lägg till exakt raddefinition och nyckel för alla sex
tabeller, en kompakt kolumn-/typbeskrivning för de fem ofullständigt beskrivna
returvärdena och förklaring av upprepade totaler. Rätta README:s utelämnade
KF/`lan`, lägg in en kort implementerat/verifierat-not och komplettera
pakethjälpen med `valresultat()`. Beskriv `mandat()`-matrisen och att
kandidatresultat är slutliga. Regenerera Rd med roxygen2.

### 5. Sätt releaseversionen sist

**Varför:** `0.0.0.9000` identifierar fortfarande en utvecklingsversion.
Versionsnumret bör avse det slutliga, kontrollerade kontraktet.

**Minsta ändring:** När punkterna ovan är godkända och genomförda, ändra endast
`Version` till `0.1.0`, bygg ett nytt rent källpaket och kör hela testsuiten,
R CMD check och ren installation på nytt.

## Bör åtgärdas före 0.1.0

### 1. Lägg till fokuserade publika kontraktstester

**Varför:** De största testluckorna ligger i publika flöden, inte i intern
radtäckning. De riskerar regressioner i schema och nycklar som check inte ser.

**Minsta ändring:** Lägg till en liten mandatfixture och en liten
ersättarfixture som kör hela respektive API med mockad/local I/O. Frys namn,
typer och nycklar för alla huvudtabeller. Testa även en representativ
`kandidaturer()`/`kandidater()`/`valda()` happy-path samt tomma men kända
resultat. Undvik nya tester som bara upprepar implementationen.

### 2. Bredda integration när representativa filer finns

**Varför:** Preliminära format och O-formatet är de största empiriska luckorna.
Fixturetesterna visar intern konsistens men kan inte upptäcka verkliga
formatavvikelser.

**Minsta ändring:** Kör de befintliga read-only-integrationsmönstren mot en
preliminär D/U/M/O-fil och slutliga O-filer när de finns. Lägg därefter till
end-to-end-kontroller för publika `mandat()`, `valda()` och `ersattare()` på
ett litet urval. Om filer inte finns vid release, behåll tydlig märkning om
att dessa vägar är implementerade men ännu inte empiriskt verifierade.

### 3. Komplettera release- och projektmetadata

**Varför:** README hänvisar användare till GitHub för installation och fel,
men paketmetadata saknar maskinläsbara länkar och det finns ingen kort
versionshistorik.

**Minsta ändring:** Lägg till `URL` och `BugReports` i `DESCRIPTION` efter att
den publika GitHub-adressen verifierats. Skapa en kort `NEWS.md` för 0.1.0 med
de sex huvudfunktionerna, 2026-avgränsningen och statusen experimentell.

### 4. Rätta spårad utvecklingsstatus

**Varför:** `STATUS.md` säger felaktigt att personröstavailability inte är
implementerad, och två dokument hänvisar till en integrationslogg som saknas.
Det gör Git-historiken svårare att granska även om filerna inte ingår i
paketbygget.

**Minsta ändring:** Uppdatera statusraden eller märk dokumentet tydligt som en
historisk ögonblicksbild. Antingen spåra den avsedda korta
`PERSONROSTER_INTEGRATION.txt` eller ändra länkarna till den redan spårade
sammanfattningen i `PERSONROSTER_IMPLEMENTATION.md`. Säkerställ samtidigt att
avsiktligt genererade integrationsloggar behandlas konsekvent i `.gitignore`.

### 5. Lägg till korta Rd-exempel

**Varför:** README ger en bra start men `?mandat`, `?kandidaturer` och övriga
funktionssidor saknar ett direkt användningsexempel.

**Minsta ändring:** Lägg ett enkelt `\dontrun{}`-anrop per publik funktion med
ett explicit `val`. För `source="local"` bör exemplet visa `data_dir` utan en
utvecklarspecifik sökväg.

## Kan vänta

### Historiska val och mandatperiodsdata

**Varför:** De ligger uttryckligen utanför 2026-kontraktet och kräver egna
modeller och källor.

**Minsta framtida ändring:** Planera dem som separata versionerade etapper utan
att vidga 0.1.0.

### RF/`lan`

**Varför:** Nivån är medvetet avstängd tills en faktisk slutlig OS-källa är
verifierad. Nuvarande tydliga fel är säkrare än ett redundant eller osäkert
resultat.

**Minsta framtida ändring:** Aktivera den befintligt förberedda källklassen
först efter M/O-jämförelse av alla regioner/län och ett uttryckligt API-beslut.

### Separata publika detaljtabeller för personröster

**Varför:** Parsern bevarar list-, detalj- och summeringsnivåerna internt, men
nya exporter skulle utöka API:t och behöver ett eget datamodellbeslut.

**Minsta framtida ändring:** Ta fram en separat design när användningsfallen
är prioriterade; ändra inte kandidatnyckeln för att exponera dem.

### Vignett, pkgdown, citation och CRAN-anpassning

**Varför:** README och Rd räcker för en första GitHub-version när de konkreta
dokumentationsluckorna ovan är stängda. Dessa artefakter förbättrar
upptäckbarhet men påverkar inte datakorrektheten.

**Minsta framtida ändring:** Lägg till dem när API:t har fått faktisk
användarerfarenhet efter 0.1.0.

### Den explorativa QMD-filen

**Varför:** Den är en utvecklingslogg och ingår varken i källpaketet eller det
publika kontraktet.

**Minsta framtida ändring:** Ingen. Flytta endast ny stabil logik eller stabila
kontroller till `R/` respektive `tests/testthat/` när ett konkret behov uppstår.

## Rekommenderad ordning efter godkännande

1. Besluta/frys argumentmultiplicitet och `mandat()`-nivåmatris.
2. Inför gemensam argumentvalidering och strikta fil-/nyckelkontroller.
3. Rätta de tre återstående NA-fallen och lägg till riktade fixtures.
4. Lägg till publika schema-/happy-path-tester.
5. Uppdatera README, roxygen, paketöversikt och release metadata.
6. Kör roxygen2, hela testsuiten, rent bygge, R CMD check och ren installation.
7. Bumpa till `0.1.0`, bygg och verifiera en sista gång.

Ingen git commit har gjorts.
