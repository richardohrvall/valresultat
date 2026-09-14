# Integration av `valresultat()` 0.2.0 mot live-snapshot

Kontrollen kördes 2026-09-14 mot `C:/valdata/manual-snapshots/2026-09-14_1014` med nuvarande arbetskatalog. Snapshotet lästes endast lokalt. Filupplösningen bands till de fyra faktiskt sparade ZIP-filerna; ingen saknad fil ersattes och inget nätanrop gjordes.

## Inventering

| ZIP | räkning | val | valområdeskod | JSON-källor i ZIP |
|---|---|---|---:|---|
| `p/rd/Val_2026_preliminar_00_RD.zip` | preliminär | RD | 00 | röstfördelning D, mandatfördelning M, underordnad summering U |
| `p/rf/Val_2026_preliminar_01_RF.zip` | preliminär | RF | 01 | röstfördelning D, mandatfördelning M, underordnad summering U |
| `p/kf/Val_2026_preliminar_0114_KF.zip` | preliminär | KF | 0114 | röstfördelning D, mandatfördelning M |
| `p/kf/Val_2026_preliminar_0180_KF.zip` | preliminär | KF | 0180 | röstfördelning D, mandatfördelning M |

Råmetadata var genomgående `valtillfalle = "Val_2026"`, `rakningstillfalle = "preliminär"` och rätt `valtyp`. Paketet normaliserade räkningen till det publika värdet `"preliminar"`.

Snapshotet innehåller inga slutliga filer och inga överordnade summeringar (OS). Slutlig räkning samt RF/riket och KF/lan/riket är därför inte integrationstestade här. Avsaknaden är ingen produktionsavvikelse.

## Valdistrikt

| ZIP | distrikt i råfil | räknade | oräknade (`rostfordelning = NULL`) | publika rader | unika publika distrikt | explicita nollrader |
|---|---:|---:|---:|---:|---:|---:|
| KF 0114 | 29 | 28 | 1 | 319 | 29 | 5 |
| KF 0180 | 612 | 591 | 21 | 7 956 | 612 | 1 012 |
| RD 00 | 6 626 | 6 276 | 350 | 59 634 | 6 626 | 27 |
| RF 01 | 1 460 | 1 396 | 64 | 16 060 | 1 460 | 1 359 |

För varje fil motsvarade antalet unika publika `valdistriktskod` exakt antalet distriktsobjekt. Mängden distrikt med `raknat = TRUE` motsvarade både distriktsobjekten med icke-`NULL` röstfördelning och rotens `antalValdistriktRaknade`. Alla `NULL`-distrikt fick `raknat = FALSE`.

Samtliga aktuella röst-, andels-, valdeltagande-, giltighets- och differensfält var typade `NA` för oräknade distrikt. Källkänd kontext, exempelvis antal röstberättigade och föregående val, behölls. Varje rapporterad partirad jämfördes med motsvarande rånod. Alla uttryckliga nollor ovan fanns kvar som integer 0. `filter(raknat)` var identiskt med det tidigare kanoniska D-resultatet för nycklar och resultatvärden.

## Partiuniversum

| ZIP | mandatvalkretsar i matchningen | skilda universum inom filen | rader per universum |
|---|---:|---:|---:|
| KF 0114 | valområdesnivå (ingen M-valkretslista) | 1 | 11 |
| KF 0180 | 6 | 1 | 13 |
| RD 00 | 29 | 1 | 9 |
| RF 01 | 12 | 1 | 11 |

För varje oräknat distrikt jämfördes den publika partimängden exakt med `rostfordelning` i mandatfilens matchade valkrets. Om mandatfilen saknade valkretslista användes dess valområdesnod. Varje distrikts `kretskod` matchade en unik M-valkrets när en sådan lista fanns. Rapporterade distriktsrader innehöll ingen icke-övrig partikod utanför detta officiella universum.

Universumen råkade vara lika mellan valkretsarna inom respektive ZIP, så snapshotet kan inte ensamt skilja två felaktigt förväxlade valkretsuniversum genom deras innehåll. Den explicita kodmatchningen passerade. De två KF-valområdena hade däremot olika stora universum (11 respektive 13 rader), vilket verifierar att de inte delar ett godtyckligt universum från en annan kommun.

Mandatnoden innehöll en icke-`NULL` `rosterOvrigaPartier` för samtliga relevanta universum, och den publika övriga-raden förekom exakt därmed. Snapshotet gav inget verkligt fall där noden saknades eller var `NULL`; det fallet är fortsatt fixture-testat. Ingen fil hade 0 räknade distrikt, så uppbyggnad av alla distriktsrader från mandatfilen när räkningen står på noll är också fortsatt endast fixture-testad.

## Geografisk kontext

Distriktskoder, distriktsnamn och typer, kommun-, läns- och valområdeskoder samt kommunvalkretskod/-namn jämfördes radvis med D-källan. Valområdesnamn och valkretskod/-namn jämfördes med M-källan. Kommunnamn för RD/RF jämfördes med U-källans samtliga kommuner; för KF jämfördes namnet med M-filens valområde. Inga saknade eller felmatchade kommun-, läns- eller valområdesnamn upptäcktes.

| ZIP | kommuner | län | M-valkretsar | kommunvalkretskoder i D |
|---|---:|---:|---:|---:|
| KF 0114 | 1 | 1 | 0 | 1 |
| KF 0180 | 1 | 1 | 6 | 6 |
| RD 00 | 290 | 21 | 29 | 314 |
| RF 01 | 26 | 1 | 12 | 34 |

Länskoden kommer från D-filen. Länsnamnet fylls av den fasta 2026-lookup som i koden dokumenteras mot Valmyndighetens överordnade KF-summering. RD-snapshotet täckte alla 21 länskoder: varje kod fick exakt ett icke-saknat namn och inga koder gav flera namn. Någon OS-fil fanns inte i snapshotet, så namnlistan kunde inte återvalideras mot en OS-råfil i just denna körning.

## Publikt schema och övriga nivåer

Det interna harmoniserade resultatet hade fortsatt exakt 83 kolumner med de frysta typerna. Efter den sista kontraktsgenomgången omfattar de frysta publika kontrakten 77 kolumner för valdistrikt, 72 för kommun, 74 för kommunvalkrets, 68 för län, 67 för region, 71 för regionvalkrets, 72 för riksdagsvalkrets och 66 för riket. Den ursprungliga snapshotkörningen verifierade samma resultatvärden och geografi med de dåvarande, något bredare kontrakten; den uppdaterade fulla testsuiten verifierar de slutliga kolumnurvalen. Inga listkolumner förekom. Geografiska identifierare ligger i kontraktets avsedda ordning, och riket exponerar inga läns-, kommun-, valområdes-, valkrets- eller distriktskolumner. `dplyr::bind_rows()` fungerar mellan distrikts- och riksnivå.

| val | nivå | primärkälla | publika rader | geografiska enheter |
|---|---|---|---:|---:|
| RD | valdistrikt | D | 59 634 | 6 626 |
| RD | kommun | U | 2 610 | 290 |
| RD | kommunvalkrets | U | 369 | 41 |
| RD | riksdagsvalkrets | M | 261 | 29 |
| RD | riket | M | 9 | 1 |
| RF | valdistrikt | D | 16 060 | 1 460 |
| RF | kommun | U | 286 | 26 |
| RF | kommunvalkrets | U | 132 | 12 |
| RF | regionvalkrets | M | 132 | 12 |
| RF | region | M | 11 | 1 |
| KF | valdistrikt | D | 8 275 | 641 |
| KF | kommunvalkrets | M | 78 | 6 |
| KF | kommun | M | 24 | 2 |

Den publika kolumnselektionen jämfördes med det interna 83-kolumnsresultatet och ändrade inga resultatvärden. Rapporterade röstsummor stämde mellan de officiella nivåerna D–U–M för RD och RF samt mellan D och M för KF. Kommunvalkretssummor stämde med kommunnivån där en officiell kommunvalkretsindelning fanns.

## Integritet och utfall

MD5 för `index.md5` och samtliga fyra ZIP-filer beräknades före och efter körningen. Alla fem hashvärden var identiska. ZIP-filernas hashvärden stämde dessutom med de poster som sparats i snapshotets `index.md5`.

Ingen faktisk produktionsavvikelse upptäcktes. Ingen produktionskod, datamodell eller API ändrades som följd av integrationen. De kvarvarande empiriska luckorna är slutlig räkning, OS-källor, ett verkligt noll-räknat fall och en verklig mandatnod där `rosterOvrigaPartier` saknas eller är `NULL`.

Hela den nätfria `testthat`-sviten passerade. Ett rent källpaket byggdes och `R CMD check --no-manual --no-vignettes` avslutades med `Status: OK` (0 errors, 0 warnings, 0 notes). Paketversionen lämnades oförändrad på 0.1.1.
