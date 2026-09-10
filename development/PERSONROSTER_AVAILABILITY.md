# Föreslagen regel för personrösternas tillgänglighet

Regeln har godkänts och implementerats i `R/personroster_availability_2026.R`.
Statusen hålls intern, utan nya publika argument eller kolumner. Underlaget är repots
`references/slut-rostfordelning.md`, daterat 2026-04-17. Beskrivningen anger
fältnamn och typer men definierar inte fullständigt vad utelämnade fält eller
tomma listor betyder. Följande är därför en konservativ paketregel, inte ett
påstående att Valmyndigheten garanterar denna tolkning i alla filer.

## Råstruktur som används

För varje valdistrikt `d` och parti `p`:

```text
valdistrikt[d].rostfordelning.rosterPaverkaMandat.partiRoster[p]
  .partikod
  .antalRoster
  .summeradePersonroster[]
      .kandidatnummer
      .antalPersonroster
  .listRoster[]
      .listnummer
      .antalRosterMedPersonrost
      .personroster[]
          .kandidatNummer
          .antalPersonroster
```

Dessutom används `rakningstillfalle`, `antalValdistriktRaknade`,
`antalValdistriktSomSkaRaknas` och distriktens identiteter för att bedöma täckning.
`rapporteringsTid`, `senasteUppdateringstid`, `test`, partiets röstetal och
mandatfilens personvalskvalificering räcker inte ensamma för att avgöra detta.

## 1. Bevara skillnaden mellan saknat fält, null och []

Bedöm råobjektet före parsning till tabeller. Med befintlig JSON-läsning
(`simplifyVector = FALSE`) är saknat fält respektive JSON-null frånvarande/NULL,
medan JSON-arrayen `[]` blir en tom lista. Kontrollera både fältnamn och värde;
`nrow(personroster_summerade) == 0` får inte användas som tillgänglighetsregel.

## 2. Bedöm distrikt × parti

Prioritera följande fall i denna ordning:

1. **FALSE (underlaget saknas):** Partinoden finns, men
   `summeradePersonroster` är saknad/null och ingen lista innehåller
   en icke-null `personroster` eller `antalRosterMedPersonrost`.
   Enbart förekomsten av `listRoster` visar inte att personröster finns.
2. **NA (oklart/ofullständigt):** Partinoden saknas, strukturen har fel typ,
   summeringen saknas trots personröstinformation på listnivå, eller något av
   nedanstående villkor för TRUE inte är uppfyllt. Ett utelämnat parti tolkas
   inte som ett parti med noll personröster.
3. **TRUE (användbart komplett underlag):** Alla följande villkor är uppfyllda:
   - `summeradePersonroster` är en explicit array, även om den är tom.
   - Varje summerad rad har kandidatnummer och ett icke-saknat, icke-negativt
     heltal `antalPersonroster`; kandidatnummer är unika inom noden.
   - `listRoster` är en explicit array. Varje lista har ett unikt listnummer,
     ett icke-saknat, icke-negativt heltal `antalRosterMedPersonrost` och en
     explicit `personroster`-array. Varje personröstrad har kandidatnummer och
     ett icke-saknat, icke-negativt heltal `antalPersonroster`, utan dubbla
     kandidatrader inom samma lista.
   - Summan av kandidatröster inom varje lista är exakt
     `antalRosterMedPersonrost`. Summering över listor per kandidat stämmer
     exakt med `summeradePersonroster`, där utelämnad kandidat i en i övrigt
     komplett array jämförs som noll. Inga saknade tal tas bort med `na.rm`.

Två uttryckligen tomma arrayer (`listRoster = []` och
`summeradePersonroster = []`) godtas som nollunderlag endast om partiets
`antalRoster` uttryckligen är 0. Med positiva eller saknade partiröster blir
den kombinationen NA: dokumentationen ger inte tillräckligt stöd för att
tolka den som en färdigräknad nolla. Tom summering tillsammans med kompletta
listor med noll personröster kan däremot ge TRUE även vid positiva partiröster.

## 3. Bedöm valområde × parti och kandidatens total

Statusen lagras internt som `personroster_available` per
`valtyp × valomradeskod × partikod`. Ingen ny publik kolumn föreslås.

- Ett förväntat områdes resultatfil saknas eller är oläsbar: NA, inte FALSE.
- En giltig preliminär fil utan personröststrukturer: FALSE. Personröststrukturer
  i en preliminär fil strider mot förväntat format och ger NA.
- En slutlig fil där alla förväntade distrikt/partinoder kan granskas och alla
  har FALSE: FALSE, även om vanlig rösträkning ännu pågår.
- TRUE kräver slutlig räkning, giltiga heltalsräknare med
  `antalValdistriktRaknade == antalValdistriktSomSkaRaknas > 0`, motsvarande
  antal unika distriktsidentiteter utan dubbletter och TRUE för partiet i
  samtliga distrikt. Ett saknat parti i ett distrikt hindrar TRUE.
- Alla andra fall: NA, inklusive blandning av TRUE/FALSE, okänd status,
  ofullständig distriktslista eller pågående räkning med vissa personröster.

Kandidatens relevanta områden hämtas från giltiga kandidaturer. Över dessa
områden används samma trevärdesregel: alla TRUE ger TRUE; alla FALSE ger FALSE;
blandade/okända eller saknade områden ger NA. Saknas relevanta områden blir
status NA, inte ett resultat av `all(logical(0))`.

Vid kandidatstatus TRUE summeras de befintliga summerade personröstraderna;
en kandidat utan rad får `0L`. Vid FALSE eller NA blir totalen `NA_integer_`.
En partiell summa presenteras aldrig som fullständig total.

## Begränsning och nästa verifiering

Regeln är avsiktligt strikt och kan ge NA för användbara filer om källan
utelämnar nollpartier/nolllistor. Den behöver verifieras med små godkända
källrepresentativa exempel, särskilt för uppsamlingsdistrikt, tomma arrayer
och hur distriktsräknarna relaterar till arrayen. Implementations- och
integrationsresultat finns i `PERSONROSTER_IMPLEMENTATION.md` och
`PERSONROSTER_INTEGRATION.txt`. Befintliga filer har där lästs read-only
efter uttryckligt tillstånd.

De deterministiska testerna täcker saknat/null/[] separat, nollröster, saknad kandidat
i komplett data, partiell rapportering, saknat parti, felaktiga tal, dubbla
nycklar samt motsägelser mellan listnivå och summerad nivå.
