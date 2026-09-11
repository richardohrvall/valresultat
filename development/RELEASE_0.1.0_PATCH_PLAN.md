# Konkret patchplan inför valresultat 0.1.0

Datum: 2026-09-10

## Syfte och beslut som planen utgår från

Planen omsätter punkterna under **måste** och **bör** i
`RELEASE_0.1.0_REVIEW.md` till små, granskningsbara patchar. Ingen
produktionskod eller publik dokumentation har ändrats när denna plan skrivs.

Följande publika kontrakt föreslås frysas utan ändrade argumentnamn eller
defaults:

- `valresultat()` tar exakt en valtyp, exakt en räkning och exakt en
  geografisk nivå. `niva = NULL` ger den redan beslutade huvudnivån.
- `mandat()`, `kandidaturer()`, `kandidater()`, `valda()` och `ersattare()`
  behåller `val = NULL` som alla valtyper och behåller stöd för en vektor av
  valtyper. Detta följer den uttryckliga riktningen i `AGENTS.md` för
  kandidatfunktionerna och är redan användbart för mandat/ersättare.
- `mandat()` behåller `niva = NULL` som alla relevanta mandatnivåer och stöd
  för en nivåvektor. En explicit nivåvektor fungerar som ett filter över den
  giltiga valtyp/nivå-matrisen; den bildar inte en kartesisk produkt.
- `rakning` fortsätter avse exakt en räkning. Kandidatresultat, `valda()` och
  `ersattare()` fortsätter använda endast slutlig räkning.
- `source`, `data_dir`, `update`, `archive` och `progress` behåller nuvarande
  betydelse och defaults. `source = "local"` får aldrig orsaka nätåtkomst.

Den föreslagna ordningen är att först lägga argument- och källkontrakten,
sedan availability och mandatsummor, därefter kontraktstester och
dokumentation, och sist versionsnumret.

## Måste 1: frys och validera argumentkontraktet

### 1. Exakt nuvarande beteende

- `valresultat()` kräver att `ar` är ett numeriskt skalärt värde exakt lika
  med 2026. De fem övriga exporterna kontrollerar i stället
  `identical(as.integer(ar), 2026L)`. Därmed accepteras exempelvis `2026.9`
  och `"2026"`, medan en vektor kan ge ett internt bas-R-fel.
- `valresultat()` kräver exakta logiska skalärer för `update`, `archive` och
  `progress`. Övriga exporter gör inte samma tidiga kontroll.
- `kandidater()` använder `if (!isTRUE(resultat)) return(out)`. Alla värden
  utom exakt `TRUE`, inklusive `NA`, `NULL`, `1` och `"ja"`, fungerar därför
  som `FALSE` i stället för att ge argumentfel.
- `.valtyper()` accepterar `NULL`, en eller flera teckensträngar, normaliserar
  gemener och tar bort dubletter. Den kontrollerar inte uttryckligen tom
  vektor, `NA` eller tom sträng före `toupper()`/`setdiff()`.
- `mandat()` använder `match.arg(rakning)` och accepterar unika
  förkortningar, medan `valresultat()` kräver hela `"slutlig"` eller
  `"preliminar"` och ger ett eget svenskt fel.
- `data_dir` kontrolleras som ett textskalärvärde i `valresultat()`, men inte
  i de övriga exporterna. En vektor eller tom sträng kan därför nå
  `normalizePath()` och ge ett sent tekniskt fel.
- Alla sex använder `match.arg(source)` och har därmed samma nuvarande
  source-regel. Den behöver inte ändras.

### 2. Berörda funktioner och filer

- Ny intern fil: `R/api_validation.R`.
- `R/api_valresultat.R`.
- `R/api_mandat.R`.
- `R/api_kandidaturer.R`.
- `R/api_kandidater.R` (`kandidater()` och `valda()`).
- `R/api_ersattare.R`.
- `tests/testthat/test-arguments.R`.
- `tests/testthat/test-valresultat.R` och
  `tests/testthat/test-local-source.R` där befintliga argumentfel redan testas.
- Roxygenkällorna ovan och genererade `man/*.Rd` för förtydligad multiplicitet.

### 3. Konkreta felaktiga eller överraskande exempel

```r
kandidaturer(ar = 2026.9)       # passerar årskontrollen
kandidater(resultat = NA)       # returnerar tabellen utan resultatkolumner
mandat(rakning = "s")           # accepteras
valresultat(rakning = "s")      # avvisas
kandidaturer(data_dir = c("a", "b")) # sent normalizePath-/längdfel
```

Anropen ska inte ändra innebörd beroende på vilken av de närliggande
funktionerna som används.

### 4. Önskat beteende

- `ar` ska i alla sex funktioner vara ett numeriskt, ändligt,
  icke-saknat skalärvärde exakt lika med 2026. Ingen tyst heltalskonvertering.
- Alla publika logiska argument ska vara ett logiskt skalärvärde som inte är
  `NA`: `resultat`, `update`, `archive` och, där det finns, `progress`.
- Explicit `data_dir` ska vara `NULL` eller en icke-tom teckensträng av längd
  ett. Optionen valideras av samma interna sökväg när den används.
- `valresultat(val=...)` ska fortsatt kräva exakt en valtyp. Övriga fem ska
  acceptera `NULL` eller minst en valtyp, normalisera gemener och ta bort
  dubletter; `character(0)`, `NA` och `""` ska ge tydliga svenska fel.
- `rakning` ska kräva hela värdet `"slutlig"` eller `"preliminar"` i både
  `valresultat()` och `mandat()`. Default förblir `"slutlig"`.
- Alla dessa fel ska uppstå före index-, fil- eller nätåtkomst och använda
  samma korta svenska felstil med argumentnamnet i backticks.

### 5. Minsta kodändring

Lägg till tre eller fyra små interna hjälpare i `R/api_validation.R`, till
exempel:

- `.check_ar_2026(ar, funktion)`;
- `.check_flag(x, namn)`;
- `.check_data_dir(data_dir)`;
- `.check_choice(x, namn, choices)` för räkning och andra exakta val.

Skärp befintliga `.valtyper()` i stället för att skapa en parallell
valtypsparser. Lägg till ett argument som endast styr om `NULL` är tillåtet
eller kontrollera längden separat i `valresultat()`. Behåll `toupper()` och
`unique()` så att redan fungerande gemener och dublettnormalisering består.

Anropa hjälparna i samma ordning i de sex exporterna innan I/O. Behåll
`match.arg(source)` eftersom source-beteendet redan är konsekvent. Ta bort
den lokala `.valresultat_scalar()` endast om dess återstående användning helt
ersätts; annars låt den delegera till den gemensamma hjälparen.

Inga argumentnamn, defaults, returkolumner eller observationsnivåer ändras.

### 6. Tester som ska läggas till eller ändras

Utöka `test-arguments.R` med en tabellstyrd kontroll för alla relevanta
exporter:

- avvisa `ar = "2026"`, `2026.9`, `NA`, `Inf`, `numeric()` och två år;
- avvisa `NA`, `NULL`, 0/1, text och längd två för varje logiskt argument;
- avvisa explicit `data_dir = ""`, `NA_character_` och längd två;
- avvisa tom, saknad och okänd valtyp; bevara `c("rd", "KF", "rd")` som
  `c("RD", "KF")` där vektorer är tillåtna;
- avvisa förkortad och vektoriserad `rakning` i båda resultatfunktionerna;
- verifiera genom mocks att samtliga fel kommer före `.read_resultatindex_2026`,
  `val_file()` eller annan filåtkomst;
- behåll och utöka testen att `source="local", update=TRUE` alltid stoppas
  före I/O.

Ändra befintliga tester som förväntar `match.arg()`-text så att de i stället
matchar de gemensamma svenska felen. Lägg inte tester på intern ordalydelse
utöver argumentnamn och den sakliga orsaken.

## Måste 2: strikt `mandat()`-matris, filurval och nyckel

### 1. Exakt nuvarande beteende

`parse_mandat_2026()` producerar exakt följande meningsfulla par:

| Valtyp | Valområdesnivå | Valkretsnivå |
| --- | --- | --- |
| RD | `riket` | `riksdagsvalkrets` |
| RF | `region` | `regionvalkrets` |
| KF | `kommun` | `kommunvalkrets` |

`mandat()` validerar däremot `niva` endast mot den gemensamma listan med sex
nivåer. Funktionen läser först alla filer för vald `val`, parsar dem och
filtrerar därefter `geografiniva %in% niva`. Ett giltigt nivånamn som är
meningslöst för den valda valtypen ger därför normalt en tom tabell i stället
för ett tidigt fel.

`.resultat_paths_2026()` och mandatfunktionens egna path-sökning kräver inte
en träff per efterfrågad valtyp och kontrollerar inte dubbla filidentiteter.
Om flera valtyper begärs kan en helt saknad valtyp tyst försvinna så länge
någon annan fil hittas. `ersattare()` ger vid helt tomt path-urval ett
0-raders data.frame med 0 kolumner. Kandidatflödet ger fel endast när det
sammanlagda path-urvalet är tomt.

`mandat()` kontrollerar inte att slutresultatets avsedda nyckel är unik. En
dubblerad indexpost eller två filer med samma områdeskod kan därför ge
dubblerade partirader.

### 2. Berörda funktioner och filer

- `R/api_mandat.R`.
- `R/kandidatresultat_2026.R`, särskilt `.resultat_paths_2026()` som även
  används av kandidat- och ersättarflöden.
- `R/api_ersattare.R` för tydligt tomt path-fel/stabilt tomt resultat.
- Eventuellt en liten intern `.mandat_schema_2026()` i
  `R/parse_mandat_2026.R` eller en separat intern schemafil.
- Ny `tests/testthat/test-mandat.R`.
- `tests/testthat/test-arguments.R`, `test-kandidater.R` och ett nytt eller
  befintligt ersättartest för path-fall.

### 3. Konkreta felaktiga eller överraskande exempel

```r
mandat(val = "RD", niva = "kommun")
# "kommun" är ett känt nivånamn men RD-mandat finns inte på kommunnivå.
# I dag sker I/O och resultatet kan bli en legitimt utseende tom tabell.

mandat(val = c("RD", "RF"))
# Om index bara innehåller RD kan RF tyst saknas.

ersattare(val = "RF")
# Om index saknar RF-path blir resultatet ett 0 x 0-data.frame.
```

Ett explicit `mandat(val=NULL, niva="kommun")` är däremot legitimt: nivåfiltret
väljer KF ur alla valtyper. Det får inte blockeras bara för att kommun inte är
en RD- eller RF-nivå.

### 4. Önskat beteende

Skapa först mängden giltiga par från sexrads-matrisen ovan och filtrera den
med efterfrågade `val` och `niva`:

- `niva=NULL` väljer båda giltiga nivåerna för varje vald valtyp.
- Explicit `niva` väljer de giltiga par som matchar nivån/nivåerna.
- Fel ges före I/O om något explicit nivåvärde inte matchar någon av de valda
  valtyperna, eller om inga giltiga par återstår.
- Det är tillåtet att ett nivåfilter gör att en valtyp inte återstår:
  `mandat(val=NULL, niva="kommun")` och
  `mandat(val=c("RD","KF"), niva="kommun")` ska båda läsa endast KF.
- En nivåvektor där någon begärd nivå inte matchar någon vald valtyp ska ge
  fel i stället för att tyst kasta bort just den nivån.

Endast valtyper som återstår i den giltiga parmängden ska kräva filer och
läsas. Indexet är auktoritet för vilka områdesfiler som publicerats; koden
ska inte hårdkoda antalet 20 RF- eller 290 KF-filer. Däremot ska den kräva
minst en fil för varje valtyp som faktiskt återstår och exakt en path per
filidentitet: RD `00`, RF tvåsiffrig valområdeskod, KF fyrsiffrig kod.

Ett existerande, giltigt filunderlag där `mandatfordelning` ännu är
explicit null/tomt får ge en typad tom mandattabell. Det ska skiljas från
saknad primärfil. Resultatet ska alltid ha ett stabilt mandatschema.

Den avsedda unika nyckeln ska vara:

`valtillfalle × valtyp × rakningstillfalle × geografiniva × valomradeskod × valkretskod × partikod`

På valområdesnivå är `valkretskod` typat `NA_character_` men ingår ändå i
nyckelkontrollen som strukturell nivåmarkör.

### 5. Minsta kodändring

- Lägg en liten konstant eller intern tibble med de sex giltiga paren i
  `R/api_mandat.R` och beräkna det efterfrågade paret före indexläsning.
- Begränsa path-sökningen till de valtyper som finns kvar efter nivåfiltret.
- Extrahera filidentiteten ur redan matchade paths och ge fel på dublett.
  Återanvänd samma lilla kontroll i `.resultat_paths_2026()` för
  kandidater/ersättare; ändra inte URL- eller source-logik.
- Kräv minst en path per kvarvarande valtyp. Ge funktionsspecifikt tydligt fel
  om en valtyp helt saknas.
- Lägg till en intern typed-empty-mandat-prototyp och bind parserresultaten
  mot den. Det ändrar inga kolumnnamn eller typer i icke-tomma resultat.
- Lägg till en nyckelkontroll efter nivåfiltreringen. Kontrollera också att
  råfilens `valtyp` och `rakningstillfalle` motsvarar path/anrop innan data
  binds, på samma sätt som `valresultat()` redan gör.
- Låt `ersattare()` och kandidatflödet använda den skärpta path-kontrollen.
  Om en giltig fil finns men innehåller en verifierat tom ersättarlista ska
  parserns befintliga typade tomma schema behållas.

Ingen ny geografisk nivå aktiveras och inga mandat aggregeras mellan nivåer.

### 6. Tester som ska läggas till eller ändras

I `test-mandat.R`:

- testa alla sex giltiga valtyp/nivå-par för både preliminär och slutlig
  räkning med deterministiska M-fixtures;
- testa de tolv ogiltiga paren mot de sex publika nivåerna och kontrollera
  att felet kommer före I/O;
- testa `niva=NULL` och nivåvektorer, inklusive de legitima filtren
  `val=NULL,niva="kommun"` och `val=c("RD","KF"),niva="kommun"`;
- testa att ett explicit nivåvärde utan match ger fel även om ett annat
  värde i samma nivåvektor är giltigt;
- testa saknad valtyp i index, dubbla paths för samma kod och råmetadata som
  inte stämmer med anropet;
- frys mandatschema och `typeof()` för både icke-tomt och verifierat tomt
  resultat;
- testa nyckelunikhet och att en avsiktlig dublett ger tydligt fel;
- testa att source-flaggorna vidarebefordras utan fallback.

För kandidat/ersättare:

- begär två valtyper när index endast innehåller en och förvänta saknad-fil-fel;
- kontrollera dublett filidentitet;
- kontrollera att en befintlig fil med explicit tom ersättarlista ger 0 rader
  med fullständigt schema, medan helt saknad path ger fel.

## Måste 3A: availability för valda

### 1. Exakt nuvarande beteende

Den slutliga mandatfilen dokumenterar `valda` som `object / null` på
valområdes- och valkretsnivå. Objektet innehåller
`partiLedamoterLista`; varje partinod innehåller `antalTommaStolar` och en
array `ledamoter`.

`.valda_available_2026()` sätter i dag availability till `TRUE` om
`valomrade$valda` är närvarande och inte null **eller** om minst en valkrets
har ett närvarande icke-null `valda`. Den granskar inte objektets form,
övriga valkretsar, mandatantal, tomma stolar eller om räkningen är slutlig och
komplett.

`parse_valda_ersattare_2026()` parsar alla valkretsar och använder
valkretsnivån om den gav minst en ledamotsrad; annars faller den tillbaka till
valområdesnivån. En explicit tom men komplett valkretsstruktur kan alltså inte
skiljas från saknat underlag genom antalet parserrader.

I `.add_kandidatresultat_2026()` omvandlas saknad area-status dessutom med
`coalesce(valda_available, FALSE)`. Om minst ett område har en statusrad men
ett annat saknas kan kandidaten därför få ett verifierat negativt utfall utan
verifierat underlag.

### 2. Berörda funktioner och filer

- `R/kandidatresultat_2026.R`: `.valda_available_2026()`,
  `.parse_kandidatresultat_fil_2026()` och aggregeringen av kandidatens
  områdesstatus.
- `R/parse_valda_ersattare_2026.R` för att hålla vald officiell nivå och tomt
  schema konsekventa med statusbedömningen.
- Eventuellt återanvändbara interna struktur-/heltalshjälpare från
  `R/personroster_availability_2026.R`; ingen ny publik funktion.
- `tests/testthat/test-parsers.R` och `test-kandidater.R`.
- En ny fokuserad `tests/testthat/test-kandidatstatus-availability.R` om
  fixtures annars gör de befintliga filerna svårlästa.

### 3. Konkret felaktigt exempel

Ett valområde har två valkretsar. Valkrets A innehåller ett giltigt
`valda`-objekt och valkrets B har `valda = null`. Dagens `purrr::some()` ger
`valda_available = TRUE`. En kandidat som bara står i B och inte finns bland
de parsade ledamöterna får då `invald = FALSE`. Rätt värde är `NA`, eftersom
B:s valda-underlag saknas.

Ett annat fall är `valda = list()` eller
`valda = list(partiLedamoterLista=list())` i ett område med positiva mandat.
Dagens närvarotest kan ge `TRUE` trots att tomheten motsäger mandatresultatet.

### 4. Önskat beteende och exakt rådataregel

Availability ska vara ett internt logiskt trelägestillstånd per valtyp och
valområde:

**Helt saknat (`FALSE` internt, kandidatutfall `NA`):**

- På den officiellt relevanta nivån saknar samtliga noder fältet `valda` eller
  har explicit `valda = null`.
- Frånvaron är en uppgift om att valda-resultatet inte publicerats, inte att
  ingen kandidat valts. Kandidatens `invald` ska därför vara `NA`.

**Verifierat komplett (`TRUE`):**

- `rakningstillfalle` är `"slutlig"`.
- På valområdesnivå är `valomrade$antalValdistriktRaknade` och
  `valomrade$antalValdistriktSomSkaRaknas` närvarande, giltiga icke-negativa
  heltal och lika. På valkretsnivå gäller samma krav för de två fälten i varje
  relevant `valkretsLista[]`. Saknad räknare gör statusen oavgörbar.
- Den relevanta nivån är entydig. För ett valkretsindelat område används
  valkretsnivån endast om varje valkrets har ett explicit, strukturellt
  giltigt `valda`-objekt. Om samtliga valkretsnoder saknar/null och ett
  giltigt valområdesobjekt finns används valområdesnivån. Blandning mellan
  nivåer eller mellan närvarande och saknade valkretsnoder är inte komplett.
- Varje relevant `valda` är ett objekt med en explicit array
  `partiLedamoterLista`. Varje partinod har unik, giltig `partikod`, en
  explicit array `ledamoter` med unika giltiga kandidatnummer och ett
  icke-negativt heltal `antalTommaStolar`.
- Samma relevanta nod har en strukturellt giltig
  `mandatfordelning$partiLista`. För varje parti med mandat gäller exakt
  `antal ledamöter + antalTommaStolar == antalMandat`, och partier/totaler
  kan stämmas av utan saknade komponenter. En explicit tom partilista är
  komplett endast när den officiella mandattotalen är explicit 0.

**Partiellt, motsägelsefullt eller oavgörbart (`NA` internt):**

- några men inte alla relevanta valkretsar har `valda`;
- objekt/arrayer har fel typ, dubletter eller saknade identiteter;
- distriktsräkningen är ofullständig;
- ledamöter plus tomma stolar avviker från mandatfördelningen;
- både valområdes- och valkretsplacering ger motstridiga besked;
- kompletthet kan av annat skäl inte bevisas från råfilen.

En kandidat som finns i en giltig ledamotsrad får `invald=TRUE` även om ett
annat relevant område är ofullständigt: det positiva fyndet är definitivt.
En kandidat som inte finns får `invald=FALSE` endast när samtliga områden från
kandidatens giltiga kandidaturer har `TRUE`. Saknas minst ett område eller har
det `FALSE`/`NA` blir kandidatens negativa utfall `NA`.

### 5. Minsta kodändring

- Behåll namnet `.valda_available_2026()` men låt hjälparen returnera
  `TRUE`, `FALSE` eller `NA` efter regeln ovan. Dela vid behov upp den i en
  liten nodvalidator och en nivåväljare.
- Låt nivåväljaren också styra vilken av de redan befintliga tabellerna från
  `parse_valda_ersattare_2026()` som används, så att parsning och availability
  inte gör var sin heuristik. Detta kan göras med ett internt attribut eller
  ett internt listfält; den publika tabellen ändras inte.
- Bevara statusvärdet direkt i `.parse_kandidatresultat_fil_2026()`.
- Ta bort `coalesce(..., FALSE)` för saknad områdesstatus. Aggregera till
  komplett endast om alla relevanta områden är `TRUE`.
- Behåll `invald_found ~ TRUE` som första gren. Använd `FALSE` endast när
  kandidatens samlade availability är exakt `TRUE`; annars typat `NA`.

Ingen kandidatnyckel, observationsnivå eller publik kolumn ändras.

### 6. Tester som ska läggas till eller ändras

Bygg små slutliga mandatfixtures för:

- icke-valkretsindelat område med komplett `valda` och kandidat närvarande;
- samma kompletta struktur där en giltig kandidat saknas: `invald=FALSE`;
- explicit tom struktur och mandattotal 0: komplett tomt resultat;
- explicit tom struktur men positivt mandatantal: `NA`;
- alla relevanta `valda` saknade respektive null: intern `FALSE`, kandidat
  `NA`;
- två valkretsar där båda är kompletta: `TRUE`;
- två valkretsar där endast en har struktur: `NA`, och frånvarande kandidat
  får `NA`;
- fel typ, dubbelt parti, dubbelt kandidatnummer, saknat `antalTommaStolar`
  och identitetsfel: `NA`;
- `ledamoter + antalTommaStolar` lika med respektive skilt från
  `antalMandat`;
- kandidat med giltiga kandidaturer i två valområden: `FALSE` endast när båda
  är kompletta och kandidaten saknas i båda; `TRUE` vid ett faktiskt fynd;
  annars `NA`.

Uppdatera det befintliga testet som i dag betraktar blotta `valda=list()` som
tillgängligt. Lägg till ett test att en saknad join-status inte blir `FALSE`.

## Måste 3B: availability för personval

### 1. Exakt nuvarande beteende

Slutformatets referens säger uttryckligen att
`kvalificeradeForPersonvalLista` finns på valområdesnivå för ett område utan
valkretsindelning och i varje `valkretsLista[]` för ett valkretsindelat område.
Listan är de kandidater som klarat personröstspärren; en explicit tom array
kan därför betyda att ingen klarade den.

`parse_personval_2026()` sätter i dag attributet `personval_available=TRUE`
om minst en valkrets har en närvarande, icke-null lista. Den validerar inte
alla valkretsar, räkningsgrad, arraytyp, dubletter eller kandidatidentiteter.
I `.parse_kandidatresultat_fil_2026()` används dessutom
`isTRUE(attr(...))`, vilket omvandlar ett framtida `NA`-attribut till
`FALSE`.

Saknad områdesstatus coalescas senare till `FALSE`. Vid resultatbyggandet får
en kandidat som finns i någon personvalsrad `kvalificerad_personval=TRUE` och
ett räknat `antal_personvalsomraden`, även om övriga relevanta områden är
ofullständiga. Det logiska positiva fyndet är säkert, men antalet är då bara
en delsiffra.

### 2. Berörda funktioner och filer

- `R/parse_personval_2026.R`.
- `R/kandidatresultat_2026.R`.
- Interna strukturhjälpare kan återanvändas från
  `R/personroster_availability_2026.R`.
- `tests/testthat/test-parsers.R`, `test-kandidater.R` och den föreslagna
  `test-kandidatstatus-availability.R`.
- Roxygen i `R/api_kandidater.R` och genererade `man/kandidater.Rd` för den
  exakta NA-regeln.

### 3. Konkret felaktigt exempel

Två valkretsar finns. A har en explicit lista med kandidat 1; B saknar listan.
Dagens status blir `TRUE` eftersom A räcker. Kandidat 2, som bara står i B,
kan få `kvalificerad_personval=FALSE` och 0 områden. B:s resultat är i själva
verket okänt, så båda värdena ska vara `NA`.

Kandidat 1 kan säkert få `kvalificerad_personval=TRUE`, men om kandidaten
också står i B är det totala `antal_personvalsomraden` okänt och ska vara
`NA`, inte 1.

### 4. Önskat beteende och exakt rådataregel

**Helt saknat (`FALSE` internt, kandidatvärden `NA`):** Alla listor på den
officiellt relevanta nivån är frånvarande eller explicit null. För ett
valkretsindelat område bedöms samtliga valkretsar; annars valområdesnoden.

**Verifierat komplett (`TRUE`):**

- filen är slutlig;
- på valområdesnivå är `valomrade$antalValdistriktRaknade` och
  `valomrade$antalValdistriktSomSkaRaknas` närvarande, giltiga icke-negativa
  heltal och lika; på valkretsnivå gäller motsvarande två fält i varje
  relevant `valkretsLista[]`; saknad räknare ger `NA`;
- varje relevant nod innehåller fältet
  `kvalificeradeForPersonvalLista` som en explicit array, även om arrayen är
  tom;
- varje rad har giltig och unik identitet för minst
  `kandidatnummer × partikod` inom personvalsområdet samt giltiga typer för
  de publicerade personröstfälten;
- alla relevanta områden/valkretsar kan granskas. För ett icke-indelat område
  får listan inte samtidigt delvis placeras på valkretsnivå.

**Partiellt/motsägelsefullt (`NA` internt):** Några men inte alla relevanta
noder har listan, räkningen är ofullständig, listan är feltypad, nycklar är
dubbla/saknas eller nivåplaceringen är motsägelsefull.

Kandidatutfallet ska därefter vara:

- faktisk rad i någon granskad lista: `kvalificerad_personval=TRUE`;
- ingen rad och alla kandidatens relevanta valområden kompletta:
  `kvalificerad_personval=FALSE` och `antal_personvalsomraden=0L`;
- ingen rad och minst ett område saknat/partiellt:
  `kvalificerad_personval=NA` och `antal_personvalsomraden=NA_integer_`;
- faktisk rad men minst ett annat relevant område saknat/partiellt:
  `kvalificerad_personval=TRUE`, men
  `antal_personvalsomraden=NA_integer_` eftersom totalantalet inte är känt;
- alla områden kompletta: exakt antal distinkta personvalsområden, inklusive
  explicit 0.

### 5. Minsta kodändring

- Låt `parse_personval_2026()` beräkna ett tri-state-attribut genom en liten
  nodvalidator och returnera samma publikt interna tabellschema som nu.
- Bevara attributets `NA` i `.parse_kandidatresultat_fil_2026()`; ta bort
  `isTRUE()`-kollapsen.
- Ta bort `coalesce(personval_available,FALSE)` och kräv alla relevanta
  områden `TRUE` för en känd negativ status eller ett känt totalantal.
- Dela villkoren för den logiska indikatorn och antalskolumnen:
  ett positivt fynd får sätta indikatorn `TRUE`, men antalet fylls endast när
  total availability är `TRUE`.

Inga nya publika argument eller kolumner behövs.

### 6. Tester som ska läggas till eller ändras

- saknad, null och explicit tom lista på icke-indelat område;
- explicit tom lista med full respektive ofullständig distriktsräkning;
- två valkretsar: båda listor närvarande, båda saknade, samt en närvarande
  och en saknad/null;
- feltypad lista, dublett kandidat/parti och saknade identiteter;
- frånvarande kandidat i komplett lista ger `FALSE`/0;
- frånvarande kandidat i partiell lista ger `NA`/`NA`;
- funnen kandidat i partiell flervalområdessituation ger `TRUE` men
  `antal_personvalsomraden=NA`;
- funnen kandidat i helt komplett flervalområdessituation ger korrekt antal;
- attributet `NA` bevaras genom `.parse_kandidatresultat_fil_2026()` och
  saknad join-status förblir `NA`.

De befintliga testerna för personrösternas availability ska lämnas separata;
personval och personröster representerar olika råstrukturer.

## Måste 3C: mandatens fallbacksummeringar

### 1. Exakt nuvarande beteende

I `parse_mandat_2026()` används samma lokala `sum_int_na()` för sex
områdestotaler när respektive uttryckliga råtotal är saknad/null och därför
blir `NA` efter `as_int_na()`:

| Publik total | Uttrycklig råtotal | Fallback från varje partirad |
| --- | --- | --- |
| `totalt_antal_mandat` | `totaltAntalMandat` | `antalMandat` |
| `totalt_antal_fasta_mandat` | `totaltAntalFastaMandat` | `antalFastaMandat` |
| `totalt_antal_utjamningsmandat` | `totaltAntalUtjamningsMandat` | `antalUtjamningsmandat` |
| `totalt_antal_mandat_fg` | `totaltAntalMandatForegaendeVal` | `antalMandatForegaendeVal` |
| `totalt_antal_fasta_mandat_fg` | `totaltAntalFastaMandatForegaendeVal` | `antalFastaMandatForegaendeVal` |
| `totalt_antal_utjamningsmandat_fg` | `totaltAntalUtjamningsMandatForegaendeVal` | `antalUtjamningsMandatForegaendeVal` |

Hjälparen returnerar `NA_integer_` när vektorn är tom eller alla värden är
`NA`. Annars används `sum(x, na.rm=TRUE)`. Det innebär att varje `NA` blandas
bort så snart minst en partirad är känd.

Ingen total fylls ovillkorligt med 0 i dag. Däremot blir fallbacktotalen 0 om
de kända komponenterna råkar vara noll och minst en annan komponent är
saknad. Med kända komponenter större än noll blir motsvarande delsumman ett
annat felaktigt känt värde.

### 2. Berörda funktioner och filer

- `R/parse_mandat_2026.R`.
- Föreslagen `tests/testthat/test-mandat.R`.
- `R/api_mandat.R` och `man/mandat.Rd` endast för dokumenterad NA-regel och
  eventuella konsistensfel; inga publika kolumner ändras.

### 3. Konkreta felaktiga eller överraskande exempel

Om `totaltAntalMandat` saknas och två partier har `antalMandat = 0` respektive
`null`, blir `totalt_antal_mandat` i dag 0. Nollan påstår att hela mandatantalet
är känt trots att det andra partiets värde saknas.

Om värdena i stället är 3 och `null`, blir totalen 3. Det är en känd delsumma,
inte ett känt områdestotal. Samma problem gäller alla sex rader i tabellen
ovan.

### 4. Önskat beteende och identifiering av ofullständighet

- En uttrycklig giltig råtotal ska bevaras som känd även om någon
  partidetalj saknas. Det är Valmyndighetens officiella total och är inte en
  beräknad fullständighetsutsaga om partidetaljerna.
- Fallback får endast användas när den uttryckliga råtotalen saknas/null.
- Fallbackkomponenterna är kompletta endast om `partiLista` är en explicit
  array och varje relevant partirad har ett giltigt, icke-negativt heltal i
  just det fält som summeras. Ett frånvarande fält, `null`, `NA`, fel typ,
  negativt eller icke-heltal gör fallbacktotalen `NA_integer_`.
- Om inga partirader finns ska totalen vara `NA`, utom när råkällan själv
  uttryckligen publicerar totalen 0.
- Om både en uttrycklig total och fullständiga komponenter finns men summan
  skiljer sig ska detta behandlas som ett källformats-/konsistensfel, inte
  döljas genom att välja en av siffrorna.
- För föregående val ska samma regel användas. `statusJamforelse` ska
  bevaras; om källformatet visar att ej jämförbara områden avsiktligt kan ha
  partiella historiska värden ska totalsumman förbli `NA`, inte en delsumma.

`NA` är rätt representation därför att den okända komponenten kan vara
positiv. Varken 0 eller summan av de synliga värdena identifierar den sanna
totalen.

### 5. Minsta kodändring

Ersätt `sum_int_na()` med en strikt intern hjälpare, exempelvis:

- returnera `NA_integer_` om längden är 0 eller `anyNA(x)`;
- annars summera och verifiera att resultatet ryms i integer;
- använd den endast när motsvarande uttryckliga råtotal är `NA`.

Validera komponenternas heltalskaraktär innan eller i samband med parsningen.
Lägg en liten identitetskontroll där både råtotal och komplett komponentsumma
finns. Ändra inte de sex publika kolumnnamnen och fyll inte andra saknade
mandatfält med noll.

`antal_tomma_stolar` ingår inte i dessa sex fallbacksummeringar. Dess
nuvarande värde kommer direkt från `valda$partiLedamoterLista` eller blir
`NA` efter join. Innan frånvarande partier eventuellt kan tolkas som 0 ska
den betydelsen verifieras genom valda/mandat-identiteten i Måste 3A; ingen
generell `coalesce(antal_tomma_stolar,0L)` ska införas.

### 6. Tester som ska läggas till eller ändras

För var och en av de sex total-/komponentparen, gärna tabellstyrt:

- uttrycklig total bevaras;
- saknad total + alla kända komponenter ger korrekt summa;
- saknad total + `c(0L,NA_integer_)` ger `NA_integer_`, inte 0;
- saknad total + `c(3L,NA_integer_)` ger `NA_integer_`, inte 3;
- alla komponenter saknas ger `NA_integer_`;
- explicit råtotal 0 bevaras som 0 även när ingen fallback kan göras;
- uttrycklig total som avviker från fullständig komponentsumma ger tydligt
  konsistensfel;
- tom/null `partiLista` ger ett stabilt tomt schema och skapar ingen
  artificiell nolltotal.

Lägg ett separat test för `antal_tomma_stolar`: saknad `valda`-struktur ger
`NA`; explicit 0 bevaras; frånvarande parti fylls inte med 0 utan verifierad
källregel.

## Måste 4: slutför det publika datakontraktet

### 1. Exakt nuvarande beteende

`valresultat.Rd` beskriver radnivå, 83 kolumner, typer, upprepade
områdestotaler och centrala NA-regler väl. `kandidater.Rd` beskriver
kandidatnyckeln och personrösternas availability.

Övriga Rd-filer anger bara övergripande returtext. `kandidaturer()` saknar en
exakt raddefinition, `mandat()` saknar per-val-nivåmatris och varning för
upprepade totaler, och `ersattare()` saknar exakt relationsnyckel. Fem av sex
funktioner saknar användningsexempel i Rd.

README utelämnar `lan` trots att KF/`lan` är implementerat. Den säger att
preliminär och slutlig räkning stöds och att 2026-vägar kontrollerats mot
genrepfiler, men skiljer inte uttryckligt fixturetestad preliminär/O från den
verkliga slutliga D/U/M-integrationen. Pakethjälpen nämner inte
`valresultat()` i sin första beskrivning.

### 2. Berörda funktioner och filer

- `README.md`.
- `R/valresultat-package.R`.
- Roxygen i `R/api_valresultat.R`, `R/api_mandat.R`,
  `R/api_kandidaturer.R`, `R/api_kandidater.R` och `R/api_ersattare.R`.
- Genererade `man/valresultat-package.Rd` och de sex funktions-Rd-filerna.
- `DESCRIPTION` för en mer korrekt Description som säger att paketet
  exponerar valresultat, inte bara parsar dem.

### 3. Konkret felaktigt eller överraskande exempel

En README-läsare ser nivåerna `valdistrikt` till `riket`, men inte `lan`, och
kan dra slutsatsen att `valresultat(val="KF",niva="lan")` inte finns. En
användare av `mandat(val="RD")` får både riket och riksdagsvalkretsar utan en
tydlig varning om att samma totalsammanhang förekommer på flera nivåer och
inte ska summeras över nivåerna.

Formuleringen om kontrollerade 2026-vägar kan också läsas som att
preliminära och O-baserade anrop testats mot verkliga filer, vilket inte är
fallet i den spårade integrationen.

### 4. Önskat beteende

Dokumentera följande raddefinitioner och nycklar utan att ändra tabellerna:

- `valresultat`: val × räkning × geografiskt område × parti/kategori; behåll
  nuvarande 83-kolumnbeskrivning.
- `mandat`: val × räkning × geografisk nivå/område × parti, med nyckeln från
  Måste 2. Områdestotaler upprepas på partirader och nivåer ska inte summeras
  tillsammans.
- `kandidaturer`: en källrad för en kandidatur på en valsedel/lista i ett
  valområde och eventuell valkrets. Kandidat kan ha flera rader; ogiltiga
  bevaras. Beskriv identitetsfält som valtyp, område, valkrets, parti,
  listnummer, ordning och kandidatnummer utan att lova en snävare unik nyckel
  än källan verifierats ha.
- `kandidater`: kandidatnummer × valtyp × partikod; förtydliga att
  `resultat=TRUE` läser slutlig räkning och dokumentera 0/FALSE/NA-reglerna
  för personröster, personval och invald efter Måste 3.
- `valda`: exakt samma observationsnivå och schema som resultatkompletterade
  `kandidater()`, filtrerad till explicit `invald==TRUE`; okända kandidater
  finns inte i vyn.
- `ersattare`: en relation mellan vald ledamot och ersättare inom val,
  geografiskt område/valkrets, parti och ersättargrupp. Beskriv
  `ledamot_kandidatnummer`, `ersattare_kandidatnummer` och
  `ersattarordning` som relationsnyckelkomponenter.

Beskriv för varje tabell vilka kolumngrupper som är text, integer, double och
logical, att geografiska fält är strukturellt `NA` utanför sin nivå och att
resultatstatus är `NA` när underlaget inte är verifierat. En fullständig
83-raders ordlista behövs inte för övriga tabeller; en kompakt, exakt
kolumnlista i `@return`/`@section` räcker.

README ska ha en kort matris som skiljer:

- implementerat för preliminär/slutlig D/U/M/O;
- verkligt integrationstestat: endast slutlig D/U/M i de dokumenterade
  lokala filerna;
- inte verifierat mot verklig lokal fil: preliminär och O;
- avsiktligt avstängt: RD/`lan` och RF/`lan`.

### 5. Minsta kod-/dokumentationsändring

- Utöka befintliga roxygenblock; skapa inga nya publika hjälpsidor om samma
  information ryms på funktionssidorna.
- Lägg till KF/`lan` och en kort verifieringsnot i README.
- Lägg till `valresultat()` i paketöversikten.
- Justera `DESCRIPTION`-texten från "parsers for vote results" till att
  paketet tillhandahåller/harmoniserar valresultat.
- Kör roxygen2 och kontrollera att endast avsedda `man/*.Rd` ändras och att
  NAMESPACE:s sex exporter är oförändrade.

### 6. Tester som ska läggas till eller ändras

- Roxygen/check ska verifiera usage, parametrar, korsreferenser och exports.
- Lägg ett lätt statiskt test eller releasekontroll som jämför
  `getNamespaceExports("valresultat")` med de sex avsedda funktionerna.
- Kör README-exemplens argumentkombinationer med mockad/local fixture där de
  kan köras utan nät; visuella textpåståenden granskas manuellt mot den
  frysta källmatrisen.
- Ingen test ska läsa README-exempel från nätet eller kräva `C:/valdata`.

## Måste 5: sätt versionsnumret sist

### 1. Exakt nuvarande beteende

`DESCRIPTION` har `Version: 0.0.0.9000`. Rent bygge, check och installation
identifierar därför paketet som en utvecklingsversion.

### 2. Berörda funktioner och filer

- `DESCRIPTION`.
- Ny `NEWS.md` från Bör 3.
- Byggnamnet ändras automatiskt till `valresultat_0.1.0.tar.gz`.
- Inga R-funktioner eller man-sidor ska behöva ändras för själva bumpen.

### 3. Konkret överraskande exempel

Efter installation från den tänkta releasekällan ger
`packageVersion("valresultat")` fortfarande `0.0.0.9000`, vilket inte kan
identifieras som den utlovade första versionen.

### 4. Önskat beteende

Det slutligt verifierade paketet ska rapportera version `0.1.0`. Bumpen ska
ske efter alla godkända beteende- och dokumentationspatchar så att samma
versionsnummer inte används för flera olika kontrakt.

### 5. Minsta kodändring

Ändra enbart `Version:` i `DESCRIPTION` från `0.0.0.9000` till `0.1.0` när
alla andra releasepunkter är klara. Synkronisera rubriken i `NEWS.md`.

### 6. Tester/kontroller som ska läggas till eller ändras

Ingen permanent enhetstest ska hårdkoda paketversionen. Releasekontrollen ska
i stället:

- bygga ett nytt rent källpaket och kontrollera filnamnet;
- installera det i ett tomt lokalt bibliotek;
- kontrollera `packageVersion("valresultat") == "0.1.0"`;
- kontrollera de sex exporterna och laddning utan `valresultat.data_dir`;
- köra hela testsuiten och `R CMD check --no-manual --no-vignettes`.

## Bör 1: fokuserade publika kontraktstester

### 1. Exakt nuvarande beteende

De 810 befintliga kontrollerna är starka för `valresultat()`, parsers,
lokal source och personröster. `mandat()` saknar offentlig happy-path-test,
`ersattare()` saknar offentlig schema-/nyckeltest och endast
`valresultat()` har ett fryst fullständigt schema-/typkontrakt. Kandidatens
grundnyckel testas, men inte ett fullständigt publikt schema för
`kandidaturer()`, `kandidater()` och `valda()`.

### 2. Berörda funktioner och filer

- Ny `tests/testthat/test-mandat.R`.
- Ny `tests/testthat/test-ersattare.R`.
- `tests/testthat/test-kandidater.R` och `test-local-source.R`.
- Nya små textfiler under `tests/testthat/fixtures/` för frysta schema/typer,
  eller kompakt prototypkod i testhelpers om det blir tydligare.
- `tests/testthat/helper-fixtures.R`.

### 3. Konkret överraskande exempel

En intern ändring kan byta `ersattarordning` från integer till double eller
låta ett tomt `ersattare()`-resultat bli 0 kolumner utan att dagens vanliga
testsvit fallerar. En dubblerad mandatrad kan på samma sätt passera eftersom
ingen publik mandatnyckel testas.

### 4. Önskat beteende

Varje huvudtabell ska ha minst ett test som går genom dess publika funktion
med deterministisk, mockad/local I/O och kontrollerar:

- raddefinitionens nyckel;
- exakt kolumnordning och `typeof()`;
- inga listkolumner;
- ett relevant tomt men känt resultat med samma schema;
- centrala NA/FALSE/0-regler utan att duplicera parserns alla fältkontroller.

### 5. Minsta kodändring

Återanvänd nuvarande fixtures och `local_mocked_bindings()`. Lägg till en
liten mandatfixture och ersättarfixture; skapa inte stora JSON-kopior. Frys
schema i en rad per `namn|typ` såsom `valresultat-schema.txt`, eller med en
gemensam testhelper om tabellerna är korta.

### 6. Tester som ska läggas till eller ändras

- `mandat()`: sex giltiga par, defaults, schema, nyckel och typed empty.
- `kandidaturer()`: källrad inklusive ogiltig kandidatur, schema och typer.
- `kandidater()`: schema med och utan `resultat`, kandidatnyckel och inga
  listkolumner.
- `valda()`: identiskt schema med `kandidater(resultat=TRUE)` och endast
  explicit `TRUE`.
- `ersattare()`: relationsnyckel, typer, tomt schema och flera ersättare till
  samma ledamot.
- Behåll `valresultat()`s befintliga 83-kolumnskontrakt oförändrat.

## Bör 2: bredda integration när filer finns

### 1. Exakt nuvarande beteende

Spårad integration täcker verkliga slutliga D/U/M-filer för RD 00, RF 01 och
KF 0114/0180. Personröst- och kandidatfilspipelinen har testats mot samma
slutliga områden samt kandidat-CSV. Ingen verklig preliminär fil eller O-fil
ingick. Publika `mandat()`, `valda()` och `ersattare()` har ingen separat
redovisad end-to-end-matris.

### 2. Berörda funktioner och filer

- `development/integration-valresultat.R`.
- `development/integration-personroster.R`.
- En liten ny eller utökad `development/integration-release-0.1.0.R` om det
  är enklare att hålla publik API-integration separat.
- `development/VALRESULTAT_INTEGRATION.md` och
  `development/PERSONROSTER_IMPLEMENTATION.md`.
- README:s verifieringsnot.

### 3. Konkret begränsande exempel

`valresultat(val="KF",niva="riket",rakning="slutlig")` är implementerat via
O-parsern och fixturetestat, men ingen slutlig lokal O-KF-fil har lästs i den
redovisade integrationen. Ett verkligt namn- eller null-formatfel kan därför
fortfarande upptäckas först när sådan fil publiceras.

### 4. Önskat beteende

När representativa filer finns ska varje faktisk källklass D/U/M/O provas
minst en gång för båda räkningarna där formatet publiceras. Publika
mandat-/kandidat-/valda-/ersättaranrop ska provas på ett litet urval. Saknade
filer ska markeras som ej integrationstestade, inte ersättas med annan nivå,
räkning eller nätkälla.

### 5. Minsta kodändring

Utöka de befintliga read-only-skripten med tabellstyrda anrop, spärrad
download/archive och MD5 före/efter. Ändra produktionskod endast om ett
observerat fall tydligt strider mot det redan godkända kontraktet; redovisa
annars avvikelsen för nytt beslut.

Denna plan ger inte i sig tillstånd att läsa `C:/valdata` i en senare etapp.
Sådan körning görs endast när användaren uttryckligen anger den åtkomsten.

### 6. Tester/kontroller som ska läggas till eller ändras

För varje tillgänglig fil:

- schema, typer, nyckel och inga listkolumner;
- officiella mandat- och röstsummor;
- source/path och ingen fallback;
- availability för valda, personval och personröster;
- tomt kontra saknat/null;
- MD5 oförändrat och inga nya lokala råfiler.

Integration förblir utanför normal `testthat` och får inte krävas för
installation eller vanlig check.

## Bör 3: release- och projektmetadata

### 1. Exakt nuvarande beteende

`DESCRIPTION` saknar `URL` och `BugReports`. README anger installation från
`richardohrvall/valresultat` och säger att felrapporter är välkomna, men
länken är inte maskinläsbar i paketmetadata. `NEWS.md` saknas.

Git-remoten är verifierad som
`https://github.com/richardohrvall/valresultat.git`.

### 2. Berörda funktioner och filer

- `DESCRIPTION`.
- Ny `NEWS.md`.
- `.Rbuildignore` endast om någon ny utvecklingsartefakt tillkommer; NEWS ska
  ingå i paketbygget och ska inte ignoreras.

### 3. Konkret överraskande exempel

`utils::packageDescription("valresultat")$BugReports` är tomt trots att
README hänvisar användaren till GitHub. En installerad användare har ingen
paketlokal sammanfattning av vad 0.1.0 omfattar.

### 4. Önskat beteende

`DESCRIPTION` ska ange:

- `URL: https://github.com/richardohrvall/valresultat`
- `BugReports: https://github.com/richardohrvall/valresultat/issues`

`NEWS.md` ska kort beskriva de sex exporterade funktionerna,
2026-avgränsningen, lokala/remote källor, availability och att versionen är
experimentell. Den ska skilja implementerat från faktiskt integrationstestat.

### 5. Minsta kodändring

Lägg till de två DESCRIPTION-fälten och en kort `NEWS.md` med rubriken
`valresultat 0.1.0`. Inga runtime-funktioner ändras.

### 6. Tester/kontroller som ska läggas till eller ändras

- `R CMD check` validerar DESCRIPTION och NEWS-format.
- Inspektera det rena tar-arkivet och bekräfta att NEWS ingår.
- Kontrollera efter installation att `packageDescription()` innehåller rätt
  URL/BugReports.
- Ingen nätkontroll av GitHub behöver ingå i testsuiten.

## Bör 4: rätta spårad utvecklingsstatus

### 1. Exakt nuvarande beteende

`development/STATUS.md` säger fortfarande att personröstavailability endast
är ett förslag. `PERSONROSTER_AVAILABILITY.md` och
`PERSONROSTER_IMPLEMENTATION.md` hänvisar till
`PERSONROSTER_INTEGRATION.txt`, men den filen finns inte i repot.
`.gitignore` ignorerar explicit `VALRESULTAT_INTEGRATION.txt` men har ingen
motsvarande regel för personröstloggen.

### 2. Berörda funktioner och filer

- `development/STATUS.md`.
- `development/PERSONROSTER_AVAILABILITY.md`.
- `development/PERSONROSTER_IMPLEMENTATION.md`.
- `.gitignore` endast om en genererad personröstlogg fortsatt ska vara en
  namngiven artefakt.

### 3. Konkret överraskande exempel

En utvecklare följer länken till `PERSONROSTER_INTEGRATION.txt` för att se
körningen men möter en saknad fil, samtidigt som Git-historiken visar att
availability redan är implementerad.

### 4. Önskat beteende

Spårade dokument ska inte beskriva nuvarande status motsägelsefullt. Det ska
vara tydligt vilka filer som är bestående sammanfattningar och vilka loggar
som är genererade/ignorerade.

### 5. Minsta kodändring

Rekommenderad minsta lösning:

- märk `STATUS.md` som historisk status per sitt befintliga datum och lägg en
  kort hänvisning till releasegranskningen, i stället för att skriva om hela
  dokumentet;
- ta bort länken till den saknade personröstloggen och använd den redan
  spårade `PERSONROSTER_IMPLEMENTATION.md` som bestående resultat;
- låt genererade integrationsloggar vara ignorerade konsekvent, exempelvis
  med `development/*_INTEGRATION.txt`, om skripten fortsatt producerar dem.

Ingen produktionskod eller paketdokumentation påverkas.

### 6. Tester/kontroller som ska läggas till eller ändras

Inga enhetstester behövs. Gör i releasekontrollen:

- `rg` efter hänvisningar till saknade filer;
- `git check-ignore` för avsedda genererade loggar;
- bygginspektion som bekräftar att `development/` fortsatt utesluts.

## Bör 5: korta Rd-exempel

### 1. Exakt nuvarande beteende

README har enkla anrop för alla sex exporter. Endast `valresultat.Rd` har ett
eget examples-avsnitt; övriga fem funktionssidor saknar exempel.

### 2. Berörda funktioner och filer

- Roxygenblocken i `R/api_mandat.R`, `R/api_kandidaturer.R`,
  `R/api_kandidater.R` och `R/api_ersattare.R`.
- `valda()`-blocket i `R/api_kandidater.R`.
- Genererade `man/mandat.Rd`, `man/kandidaturer.Rd`, `man/kandidater.Rd`,
  `man/valda.Rd` och `man/ersattare.Rd`.

### 3. Konkret överraskande exempel

Efter installation visar `?ersattare` argument och returtext men inget
kopierbart minsta anrop, trots att README visar `ersattare(val="RD")`.

### 4. Önskat beteende

Varje funktionssida ska ha ett kort exempel med explicit valtyp. Exempel som
kräver Valmyndighetens data ska ligga i `\dontrun{}` och får inte anta
`C:/valdata`. Ett lokalt exempel ska använda en neutral platshållare som
`"mitt_arkiv"`.

### 5. Minsta kod-/dokumentationsändring

Lägg till ett eller två `@examples`-anrop per roxygenblock. Återanvänd README:s
anrop och undvik att dokumentera fler API-detaljer än de frysta kontrakten.
Regenerera Rd; inga funktionskroppar ändras för denna punkt.

### 6. Tester/kontroller som ska läggas till eller ändras

- Kör roxygen2 och `R CMD check --no-manual --no-vignettes`.
- Kontrollera att exemplen parsas och att de nät-/datakrävande anropen inte
  exekveras under check.
- Kontrollera att inga utvecklarspecifika sökvägar förekommer i `R/`, `man/`
  eller README.

## Patchindelning och verifieringsgrindar

Följande patchindelning håller beteendeförändringarna möjliga att granska var
för sig:

1. **Argumentkontrakt:** gemensamma validatorer och endast argumenttester.
2. **Mandatkontrakt:** nivåmatris, paths, typed empty, metadata och nyckel.
3. **Kandidatstatus:** tri-state valda/personval samt flerområdestester.
4. **Mandatsummor:** strikt fallback och identitetstester.
5. **Publika kontraktstester:** schema/typer/nycklar för fem tabeller.
6. **Dokumentation och metadata:** README, roxygen/Rd, DESCRIPTION, NEWS och
   utvecklingsstatus.
7. **Releasegrind:** full testsuite, rent bygge, check och ren installation.
8. **Versionsbump:** `0.1.0`, följd av samma releasegrind en sista gång.

Efter varje produktionspatch körs relevanta deterministiska tester. Efter
patch 4 och framåt körs hela testsuiten. Slutgrinden ska ge 0 errors,
0 warnings och 0 notes och ska inte kräva nätåtkomst eller externa råfiler.
QMD-filen lämnas orörd. Ingen git commit ingår i genomförandet om inte
användaren uttryckligen begär det.
