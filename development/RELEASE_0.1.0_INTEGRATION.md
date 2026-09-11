# Riktad integration inför 0.1.0

Kontrollen körs read-only med `integration-release-0.1.0.R`. Nätåtkomst och
arkivering spärras och MD5 kontrolleras före och efter körningen.

Lokalt fanns slutliga individuella D/U/M-filer för RD 00, RF 01 samt KF 0114
och 0180, plus kandidat-CSV. Preliminära filer och överordnade O-filer saknades
och är därför inte integrationstestade.

Den 10 september 2026 verifierades att RD:s mandat-, valda-, ersättar- och
personvalsstrukturer kan parsas med stabila typer. RD:s availability var
`TRUE` för valda och personval. RF/KF-filerna är mandatfiler och innehåller
officiella röstaggregat i `rostfordelning` på valområdes- och i förekommande
fall valkretsnivå; denna M-källa har tidigare verifierats för `valresultat()`.
I de lokala genrepsfilerna är däremot själva `mandatfordelning`-noden `null`,
liksom slutliga strukturer för `valda` och personval. `mandat()` ger därför
ett schema-stabilt tomt resultat och kandidatstatus blir `NA`, inte 0 eller
`FALSE`. Formuleringen avser alltså saknat fastställt mandatresultat, inte att
mandatfilen eller dess röstresultat saknas.

En separat körning av `kandidater(val = "RD", source = "local")` gick genom
den publika pipelinen och gav 6 316 kandidatnycklar: `invald` var TRUE för
347 och FALSE för 5 969, och personval var TRUE för 324 och FALSE för 5 992;
inga av dessa statusfält var `NA` när underlaget verifierats komplett. De 349
råa ledamotsraderna motsvarar 347 matchade kandidatnycklar i genrepet, en känd
typ av inkonsistens i testdata som inte ska ändra produktionsmodellen.
Publika RF/KF-landskörningar kunde inte göras eftersom
indexet hänvisar till områdesfiler som inte finns i det lokala urvalet; de
saknade filerna ersattes inte med fallback eller nätkälla.

En äldre personröstintegration stannade på ett kontrolltecken i ortnamnet i
KF 0114 under JSON-avkodning. Detta berör D-filens textkodning och är inte ett
fel i de nya availability- eller mandatändringarna; ingen produktionsändring
gjordes för att dölja avvikelsen.

## Livefilnamn enligt beskrivningen 2026-09-10

En liten deterministisk ZIP-fixture verifierar de korrigerade namnen
`Val_2026_slutlig_00_RD.zip` och interna JSON-filer för `rostfordelning`,
`mandatfordelning` och `summering_00_RD`. Ett syntetiskt `val2026/index.md5`
verifierar preliminära och slutliga individuella filer samt OS-filer för RF/KF.

ZIP-logiken konstruerar inte ett `Val_20260913`- eller `Val_2026`-prefix utan
använder hela den relativa sökvägen som faktiskt står i indexet. Det enda
upptäckta kompatibilitetsfelet var att underordnad summering tidigare väntade
sig genrepsformen `..._summering_RD.json` utan områdeskod. Mönstret accepterar
nu även liveformen `..._summering_00_RD.json`; genrepsformen stöds fortsatt.

Resultatsamlingen är fortsatt konfigurerbar. Med
`options(valresultat.resultatsamling_2026 = "val2026")` läses liveindexet från
`https://resultat.val.se/resultatfiler/val2026/index.md5`. Inför 0.1.0 ändrades
paketets default till `val2026`, så normala publika anrop inte kan returnera
genrepsdata tyst. `genrep2026` finns kvar som ett uttryckligt val för test och
utveckling.

## Slutlig releasegrind 2026-09-11

Paketversionen är `0.1.0`. Den fullständiga nätfria testsuiten omfattade 57
testblock och 922 godkända förväntningar, utan fel, varningar eller hoppade
tester. Ett rent källpaket byggdes och gav `Status: OK` i
`R CMD check --no-manual --no-vignettes`.

Källpaketet installerades därefter i ett tomt bibliotek utan konfigurerad
rådatakatalog. `library(valresultat)` fungerade, standardsamlingen var
`val2026` och namespace exporterade exakt `valresultat`, `mandat`,
`kandidaturer`, `kandidater`, `valda` och `ersattare`. Källpaketet innehöll
inga utvecklingsfiler, referensdokument, Git-filer eller lokala rådata.
