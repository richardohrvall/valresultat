# Designförslag: valresultat() för 2026

Status: analys och beslutsunderlag, ingen implementation. Granskad: 2026-09-10.

## Rekommendation

Ett anrop avser **en valtyp, en geografisk nivå och en räkning**. Välj en
förutbestämd officiell huvudkälla för kombinationen. Hämta aldrig distrikt för
att summera fram en nivå som redan har officiella resultat. Komplettera inte
en rad kolumnvis från andra resultatfiler med potentiellt andra tidpunkter.
Överlappande källor används i första hand för validering.

Första versionen bör använda endast officiellt publicerade nivåresultat.
RD per län är analytiskt meningsfullt, men någon direkt länssummering för RD
är inte belagd i de granskade formaten. Jag rekommenderar ett tydligt
"ännu inte stödd"-fel där, tills separat aggregering har beslutats. Detta är
en stödlucka, inte en nonsenskombination.

Ingen av nedanstående rekommendationer ändrar befintliga funktioner.
Personrösternas availability lämnas helt utanför den föreslagna implementationen.

## Underlag och evidensgräns

AGENTS.md lästes först. Analysen bygger på produktionskoden i R/, befintliga
tester och följande lokala formatbeskrivningar:

- `references/prel-rostfordelning.md` och `references/slut-rostfordelning.md`.
- `references/prel-summering-rd-rf.md` och `references/slut-summering-rd-rf.md`.
- `references/prel-overordnad-summering-rf.md` och motsvarande `slut-`-fil.
- `references/prel-overordnad-summering-kf.md` och motsvarande `slut-`-fil.
- `references/prel-mandatfordelning.md` och `references/slut-mandatfordelning.md`.
- `references/index.md5`, som är en lokal genrepsförteckning, inte ett aktuellt
  besked om vilka produktionsfiler som nu är publicerade.

QMD:n användes endast som bakgrund för filurval. Den har inte ändrats.
Efter uttryckligt tillstånd har befintliga filer i `C:/valdata/2026` inventerats
read-only och utvalda JSON-poster lästs direkt ur ZIP i minnet. Inga filer där
har skrivits, extraherats, uppdaterats, arkiverats eller raderats. Inga nya
filer har hämtats. Nedan skiljs faktisk rådata från formatbeskrivningar och
indexposter; en indexpost innebär inte att filen finns lokalt.

### Kontroll av faktisk RD-summering

Inspekterad fil: `C:/valdata/2026/genrep2026/s/rd/Genrep_2026_slutlig_00_RD.zip`,
post `Genrep_2026_slutlig_summering_RD.json` (8 313 208 byte okomprimerad).
Råmetadata anger `Genrep_2026`, `RD`, `slutlig`, uppdateringstid
`2026-09-02T11:10:40` och 6 626 av 6 626 räknade distrikt.

- Rotens enda geografiska samling är `kommuner`: **290 kommuner**.
- Under kommunerna finns sammanlagt **41 kommunvalkretsobjekt**.
- Kommunernas `lankod` omfattar **21 olika koder**, men det finns inga
  länsobjekt med egen `rostfordelning`, ingen `lan[]` och inget `helaLandet`.
- Gotland finns som RD-kommun: `kommunkod = "0980"`, `lankod = "09"`,
  namn `"Region Gotland"`, `totaltAntalRoster = 41190`. Namnet gör inte
  detta till ett RF-resultat.

**Slutsats:** officiell länsnivå finns inte i denna faktiska slutliga
RD-underordnade summering. Länskoder på kommunrader är inte länsresultat.
Dagens U-parser missar alltså ingen länssamling i denna fil. RD/lan bör
fortsatt ge ett tydligt stöd-fel i v1. Egen summering av kommuner vore en
separat härledning som kräver beslut. Ingen preliminär RD-ZIP finns lokalt;
slutsatsen är inte ett bevis om alla preliminära eller framtida 2026-filer.

### RF region kontra län: observationer och kvarvarande jämförelse

Inventeringen under `C:/valdata/2026` hittar fyra resultat-ZIP: RD 00,
RF 01 samt KF 0114 och 0180, samtliga slutliga. Ingen OS_RF-ZIP finns lokalt,
och RF 01 innehåller bara individuell röstfördelning, mandatfördelning och
underordnad summering, med signaturer. Full jämförelse mellan M och O-RF
kan därför **inte genomföras med de tillåtna befintliga filerna**.

Inspekterad RF-post är `Genrep_2026_slutlig_mandatfordelning_01_RF.json` i
`C:/valdata/2026/genrep2026/s/rf/Genrep_2026_slutlig_01_RF.zip`.
Den anger `slutlig`, uppdateringstid `2026-09-02T10:37:51`.

| Kontroll | M: region, faktiskt läst | O-RF: län |
|---|---|---|
| Antal enheter i tillgänglig rådata | 1 valområde | Okänt, fil saknas |
| Kod och namn | `01`, Stockholm | Kan inte jämföras |
| Totalt antal röster | 1 392 488 | Kan inte jämföras |
| Giltiga / ogiltiga röster | 1 371 736 / 20 752 | Kan inte jämföras |
| Individuella partirader | 13 | Kan inte jämföras |
| Övriga partier | Uttryckligt objekt med 0 röster | Kan inte jämföras |
| Räknade / förväntade distrikt | 1 460 / 1 460 | Kan inte jämföras |

Partiernas röster i M/01: `0001=267246`, `0004=90534`, `0003=64171`,
`0068=60553`, `0002=448387`, `0005=73032`, `0055=61489`, `0110=284835`,
`1693=5441`, `1439=4996`, `1718=4320`, `1551=3628`, `1296=3104`.
Summan är 1 371 736 och giltiga + ogiltiga är 1 392 488.

Det lokala `genrep2026/index.md5` listar **20 individuella RF-valområden per
räkning**, med koderna `01, 03, 04, 05, 06, 07, 08, 10, 12, 13, 14, 17,
18, 19, 20, 21, 22, 23, 24, 25`. Kod **09 saknas i både p och s**.
Det belägger ingen RF-mandatfil för Gotland i detta index, men säger inte
om OS innehåller eller utelämnar ett länsobjekt 09. En sådan nods existens,
eventuella null-värden och röster är fortfarande okända. Skapa aldrig ett
RF-resultat för Gotland med nollor utifrån dess RD-/KF-resultat eller namn.

**Rekommendation:** exponera endast RF `region` från M i v1; avstå från
RF `lan` som ytterligare publik vy. M har valområdets tydliga identitet,
mer komplett jämförelseinformation och den relevanta mandatkontexten.
OS-län behövs som kontrollkälla, inte som ett andra nivånamn för ett
sannolikt överlappande resultat. Detta är en designrekommendation, **inte
ett verifierat påstående att alla 20 enheter och röster är identiska**.

Kvar före en empiriskt slutlig redundansbedömning: jämför M och OS från
samma räkning och jämförbar uppdatering/täckning. Räkna unika enheter,
gör anti-joins i båda riktningar på M:s `valomrade.kod` mot OS:s `lankod`,
kontrollera särskilt 09, och jämför partinycklar samt samtliga gemensamma
aktuella antal (inklusive ogiltiga kategorier). Andelar jämförs med
avrundningstolerans. Redovisa saknat separat från noll. Ett preliminärt OS
och slutliga mandatfiler är inte ett giltigt par för ett likhetstest.
Detta steg lämnas öppet tills lämpliga källfiler finns tillgängliga; ingen
nedladdning görs inom denna uppgift.

**Viktig skillnad:** indexet innehåller `p/kf/..._OS_KF.zip` och
`p/rf/..._OS_RF.zip`, men inga motsvarande slutliga OS-filer. Slutliga
överordnade format är ändå beskrivna i referenserna. De slutliga OS-raderna
i matrisen nedan betyder därför "formatstödd, villkorad av publicerad fil",
inte att ett anrop mot just det sparade indexet kan lyckas.

Referenserna har också kopieringsfel: slutliga format använder ibland text
om preliminära rapportpartier; KF-formatets rubrik för `valdeltagande` på
länsnivå har en missvisande beskrivning. Faktiska fältnamn och representativa
fixtures behöver därför verifieras före implementation.

## Källor, läsare och parsers

| Kod | Fil och rånod | Befintlig läsare/parser |
|---|---|---|
| D | Individuell ZIP, JSON `rostfordelning`, `raw$valdistrikt[]` | `read_rostfordelning_zip_2026()` → `parse_rostfordelning_2026()`. Alternativt `read_raw_json_zip_2026(type = "rostfordelning")` → samma parser. |
| U | Underordnad summering i individuell RD/RF-ZIP, `raw$kommuner[]` och `kommunvalkretsar[]` | `read_underordnad_summering_zip_2026()` → `parse_underordnad_summering_2026()`. Läsaren har ett specifikt filnamnsmönster för RD/RF. |
| M | Individuell ZIP, JSON `mandatfordelning`; endast dess `rostfordelning` | `read_raw_json_zip_2026(type = "mandatfordelning")` → `parse_rostfordelning_mandat_2026()`. `parse_mandat_2026()` ska inte användas för röster. |
| O-RF | Separat OS_RF-ZIP; `raw$helaLandet` och `raw$helaLandet$lan[]` | `read_raw_json_zip_2026(type = "summering")` → `parse_overordnad_summering_rf_2026()`, med verifiering av faktiskt JSON-filnamn. Parsern märker länsnoderna som `region`. |
| O-KF | Separat OS_KF-ZIP; `raw$helaLandet`, `raw$helaLandet$lan[]`, dess `kommuner[]` | `read_raw_json_zip_2026(type = "summering")` → `parse_overordnad_summering_kf_2026()`, med samma filnamnsverifiering. |

Alla läsare accepterar lokala filer; eventuell URL ska komma från den gemensamma
datakällehanteringen. M-parsern producerar valområde och valkretsar tillsammans;
U och O producerar också flera nivåer. API:t filtrerar till den efterfrågade
nivån innan tabeller kombineras. Parserns flernivåutdata är inte ett skäl att
exponera flera nivåer i samma API-anrop.

## Kombinationsmatris: 24 nivåval × två räkningar

`p/` respektive `s/` anger preliminär/slutlig ZIP. "Ja" betyder att råformat
och en befintlig parser ger en väg framåt; schemaharmonisering och tester krävs
fortfarande. `Ja*` för OS förutsätter en motsvarande fil i valt index.
Kolumnprofiler G1–G8 och P nedan preciserar innehåll och NA för varje stödd rad.

| val | niva | preliminar källa | slutlig källa | parser | stöds? | kommentar |
|---|---|---|---|---|---|---|
| RD | valdistrikt | p/D, RD:s individuella ZIP | s/D, RD:s individuella ZIP | D | Ja | G1/P. Inkludera uppsamlingsdistrikt med källans identitet och typ. |
| RD | kommun | p/U, `kommuner[]` | s/U, `kommuner[]` | U | Ja | G2/P. Officiella RD-röster per kommun; ingen distriktssummering. |
| RD | kommunvalkrets | p/U, `kommuner[].kommunvalkretsar[]` | s/U, samma nod | U | Ja, där indelning finns | G3/P. Meningsfull geografisk uppdelning av RD-röster, inte RD:s mandatvalkretsar. |
| RD | lan | Ingen direkt källa belagd; möjlig härledning ur U/kommun | Samma lucka | U + ännu ej beslutad aggregering | Nej i v1; meningsfull | G4 kan utformas senare. Summera i så fall officiella kommunrader, inte distrikt. Riksdagsvalkrets är inte generellt samma sak som län. |
| RD | region | — | — | — | Nej | Använd län för administrativ indelning; region är här reserverat för RF:s valområden. |
| RD | regionvalkrets | — | — | — | Nej | Ingen sådan uppdelning av RD belagd i formaten. |
| RD | riksdagsvalkrets | p/M, `valomrade.valkretsLista[]` | s/M, samma nod | M | Ja | G7/P. Officiella kretsröster; tillhör RD-valområdet riket. |
| RD | riket | p/M, `valomrade` | s/M, `valomrade` | M | Ja | G8/P. Officiellt resultat för ett enda RD-valområde. |
| RF | valdistrikt | p/D, individuella RF-ZIP | s/D, individuella RF-ZIP | D | Ja | G1/P. RF-områden väljs från index, inte från alla länskoder. |
| RF | kommun | p/U, `kommuner[]` | s/U, samma nod | U | Ja | G2/P. Föredras framför kommunernas enklare röstnoder i O-RF. |
| RF | kommunvalkrets | p/U, `kommuner[].kommunvalkretsar[]` | s/U, samma nod | U | Ja, där indelning finns | G3/P. Kommunvalkrets är en geografisk redovisning här, inte regionvalkrets. |
| RF | lan | O-RF:s länsnoder är möjlig kontrollkälla | Samma format, ingen s/OS i sparat index | O-RF, endast kontroll | Nej i föreslagen v1 | Hänvisa till region/M. Redundans sannolik men faktisk likhet, inklusive Gotland, återstår att kontrollera. |
| RF | region | p/M, `valomrade` | s/M, `valomrade` | M | Ja | G5/P. M prioriteras framför O-RF för valområdets resultat, jämförelser och mandatbehörighet. |
| RF | regionvalkrets | p/M, `valomrade.valkretsLista[]` | s/M, samma nod | M | Ja, där indelning finns | G6/P. Officiell valkretsindelning i regionvalet. |
| RF | riksdagsvalkrets | — | — | — | Nej | Fel valkretsindelning för RF; ingen officiell sådan källa belagd. |
| RF | riket | p/O-RF, `helaLandet` | s/O-RF, samma nod | O-RF | Ja* | G8/P. Officiell summering av flera regionval, ingen nationell RF-mandatfördelning. |
| KF | valdistrikt | p/D, individuella KF-ZIP | s/D, individuella KF-ZIP | D | Ja | G1/P. Samtliga kommunval i indexet. |
| KF | kommun | p/M, `valomrade` | s/M, `valomrade` | M | Ja | G2/P. M prioriteras framför O-KF:s kommunrader; mer komplett områdeskontext och jämförelsedata. |
| KF | kommunvalkrets | p/M, `valomrade.valkretsLista[]` | s/M, samma nod | M | Ja, där indelning finns | G3/P. Tillhörande kommun måste ingå i identiteten. Ingen U-källa för KF är dokumenterad. |
| KF | lan | p/O-KF, `helaLandet.lan[]` | s/O-KF, samma nod | O-KF | Ja* | G4/P. Officiell sammanräkning av kommunval inom länet. |
| KF | region | — | — | — | Nej | Kommunval på administrativ mellannivå redovisas som län, inte som ett RF-valområde. |
| KF | regionvalkrets | — | — | — | Nej | Ingen officiell sådan KF-uppdelning belagd; hör till RF. |
| KF | riksdagsvalkrets | — | — | — | Nej | Ingen officiell sådan KF-uppdelning belagd; hör till RD. |
| KF | riket | p/O-KF, `helaLandet` | s/O-KF, samma nod | O-KF | Ja* | G8/P. Officiell summering av kommunval, ingen gemensam nationell valområdesspärr. |

### Län kontra region

RF använder `region` (valområde, M). `lan` avvisas i det föreslagna API:t
med hänvisning till `region`, utan att tyst byta källa eller nivå. Detta är
en avgränsning av publika vyer, inte en bedömning att OS:s länsnoder är
nonsens. Motivering och begränsningen i rådatajämförelsen finns ovan.

För RD/region och KF/region ska felmeddelandet hänvisa till län, inte hävda
att en sådan geografisk summering är omöjlig i princip. RF täcker inte
automatiskt alla områden som finns i RD/KF; indexet saknar exempelvis RF 09.
Skapa inte ett saknat RF-val med nollröster.

### Områden utan valkretsindelning

Skapa inte en syntetisk kommun-/regionvalkrets av hela valområdet. Returnera
bara faktiskt redovisade kretsar. En dokumenterad frånvaro av kretsindelning
är inte en saknad fil. Om kretsen finns men dess `rostfordelning` är null
är resultatet däremot otillgängligt, inte noll. Sådana luckor ska identifieras
före parsning och ge ett tydligt fel i v1, så att ofullständig leverans inte
ser ut som en fullständig tabell. Rapporteringstal får fortfarande visa att
själva rösträkningen inom ett publicerat resultat pågår.

## Källprioritet och överlapp

1. **Individuell D:** endast distriktsresultat; inga konkurrerande distrikts-
   noder är belagda i övriga lästa format.
2. **RD/RF kommun och kommunvalkrets:** U. O-RF innehåller enligt referensen
   även kommunernas röstnoder, men dagens O-RF-parser läser inte dem. U ger
   uttrycklig kommun-/kretskontext, rapportering och jämförelser. Utvidgning
   av O-RF till kommuner behövs alltså inte för denna huvudkälla.
3. **RD riket/riksdagsvalkrets, RF region/regionvalkrets, KF kommun/kommunvalkrets:**
   M:s röstnoder. Att filen heter mandatfördelning ändrar inte att röstetalen
   är officiella nivåresultat. Röster kräver inte att `mandatfordelning` eller
   `valda` är färdigställda. Dessa extra strukturer ska inte läsas in här.
4. **RF riket, KF riket/län:** respektive O. Använd inte summering av
   underliggande M- eller D-tabeller bara för att det är enklare.
5. **Överlapp KF kommun:** O-KF:s kommunnoder har endast namn, kod och
   röstfördelning i beskrivningen; föregående/förändring saknas på den nivån.
   M ger dessutom områdets totalsiffror, röstberättigade, deltagande, rapportering
   och spärrinformation. O-KF är en kontrollkälla, inte en radvis reservkälla.
6. **Överlapp RF region/län:** O-RF:s läns-röstfördelning saknar enligt
   referensen föregående/förändring även om områdesobjektet har vissa sådana
   totalsiffror. M är därför primär för `region`.

I v1 rekommenderas **ingen automatisk fallback** till en annan filtyp eller
räkning när primärkällan saknas. Ett sådant byte skulle kunna ändra
kolumntäckning, tidpunkt eller populationsomfattning. Ge i stället ett fel
som anger saknad källa och vald kombination. Eventuell framtida fallback
behöver en separat fastställd regel och synlig proveniens.

## Filval och intern arbetsgång

1. Validera samtliga argument och kombinationen före IO.
2. Läs `index.md5` en gång via `.read_resultatindex_2026()` och använd
   `.resultatsamling_2026()`; hårdkoda inte `genrep2026` i ny kod.
3. Välj räkningens prefix `p`/`s` och en disjunkt filklass. Föreslagna
   indexmönster, där `<p>` är valt prefix och filnamnsprefix hämtas ur index:

   ```text
   RD individuell: ^<p>/rd/[^/]+_00_RD\.zip$
   RF individuell: ^<p>/rf/[^/]+_[0-9]{2}_RF\.zip$
   KF individuell: ^<p>/kf/[^/]+_[0-9]{4}_KF\.zip$
   RF överordnad:  ^<p>/rf/[^/]+_OS_RF\.zip$
   KF överordnad:  ^<p>/kf/[^/]+_OS_KF\.zip$
   ```

   Verifiera dessutom att filens räkning och valtyp stämmer med råmetadata.
   Behåll strikt separat urval för OS; använd inte `.*_RF.zip` som generell
   RF-matchning. Dubbletter per förväntad filidentitet ger fel.
4. Hämta/lokalisera varje vald ZIP en gång med `.resultat_file_2026()` eller
   `.resolve_val_file()`. D/U/M kan finnas i samma ZIP; välj endast behövd
   JSON. Läsaren ska hitta exakt en fil av rätt typ och rätt val/räkning.
5. Kontrollera förväntad rotstruktur, tillgängliga områden och matchande
   metadata; anropa befintlig parser, filtrera nivå, harmonisera schema.
6. Kombinera tabeller på samma nivå, kontrollera nyckel och typer och sortera
   deterministiskt efter geografisk identitet och parti/kategori.

`.resultat_paths_2026()` är idag avsiktligt slutlig och används för kandidater;
ändra inte dess argumentbetydelse tyst. Ny intern urvalslogik kan byggas vid
implementationen, eller en separat generell hjälpare återanvändas där
befintliga anrop behåller sitt beteende.

## Resultatschema och NA-regler

En rad är fortsatt val × geografiskt område × parti/kategori. Areaegenskaper
upprepas på partiraderna. Samma förutbestämda kolumnnamn, ordning och typer
ska användas för båda räkningarna och samtliga stödda nivåer. Basera kontraktet
på unionen av befintliga parserkolumner; inga mandat, kandidater, personröster
eller föregående-distriktslistor ska byggas in i resultattabellen.

### P: exakt kolumnkontrakt (83 kolumner)

Kolumnordningen är tabell A:s 40 rader, därefter tabell B:s 14 aktuella
kolumner uppifrån ned, dess 14 föregående-kolumner, dess 14 differenskolumner
och sist `status_jamforelse` (character, från områdets `statusJamforelse`,
NA om saknat). Inga andra kolumner eller listkolumner. Även en tillåten tom
tabell har dessa 83 kolumner med samma typer.

Generell regel: frånvarande eller JSON-null skalär blir `NA_character_`,
`NA_integer_`, `NA_real_` respektive logisk `NA`. Noll och FALSE behålls
endast när källan eller kategoriregeln uttryckligen ger dem. Fel struktur
eller oförenlig typ är ett källfel, inte ett värde att tyst omvandla till NA.
Saknad obligatorisk val-/områdes-/partiidentitet ger fel före leverans.
Datum och tidsstämplar förblir character med källans representation;
inga nya Date-/POSIXct-typer eller tidszonsantaganden.

**Tabell A. Val, rapportering, geografi, parti och spärr.**

| Kolumn | R-typ | Källa och NA-regel |
|---|---|---|
| `valtillfalle` | character | Rotens fält; obligatorisk identitet. |
| `valklass` | character | Rotens fält; NA om saknat. |
| `rakningstillfalle` | character | Rotens räkning; obligatorisk och ska motsvara anropet. |
| `valtyp` | character | Rotens valtyp; obligatorisk och ska motsvara anropet. |
| `valdatum` | character | Rotens fält; NA om saknat, fyll inte från argumentets år. |
| `valdatum_fg` | character | Rotens `tidigareValdatum`; NA om saknat. |
| `test` | logical | Rotens fält; saknat är NA, inte FALSE. |
| `senaste_uppdateringstid` | character | Rotens `senasteUppdateringstid`; NA om saknat. |
| `antal_uppdateringar` | integer | Rotens `antalUppdateringar`; NA om saknat. |
| `antal_valdistrikt_raknade` | integer | Filpopulationens `antalValdistriktRaknade`: rot i D/U/O, `valomrade` i M; NA om saknat. |
| `antal_valdistrikt_som_ska_raknas` | integer | Samma population, `antalValdistriktSomSkaRaknas`; NA om saknat. |
| `rapporteringstid` | character | D/M: radnodens `rapporteringsTid`; U/O: `senasteRapporteringstid`; NA om saknat. |
| `senaste_uppdateringstid_omrade` | character | U-nodens `senasteUppdateringstid`; NA i D/M/O. |
| `antal_valdistrikt_raknade_omrade` | integer | U/O/M: radnodens `antalValdistriktRaknade`; NA i D eller om saknat. |
| `antal_valdistrikt_som_ska_raknas_omrade` | integer | U/O/M: radnodens `antalValdistriktSomSkaRaknas`; NA i D eller om saknat. |
| `antal_rostberattigade_raknade` | integer | U/O/M: radnodens `antalRostberattigadeIRaknadeValdistrikt`; NA i D eller om saknat. |
| `geografiniva` | character | Den enda efterfrågade nivån efter upplösning av NULL; aldrig NA. |
| `valdistriktsnamn` | character | D: `namn`; annars NA. |
| `valdistriktstyp` | character | D: `valdistriktstyp`; annars NA. |
| `valdistriktskod` | character | D: `valdistriktskod`; obligatorisk på distriktsrad, annars NA. |
| `kommunkod` | character | D/U: kommunidentitet i källan; KF M: valområdets kod; annars NA. |
| `kommunnamn` | character | U: kommunens namn (också på dess kretsar); KF M: valområdets namn; annars NA. |
| `lankod` | character | D/U: explicit länskod; O-KF län: `lankod`; KF M: första två tecknen i valområdets fyrsiffriga kommunkod; annars NA. |
| `lannamn` | character | O-KF län: länsnodens `namn`; annars NA. |
| `valomradeskod` | character | D: explicit kod; U: validerad individuell ZIP-identitet; M: `valomrade.kod`; O: NA. |
| `valomradesnamn` | character | M: `valomrade.namn`; annars NA. |
| `kretskod` | character | Endast D:s uttryckliga `kretskod`; annars NA. Ingen automatisk likställning med `valkretskod`. |
| `valkretskod` | character | M-krets: `kod`; annars NA. |
| `valkretsnamn` | character | M-krets: `namnValkrets`; annars NA. |
| `kommunvalkretskod` | character | D: `kommunvalkretsKod`; U-krets: `kod`; KF M-krets: `kod`; annars NA. |
| `kommunvalkretsnamn` | character | D: `kommunvalkretsNamn`; U-krets: `namn`; KF M-krets: `namnValkrets`; annars NA. |
| `partibeteckning` | character | Enskilt parti: källfält, NA om saknat; övriga-kategori: `"Övriga partier"`. |
| `partiforkortning` | character | Enskilt parti: källfält; NA om saknat och för övriga. |
| `partikod` | character | Enskilt parti: obligatoriskt källfält; NA för övriga. |
| `fargkod` | character | Enskilt parti: källfält; NA om saknat och för övriga. |
| `ordningsnummer` | integer | Enskilt parti: källfält; NA om saknat och för övriga. |
| `ovriga_partier` | logical | FALSE för faktisk `partiRoster`-rad, TRUE för faktisk övriga-nod; aldrig NA. |
| `over_sparr` | logical | Endast relevant uttryckligt M-besked på den aktuella nodens partirad; annars NA, även för övriga. |
| `valomradessparr_procent` | double | M: `valomrade.valomradessparrProcent`; annars NA. Upprepad valområdeskontext även på kretsrader. |
| `valkretssparr_procent` | double | M: `valomrade.valkretssparrProcent`; annars NA. Källans kontextfält, inget automatiskt besked om radpartiets behörighet. |

RF M får alltså `lankod = NA` i v1. En identitetsmappning till län ska inte
införas innan den har verifierats och beslutats; valområdeskoden räcker för
RF:s identitet. För U-kretsar ärvs kommunens kod, namn och länskod. O-RF:s
länsrader och O-KF:s kommunrader är endast jämförelsekällor och returneras
inte via de valda publika rutterna. Adaptern fyller inte luckor från dem.

**Tabell B. Samtliga 42 resultatkolumner.** Typen på varje rad gäller alla
tre namngivna kolumnerna. Antal är integer; andelar är procent som double,
med differenser i procentenheter. Alla saknade värden blir typad NA.

| Aktuell kolumn | Föregående val | Förändring | R-typ |
|---|---|---|---|
| `antal_roster` | `antal_roster_fg` | `diff_antal_roster` | integer |
| `andel_roster` | `andel_roster_fg` | `diff_andel_roster` | double |
| `totalt_antal_roster` | `totalt_antal_roster_fg` | `diff_totalt_antal_roster` | integer |
| `antal_rostberattigade` | `antal_rostberattigade_fg` | `diff_antal_rostberattigade` | integer |
| `valdel` | `valdel_fg` | `diff_valdel` | double |
| `giltiga_roster` | `giltiga_roster_fg` | `diff_giltiga_roster` | integer |
| `ogiltiga_roster` | `ogiltiga_roster_fg` | `diff_ogiltiga_roster` | integer |
| `andel_ogiltiga` | `andel_ogiltiga_fg` | `diff_andel_ogiltiga` | double |
| `roster_ej_anmalt_deltagande` | `roster_ej_anmalt_deltagande_fg` | `diff_roster_ej_anmalt_deltagande` | integer |
| `andel_ej_anmalt_deltagande` | `andel_ej_anmalt_deltagande_fg` | `diff_andel_ej_anmalt_deltagande` | double |
| `blanka_roster` | `blanka_roster_fg` | `diff_blanka_roster` | integer |
| `andel_blanka` | `andel_blanka_fg` | `diff_andel_blanka` | double |
| `ovriga_ogiltiga` | `ovriga_ogiltiga_fg` | `diff_ovriga_ogiltiga` | integer |
| `andel_ovriga_ogiltiga` | `andel_ovriga_ogiltiga_fg` | `diff_andel_ovriga_ogiltiga` | double |

De första två måtten kommer från partiraden eller övriga-noden. Totalt
antal röster, röstberättigade och deltagande kommer från radens område;
D använder `valdeltagandeVallokal` för aktuell `valdel`, övriga källor
`valdeltagande`. Giltiga kommer från `rosterPaverkaMandat`; ogiltiga och
dess tre underkategorier från `rosterEjPaverkaMandat`. Därmed upprepas
områdestotaler men inte andra partiers röster på varje partirad.

Historik och differenser hämtas fältvis från motsvarande
`...ForegaendeVal`/`forandring...` i samma rånod enligt befintlig parser.
Saknad historik/differens för ett mått släcker endast just den kolumnen.
Inga egna differenser eller andelar beräknas. Undantaget för O:s befintliga
totalfallback (giltiga + ogiltiga inom samma nod) preciseras nedan.
Ogiltiga underkategorier utan källvärde är NA även om totalen är känd.

### När en övriga-rad finns

Regeln tillämpas på varje resultatnod före eller med rånärvaroinformation
vid schemaanpassningen, likadant i D/U/M/O och båda räkningarna:

1. `rosterOvrigaPartier` saknas eller är JSON-null: **ingen övriga-rad**.
2. Ett objekt med dokumenterade röstfält finns: exakt en övriga-rad.
   Ett uttryckligt 0 behålls. Saknade/null enskilda mått blir NA, inte 0.
   Även en källkategori vars dokumenterade fält alla är null behålls som
   okänd, eftersom den faktiskt deklarerats; den uppfinns inte av parsern.
3. Ett tomt objekt utan något dokumenterat röstfält eller fel nodtyp är
   ett schemafel som ska rapporteras; skapa inte en tom partirad därifrån.

Använd aldrig en regel som tar bort alla nollrader eller alla NA-rader.
Stockholms RF M har faktiskt `rosterOvrigaPartier` med 0 och ska därför
behålla kategorin. Saknad kategori innebär däremot inte ett påstående om
antalet röster i partier som inte redovisas individuellt. Röstidentiteter
måste kontrolleras mot vad källans kategorier faktiskt täcker.

Historik och differenser är inte generellt otillgängliga för preliminärt
resultat. Inte heller innebär "slutlig" att varje resultatfält måste vara
ifyllt. Räkningstillfälle och färdigställande/täckning är olika saker.

### G1–G8: geografisk identitet och strukturella NA

Behåll `valkretskod` och `kretskod` som befintliga kolumner tills en särskild
namnharmonisering har godkänts. De får inte slås ihop enbart för att namnen
liknar varandra. För KF kommunvalkrets föreslås att adaptern också fyller de
redan etablerade `kommunvalkretskod`/`kommunvalkretsnamn` från M-kretsens
kod/namn, samtidigt som M:s generiska kretskolumner bevaras. Detta är en
föreslagen schemaanpassning, ännu inte genomförd.

| Profil/nivå | Identitet och kolumner som kan fyllas | Kolumner som normalt ska vara NA |
|---|---|---|
| G1 valdistrikt | `valdistriktskod`, `valdistriktsnamn`, `valdistriktstyp`, `kommunkod`, `lankod`, `valomradeskod`, `kretskod`, samt `kommunvalkretskod`/`kommunvalkretsnamn` där rådata har dem | Namn på kommun/län/valområde och generiska M-kretskolumner är NA. `antal_rostberattigade` och `valdel` är NA för uppsamlingsdistrikt enligt formatet. |
| G2 kommun | `kommunkod`, `kommunnamn`, `lankod` när U ger dem; för KF M även `valomradeskod`/`valomradesnamn`, med deterministisk kopiering till kommunidentiteten | Distrikts- och kretskolumner. RD U:s valområdeskod kan härledas från RD-ZIP:s identitet; RF U:s från RF-ZIP:s identitet. Länsnamn lämnas NA om det inte finns i vald källa. |
| G3 kommunvalkrets | Kombinationen `kommunkod + kommunvalkretskod`, respektive namn från U eller KF M. För KF M även generisk `valkretskod`/`valkretsnamn` och valområdesidentitet | Distriktskolumner; RD/RF:s mandatkrets kan inte väljas godtyckligt från en geografisk kommunvalkrets. U:s generiska `valkretskod` lämnas därför NA. |
| G4 lan (KF) | `lankod`, `lannamn` från OS | Kommun-, kommunvalkrets-, distrikts- och mandatvalkretskolumner. Inget enskilt KF-valområde på länsrad; `valomradeskod`/`valomradesnamn` lämnas NA. RF/lan exponeras inte. |
| G5 region (RF) | `valomradeskod`, `valomradesnamn` från M | Kommun-, kommunvalkrets-, distrikts- och valkretskolumner samt länskod/-namn är NA. |
| G6 regionvalkrets | `valomradeskod + valkretskod`, respektive namn från M | Kommun-/kommunvalkrets-/distriktsidentiteter; källan utpekar ingen unik kommun. |
| G7 riksdagsvalkrets | RD-valområdets identitet samt `valkretskod`, `valkretsnamn` från M | Kommun-/kommunvalkrets-/distriktsidentiteter. `lankod`/`lannamn` fylls inte genom att anta att län = riksdagsvalkrets. |
| G8 riket | `geografiniva = "riket"`; RD M har `valomradeskod = "00"` och namn från källan | Alla underordnade geografier. RF/KF OS-riket är inte ett enskilt valområde: valområdesidentiteten lämnas NA, inte en påhittad kod. |

Geografiska identiteter ska alltid vara character så inledande nollor bevaras.
Ingen geografisk namnuppslagning utanför vald källa behövs i v1. En adapter
kan använda explicit filidentitet där den entydigt anger valområdet, men ska
inte gissa distrikts-/kretskorsningar. På KF M-rader härleds länskoden ur
de första två tecknen i den validerade fyrsiffriga kommunkoden enligt tabell A;
samma föräldrakod används på kommunvalkretsrader.

### Rapportering: en befintlig semantisk skillnad måste lösas

D och U/O fyller idag `antal_valdistrikt_raknade` och
`antal_valdistrikt_som_ska_raknas` från filens rot. U/O har dessutom
`*_omrade` från radens områdesobjekt. M fyller de första namnen från
radens område/valkrets. En blind `bind_rows()` ger alltså samma kolumnnamn
olika omfattning beroende på parser.

Föreslagen regel för det nya API:t, utan ändring av befintliga parsers:

- `antal_valdistrikt_raknade` och `antal_valdistrikt_som_ska_raknas` avser
  alltid filens övergripande resultatpopulation: rot i D/U/O, valområdet i M.
- `antal_valdistrikt_raknade_omrade` och `antal_valdistrikt_som_ska_raknas_omrade`
  avser den returnerade områdesraden: U/O:s nod eller M:s område/valkrets.
  D saknar motsvarande explicit distriktsräknare per distrikt: NA, inte
  en påhittad 0/1 utifrån tidsstämpeln.
- `senaste_uppdateringstid` och `antal_uppdateringar` är filmetadata.
  `rapporteringstid` är områdets/distriktets rapporteringstid.
  `senaste_uppdateringstid_omrade` fylls där U har den; annars NA.
- `antal_rostberattigade_raknade` fylls från områdets uttryckliga fält;
  D har inte detta fält i den granskade beskrivningen och får NA.

Denna adapterregel behöver godkännas som del av API-kontraktet. Den ändrar
inte dagens parserresultat men gör omfattningen konsekvent i `valresultat()`.

### Källspecifika kolumnluckor

- D: `valdel` kommer från `valdeltagandeVallokal`. U/O/M använder
  `valdeltagande`. Dokumentera skillnaden och använd inte en generell
  kontroll `valdel == röster / alla röstberättigade` för alla rader.
- U: områdeskontext, aktuell/historisk röstfördelning och differenser är
  dokumenterade för kommun och kommunvalkrets i båda räkningarna.
- M: samma grundläggande röstschema för valområde/valkrets i båda räkningarna;
  en krets `rostfordelning` kan vara null. Spärrfält finns här, inte i D/U/O.
- O-RF län: röstfördelningens `_fg` och `diff_` saknas enligt både preliminär
  och slutlig referens. Behåll dock de historiska områdestotaler som faktiskt
  publiceras på själva länsobjektet. Detta motiverar M-prioritet för region.
- O-RF kommun: enklare nod, inte läst av dagens parser. Ingen anledning att
  ersätta U med denna för kommunresultatet.
- O-KF kommun: röstfördelningens historik/differenser saknas i båda
  formatbeskrivningarna. Områdesfält som deltagande/rapportering saknas
  också i kommunnodens uppräkning. Den befintliga parsern ger då NA, med
  undantag för sin härledning av totalt antal röster ur giltiga + ogiltiga.
- O-KF: slutreferensen anger null för `antalRosterForegaendeVal` och
  `forandringAntalRoster` under `rosterPaverkaMandat`. Fyll därför inte
  `giltiga_roster_fg`/`diff_giltiga_roster` genom egen rekonstruktion.
  Andra historiska fält kan fortfarande finnas; slå inte ut hela historikgruppen.
- O-RF/O-KF: parsern har redan en fallback för `totalt_antal_roster = giltiga +
  ogiltiga` när explicit total saknas. Detta är en identitet inom samma nod,
  inte geografisk aggregering. Bevara beteendet och testa att saknat deltal
  ger NA, inte en ofullständig totalsumma.

## over_sparr

**Rekommendation: ta med `over_sparr` som logical i det gemensamma schemat**, men
fyll den endast från `deltaMandatfordelning` i M på nivåer där mandatbehörighet
har en definierad omfattning. Den granskade referensen beskriver fältet som
"över spärren i valområdet eller valkretsen"; befintlig parser mappar
`ja`/`nej` till TRUE/FALSE och saknat/okänt till NA.

| Kombination | Tolkning och regel |
|---|---|
| RD riket | Källans behörighet på nationell valområdesnivå. Tolka inte FALSE som bevis att partiet saknar möjlighet till mandat i varje enskild krets. |
| RD riksdagsvalkrets | Källans behörighet för kretsens mandatfördelning. Inte en egenberäknad indikator `andel_roster >= 12`; den nationella behörigheten kan också ha betydelse. |
| RF region, KF kommun | Källans valområdesbehörighet. Spärrprocent hämtas från källan, inte hårdkodade lagregler. |
| RF regionvalkrets, KF kommunvalkrets | Källans behörighet i denna mandatkontext, om flaggan uttryckligen finns. Det betyder inte att en självständig procentgräns gäller just i kretsen. Kopiera inte en områdesflagga till en saknad kretsflagga. |
| Alla D/U-nivåer samt RF/KF OS-riket och OS-län | NA. En geografisk redovisning eller summering över flera val är inte en gemensam mandatspärr. |
| Aggregerade övriga partier | NA, även om någon ingående part kan passera en spärr. |

Bevara `rakningstillfalle`: ett preliminärt TRUE är ett preliminärt
källbesked, inte ett fastställt slutresultat. Fältnamnet bör dokumenteras som
"källans besked om behörighet för mandatfördelning på aktuell nivå".
Om källfixtures visar att kretsflaggan har en annan betydelse behöver just
den tolkningen klarläggas innan den exponeras; räkna inte fram en ersättning.

## Rekommenderat publikt gränssnitt

```r
valresultat(
  ar = 2026,
  val = "RD",
  rakning = c("slutlig", "preliminar"),
  niva = NULL,
  source = c("auto", "local", "remote"),
  data_dir = NULL,
  update = FALSE,
  archive = FALSE,
  progress = interactive()
)
```

- `ar`: ett giltigt skalärt år; endast 2026 stöds i v1.
- `val`: exakt en av RD/RF/KF; små bokstäver kan normaliseras som i övriga
  funktioner. **Inte NULL och inte en vektor med flera valtyper.** Default RD
  ger ett tydligt, begränsat standardanrop. Kandidatfunktionernas NULL-default
  behöver inte kopieras till en resultattabell med olika möjliga nivåer.
- `niva`: NULL (default) eller exakt en nivå ur matrisen; ingen flernivåvektor.
  NULL löses deterministiskt efter valvalidering och före IO: RD → `riket`,
  RF → `region`, KF → `kommun`. Det betyder valets naturliga huvudnivå,
  aldrig alla nivåer eller den nivå som råkar vara tillgänglig. Flera val
  eller nivåer hämtas i separata anrop.
- `rakning`: en räkning; samma argumentnamn och standardordning som `mandat()`.
  Default är slutlig. Saknas slutlig källa ges fel; inget automatiskt byte
  till preliminär. Ingen `auto` eller `bada` för räkning i v1.
- `source`: befintlig semantik via samma filhjälpare. Local använder aldrig
  nätet; local + update TRUE ger tidigt fel; local + archive TRUE kopierar
  endast redan befintlig lokal fil. Auto/remote med uppdaterings-/arkivflaggor
  ska följa befintlig `.resolve_val_file()` exakt, inklusive dess krav på
  lokal mapp. Denna nya funktion ska inte ändra andra API:ers semantik.
- `data_dir`: explicit argument före optionen `valresultat.data_dir`.
- `update = FALSE`, `archive = FALSE`: bevara dagens arbetskopior respektive
  avsiktlig ersättning av samma dags snapshot. Arkivera bara index och de
  källfiler som anropet faktiskt använder.
- `progress = interactive()`: indikator över de ZIP-filer som ska läsas,
  avstängningsbar i tester. Ingen ny export eller ny option behövs för detta.

### Varför NULL bör ersätta distriktsdefault

| Default | Fördel | Nackdel |
|---|---|---|
| `niva = "valdistrikt"` | Samma uttryckliga geografiska nivå för alla val; bra för detaljanalyser. | Standardanrop läser stora distriktsfiler och levererar en detaljnivå som ofta kräver vidare bearbetning. |
| `niva = NULL` | Ger direkt valområdenas officiella resultat från M: ett RD-riksresultat, RF-regionerna respektive KF-kommunerna. Följer valets naturliga analysnivå. | Den geografiska nivån beror på `val` och måste dokumenteras tydligt. RF/KF kan fortfarande kräva många individuella ZIP-filer. |

**Rekommendation: NULL.** Ett anrop returnerar fortfarande en enda nivå,
men kan innehålla flera enheter på den nivån. `valresultat()` motsvarar
uttryckligen `valresultat(val = "RD", niva = "riket")`; RF och KF med NULL
motsvarar explicit region respektive kommun. `character(0)`, NA och flera
nivåer ger fel; de är inte alternativa stavningar av NULL. Valtyp NULL
ger fortsatt fel. Ingen fallback när den naturliga huvudkällan saknas.

Felet ska skilja mellan ogiltigt nivånamn, otillåten kombination, ännu ej
stödd men meningsfull kombination (RD/län), saknad publicerad källa och saknad
lokal fil. Tyst bortfiltrering till en tom tabell är inte acceptabelt för
ett ogiltigt anrop. En verifierat tom mängd faktiskt existerande kretsar kan
däremot representeras med en typad tom tabell.

## Identiteter och konsistenskontroller

### Nyckel

Gemensam del: `valtillfalle + valtyp + rakningstillfalle + geografiniva`.
Till detta läggs nedanstående områdesidentitet och `partikod + ovriga_partier`:

| Nivå | Områdesidentitet |
|---|---|
| valdistrikt | `valomradeskod + kommunkod + valdistriktskod + valdistriktstyp`; pröva och dokumentera behovet av typ för uppsamlingsdistrikt mot fixtures |
| kommun | `kommunkod` |
| kommunvalkrets | `kommunkod + kommunvalkretskod` |
| lan | `lankod` |
| region | `valomradeskod` |
| regionvalkrets/riksdagsvalkrets | `valomradeskod + valkretskod` |
| riket | konstant rikets identitet inom valtyp/räkning; kräver inte påhittat valområde för RF/KF |

Ett individuellt parti utan partikod ska upptäckas som källproblem, inte
slås samman med övriga partier. Bevara kodernas inledande nollor. Kontrollera
att namn/områdestotaler är konstanta inom nyckelns områdesdel.

### Viktigaste nya deterministiska tester

1. **Hela matrisen:** parametriserade tester över 3 × 8 × 2. Godkända rutter
   väljer rätt reader/parser och källnod; avvisade kombinationer ger fel före
   IO. Testa att niva NULL är identiskt med explicit RD/riket, RF/region och
   KF/kommun i båda räkningarna; val NULL ska ge fel. Testa även tomma
   värden, NA, felaktiga år och flervärdesargument. RF/lan hänvisar till region.
2. **Filurval:** individuella RD/RF/KF kontra verkliga `_OS_RF`/`_OS_KF`-namn,
   p kontra s, fel kodlängd, bakfiler, dubbelmatchning, fel råmetadata och
   flera JSON-filer av samma typ. Använd liten syntetisk index-/ZIP-fixture.
3. **Källprioritet:** låt två officiella testkällor avsiktligt ha olika tal.
   Kontrollera att KF/kommun och RF/region väljer M, RF/kommun väljer U och
   OS-nivåer väljer O. Varken sammanslagning, medelvärde eller fallback får ske.
4. **Tillgänglighet:** slutlig OS saknas i index; lokalt index finns men vald
   ZIP saknas; kretsobjekt saknar röstfördelning; icke valkretsindelat område.
   Skilj dessa från ett uttryckligt publicerat nollresultat. Ingen hämtning av
   preliminärt resultat när slutligt efterfrågats.
5. **Schema:** exakt kolumnordning och typer över D/U/M/O, preliminärt/slutligt,
   tomma och ifyllda tabeller; exakt 83 kolumner, inga listkolumner. Kontrollera profilerna P/G,
   inledande nollor och båda nivåerna av rapporteringsräknare.
6. **Röstidentiteter:** `totalt_antal_roster = giltiga_roster + ogiltiga_roster`;
   summan av enskilda partirader och källans övriga-kategori = giltiga röster;
   ogiltiga = kategorisumman när alla kategorier är kända. Okända tal gör
   kontrollen oavgjord; `na.rm = TRUE` får inte maskera luckor.
7. **Andelar:** kontrollera källans procentenhet och rimlig avrundning för
   partiröster när nämnaren är känd. Använd tolerans här, inte för heltalsröster.
   Noll nämnare ger inte Inf. Valdeltagande testas separat för rätt källfält
   och rätt population av röstberättigade, särskilt under pågående räkning.
8. **Officiella nivåer mot varandra:** RD D→U kommun→M riket och D→M
   riksdagsvalkrets→M riket; RF D→U kommun→M region och krets→region→O riket;
   KF D→M kommun, krets→kommun samt M kommun→O län→O riket. Aggregationen
   görs i tester, inte i API:t. Summera områdestotaler en gång per område,
   aldrig en gång per partirad. U kommunvalkretsar täcker bara indelade kommuner.
9. **Överlapp:** jämför RF M region med O-RF län och KF M kommun med O-KF
   kommun på gemensamma aktuella röstkolumner. Kräv inte likhet för fält
   som saknas i ena formatet. Använd synkroniserade, kompletta fixtures;
   Kontrollera antal enheter, kodmängder i båda riktningar och särskilt
   frånvarande, null eller uttryckligt nollvärderad Gotland-nod 09.
   Olika rapporteringstid/täckning i levande filer ska ge en tydlig diagnos,
   inte leda till att produktionsdata justeras.
10. **Partikategorier:** preliminära rapportpartier plus övriga mot slutliga
    individuella partier, utan dubbelräkning. Kontrollera saknad respektive
    uttryckligt nollvärderad övriga-nod: saknad/null ger ingen rad, explicit
    noll ger en rad, deklarerade null-fält bevarar NA, tomt/felaktigt objekt
    ger schemafel. Jämför aldrig kategorin som om den
    representerade samma partimängd i två olika räkningar.
11. **Spärr:** ja/nej/saknat/okänt, preliminär/slutlig, alla sex M-nivåerna,
    och NA på D/U/O samt övriga-raden. Inga egna procenttrösklar och ingen
    härledning av invald-status från flaggan.
12. **Källhantering:** återanvänd testmönstren för local/update-fel,
    arkivering utan nät, auto/remote, optionens prioritet och progress FALSE.
    Kontrollera högst en hämtning per vald ZIP och oförändrad exportlista
    för övriga publika funktioner.

Små handbyggda JSON-objekt och lokalt genererade ZIP-fixtures räcker för
unit-tester. Några godkända källrepresentativa integrationsexempel behövs för
filnamn, spärrtolkning och uppsamlingsdistrikt. Hundratals nätfiler ska inte
vara ett beroende för ordinarie tester. Ingen testdata kopieras in nu.

## Konkreta luckor före implementation

- Det saknas en publik `valresultat()`, en nivå-/källmatris i kod och en
  uttrycklig schemaadapter. Särskilt geografiska kolumner och räknarnas
  omfattning måste harmoniseras enligt ovan; ren radbindning räcker inte.
- RD/län saknar direkt belagd officiell summeringsparser. Om nivån senare
  tas med bör en separat, uttrycklig härledning från U:s kommunrader utredas:
  full täckning, hantering av rapportpartier, jämförelseområden, deltagandets
  nämnare och härledd proveniens. Inte från distrikt och inte genom att byta
  etikett på riksdagsvalkretsar.
- O-RF läser idag endast riket och länsnoder märkta `region`, inte de
  dokumenterade kommunnoderna. Det senare blockerar inte U-baserat kommunstöd.
  RF/län exponeras inte i förslaget; någon administrativ nivåadapter behövs
  därför inte. Faktisk M/OS-jämförelse återstår eftersom lokala OS-data saknas.
- M saknar kommun-/länsspecifika kolumner i utdata; U saknar valområdesidentitet.
  Dessa kan bara fyllas där källa/filidentitet ger entydig information.
- D/U/M/O skapar för närvarande övriga-rader även när övriga-noden saknas.
  Slutresultat kan därför få en tom syntetisk kategori. Föreslaget API ska
  skilja källans närvarande övriga-nod (även 0) från frånvaro. Det kräver
  rånärvaroinformation eller en avgränsad parseranpassning med regressionstest;
  filtrera inte bara på `antal_roster == 0` eller på att alla tal är NA.
- M kan returnera noll kolumner om alla röstnoder saknas. U kan göra samma sak
  vid tom kommunlista, medan O kan skapa en tom övriga-rad för saknad rotnod.
  Rotvalidering och typade tomma utdata behöver hanteras konsekvent.
- `read_raw_json_zip_2026()` använder en relativt bred delsträngsmatchning.
  Det strikta U-mönstret finns redan, men faktiska OS-JSON-namn måste
  verifieras. Fel filtyp ska inte upptäckas först genom konstiga parserrader.
- `parse_overordnad_summering_kf_2026()` saknar RF-parserns explicita valtyps-
  kontroll. Validera alltid råfilens typ i det nya flödet.
- Befintliga tester täcker hjälpare, indexurval, local-semantik, kandidater,
  personröster och några geografiska namn. De verifierar ännu inte hela
  röstschemat, M-röstparsern, OS-KF eller de geografiska röstidentiteterna.

## Beslut som planen föreslår inför nästa steg

Förslaget är ett API med en valtyp och nivå per anrop, `niva = NULL` som
valets naturliga huvudnivå, källprioriteten i matrisen, RD/län som uttrycklig
v1-lucka och RF/region som enda regionala RF-vy. Det exakta schemat har 83
kolumner med ovan angivna geografi-/rapporteringsregler, källstyrd
`over_sparr` och inga artificiella rader när övriga-noden saknas. Den fulla
RF M/OS-jämförelsen är fortfarande öppen på grund av saknade lokala filer;
den får inte beskrivas som verifierad likhet. Bygg därefter
små fixtures och kontraktstester innan den publika funktionen kopplas ihop.
Inga nya parsers eller ändringar i befintliga funktioner ingår i denna fil.

Endast denna planfil har uppdaterats i detta steg. Tester och R CMD check har inte körts om
för detta rena analyssteg; det skulle skapa andra arbetsfiler utan att
verifiera någon ny produktionskod.
