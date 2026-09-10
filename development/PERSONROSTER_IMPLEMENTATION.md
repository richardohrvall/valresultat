# Personröster: implementation och verifiering

Availability enligt `PERSONROSTER_AVAILABILITY.md` är implementerad internt.
Kandidatmodellens observationsnivå och publika funktionsargument är oförändrade.

## Ändrat beteende

- Underlaget bedöms per valtyp, valområde och parti. `TRUE` kräver komplett
  slutlig distriktsrapportering, giltiga och unika identiteter samt konsistens
  mellan listornas personröster och den summerade kandidatstrukturen.
- Saknade/null personröststrukturer utan personröstinformation ger internt
  `FALSE`. Partiellt, motsägelsefullt eller oklart underlag ger internt `NA`.
  Båda innebär `NA_integer_` i kandidatens totala personröster.
- En kandidat som saknas i verifierat komplett underlag får 0. Explicit noll
  bevaras. Tomma arrayer bedöms separat från saknade/null strukturer.
- För kandidater i flera valområden måste samtliga relevanta områden från
  giltiga kandidaturer vara verifierat kompletta. Annars blir totalen `NA`.
- Saknade röster summeras inte längre bort med `na.rm = TRUE`. En befintlig
  rad med okänt röstetal omvandlas inte till noll.
- Kandidatnummer som råkällan anger som heltal stöds och normaliseras till
  teckenidentiteter, med regressionstest.

Personvalskvalificering och invald-logik har inte ändrats. De tre befintliga
detaljerade personrösttabellerna och deras parser är oförändrade. `valresultat()`,
`mandat()` och QMD-filen har inte ändrats.

## Filer i ändringen

Nya filer:

- `R/personroster_availability_2026.R`: intern rådatavalidering, availability
  och kandidatens totalsumma över relevanta områden.
- `tests/testthat/test-personroster-availability.R`: deterministiska fixtures
  för tomt/null/saknat, täckning, felaktiga tal och identiteter, röstsummor,
  flera valområden, noll kontra NA samt saknade RF/KF-resultat.
- `development/integration-personroster.R`: reproducerbar lokal kontroll med
  spärrad nätåtkomst/arkivering och kontrollsummor för råfilerna.
- `development/PERSONROSTER_INTEGRATION.txt`: integrationskörningens utfall.
- `development/PERSONROSTER_IMPLEMENTATION.md`: denna redovisning.

Ändrade filer:

- `R/kandidatresultat_2026.R`: kopplar in verifierat områdesunderlag och
  ersätter ovillkorlig nollutfyllnad med availability-styrda totaler.
- `R/add_personroster_to_kandidater_2026.R`: äldre intern hjälpfunktion kräver
  explicit internt bevis på komplett underlag; annars NA. Inga nya argument.
- `R/globals.R`: deklarationer för intern NSE-användning.
- `R/api_kandidater.R` och `man/kandidater.Rd`: dokumenterar totalernas betydelse.
- `tests/testthat/test-kandidater.R`: uppdaterade förväntningar och interna mocks.
- `development/PERSONROSTER_AVAILABILITY.md`: implementationsstatus och länkar.

En separat ändring i `README.md` fanns vid slutkontrollen; den ingår inte i
denna uppgift och har lämnats orörd.

## Verkliga filer: read-only integration

Följande filer under `C:/valdata/2026/genrep2026/` testades:

| Fil | Giltiga kandidatnycklar i områdesurvalet | Positiv total | Noll | NA |
| --- | ---: | ---: | ---: | ---: |
| `s/kf/Genrep_2026_slutlig_0114_KF.zip` | 278 | 52 | 185 | 41 |
| `s/kf/Genrep_2026_slutlig_0180_KF.zip` | 888 | 112 | 647 | 129 |
| `s/rd/Genrep_2026_slutlig_00_RD.zip` | 6316 | 1236 | 4528 | 552 |
| `s/rf/Genrep_2026_slutlig_01_RF.zip` | 1853 | 173 | 1569 | 111 |

Giltiga kandidaturer lästes från
`C:/valdata/2026/val2026/parti/kandidaturer.csv`. Kontrollen omfattade rådata,
filparserns kandidatresultat och totalberäkningen för kandidaturerna i respektive
lokalt områdesurval, inklusive unika kandidatnycklar och stabil heltalstyp.
Det är inte ett fullständigt rikstäckande publikt RF/KF-anrop. Flera områden per
kandidat kontrolleras dessutom med deterministiska fixtures.

**De befintliga RF/KF-filerna innehåller personröster.** Åtta partier per testad
fil uppfyller fullständighetskraven; övriga har oklart underlag. Ett generellt
NA för RF/KF skulle därför strida mot den godkända rådatastyrda regeln. Tester
med faktiskt saknade RF/KF-strukturer ger fortsatt NA, aldrig automatisk nolla.
Detta krävde ingen ändring av planen eller den publika modellen.

Samtliga integrationskontroller passerade. MD5 för alla fem lästa källfiler
var oförändrat efter körningen. Ingenting hämtades, uppdaterades eller
arkiverades i rådataarkivet.

## Slutlig paketkontroll

- Hela testsuiten: **810 godkända förväntningar, 0 fel, 0 varningar, 0 överhoppade**.
- `R CMD check --no-manual --no-vignettes`: **0 errors, 0 warnings, 0 notes**
  (`Status: OK`). Logg: `.check/valresultat.Rcheck/00check.log`.
- Ingen git commit har gjorts.
