# README – JSON-format mandatfördelning

Övergripande beskrivning: Filen innehåller information om mandatfördelningen samt tillsatta ledamöter och ersättare för ett valområde.
Dokumentationen skapad: 2026-04-17

---

## Root-objekt

| Fält                   | Typ     | Beskrivning                                      |
|------------------------|---------|--------------------------------------------------|
| valtillfalle           | string  | Valtillfällets namn                              |
| valklass               | string  | Ordinarie val, omval, extra val                  |
| rakningstillfalle      | string  | preliminär eller slutlig                         |
| valtyp                 | string  | RD, KF, RF, E, S                                 |
| valdatum               | string  | Valdatum t ex 2026-09-13                         |
| tidigareValdatum       | string  | Tidigare valdatum t ex 2022-09-11                |
| test                   | boolean | Om true så innehåller filen testdata             |
| senasteUppdateringstid | string  | Senaste uppdateringstid t ex 2026-03-26T15:29:34 |
| antalUppdateringar     | integer | Antal uppdateringar filen haft                   |
| valomrade              | object  | Json-objekt som innehåller info om valområdet    |

---

## Root-objekt.valomrade

| Fält                                     | Typ           | Beskrivning                                                                                                                                                                   |
|------------------------------------------|---------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| namn                                     | string        | Namn på valområdet                                                                                                                                                            |
| kod                                      | string        | Valområdeskod                                                                                                                                                                 |
| rapporteringsTid                         | string / null | Tidpunkt för senaste rapport av ett distrikt i valområdet                                                                                                                     |
| totaltAntalMandat                        | integer       | Totalt antal mandat                                                                                                                                                           |
| totaltAntalFastaMandat                   | integer       | Totalt antal fasta mandat                                                                                                                                                     |
| totaltAntalUtjamningsMandat              | integer       | Totalt antal utjämningsmandat                                                                                                                                                 |
| antalValdistriktRaknade                  | integer       | Antal räknade valdistrikt                                                                                                                                                     |
| antalValdistriktSomSkaRaknas             | integer       | Totalt antal valdistrikt                                                                                                                                                      |
| lankTillProtokoll                        | string / null | URL till huvudprotokoll                                                                                                                                                       |
| totaltAntalRoster                        | integer       | Totalt antal röster                                                                                                                                                           |
| antalRostberattigade                     | integer       | Antal röstberättigade                                                                                                                                                         |
| valdeltagande                            | number        | Valdeltagande                                                                                                                                                                 |
| antalRostberattigadeIRaknadeValdistrikt  | integer       | Röstberättigade i räknade distrikt                                                                                                                                            |
| valomradessparrProcent                   | number        | Spärrprocent för valområdet                                                                                                                                                   |
| valkretssparrProcent                     | number        | 12% om RD, för andra val tas denna bort                                                                                                                                       |
| meddelandetext                           | string        | meddelandetext för publicering i valresultatpresentation, obsolet                                                                                                             |
| valomradeskodForegaendeVal               | array<string> | Valområdeskod föregående val                                                                                                                                                  |
| totaltAntalMandatForegaendeVal           | integer       | Mandat föregående val                                                                                                                                                         |
| totaltAntalFastaMandatForegaendeVal      | integer       | Fasta mandat föregående val                                                                                                                                                   |
| totaltAntalUtjamningsMandatForegaendeVal | integer       | Utjämningsmandat föregående val                                                                                                                                               |
| totaltAntalRosterForegaendeVal           | integer       | Röster föregående val                                                                                                                                                         |
| antalRostberattigadeForegaendeVal        | integer       | Röstberättigade föregående val                                                                                                                                                |
| valdeltagandeForegaendeVal               | number        | Valdeltagande föregående val                                                                                                                                                  |
| forandringTotaltAntalRoster              | integer       | Förändring antal röster                                                                                                                                                       |
| forandringValdeltagande                  | number        | Förändring valdeltagande                                                                                                                                                      |
| forandringAntalRostberattigade           | integer       | Förändring röstberättigade                                                                                                                                                    |
| statusJamforelse                         | string        | Status för jämförelse (Jämförbart / Ej jämförbart)                                                                                                                            |
| rostfordelning                           | object        | Json-objekt som innehåller röstetal för valområdet                                                                                                                            |
| kvalificeradeForPersonvalLista           | array         | Array med personer som klarat personröstspärren, attibutet finns enbart för ej valkretsindelade valområden, för valkretsindelade valområden finns attributet i valkretslistan |
| mandatfordelning                         | object / null | Json-objekt som innehåller mandatfördelning för valområdet                                                                                                                    |
| valda                                    | object / null | Json-objekt som innehåller valda för valområdet                                                                                                                               |
| valkretsLista                            | array / null  | Json-objekt som innehåller information per valkrets om röstfördelning och mandatfördelning                                                                                    |

---

## Root-objekt.valomrade.rostfordelning

| Fält                  | Typ    | Beskrivning                                                                                       |
|-----------------------|--------|---------------------------------------------------------------------------------------------------|
| rosterPaverkaMandat   | object | Json-objekt som innehåller information om röster som påverkar mandatfördelningen (giltiga röster) |
| rosterEjPaverkaMandat | object | Json-objekt som innehåller information om ogiltiga röster                                         |

---

## Root-objekt.valomrade.rostfordelning.rosterPaverkaMandat

| Fält                     | Typ            | Beskrivning                                                       |
|--------------------------|----------------|-------------------------------------------------------------------|
| antalRoster              | integer        | Totalt antal giltiga röster                                       |
| antalRosterForegaendeVal | integer / null | Antal giltiga röster föregående val                               |
| forandringAntalRoster    | integer / null | Förandring antal giltiga röster                                   |
| partiRoster              | array          | Array med röster per rapportparti (preliminär räkning)            |
| rosterOvrigaPartier      | object         | Röster på partier som inte är rapportpartier (preliminär räkning) |

---

## Root-objekt.valomrade.rostfordelning.rosterPaverkaMandat.partiRoster[]

Definitionen gäller för både root-objekt.valomrade.rostfordelning.rosterPaverkaMandat.partiRoster[] och root-objekt.valomrade.valkretsLista[].rostfordelning.
Attributet listRoster finns i Root-objekt.valomrade.rostfordelning.rosterPaverkaMandat.partiRoster[] om valområdet är ej valkretsindelat, för valkretsindelade valområden finns
listRoster i root-objekt.valomrade.valkretsLista[].rostfordelning.

| Fält                     | Typ            | Beskrivning                                                                                                            |
|--------------------------|----------------|------------------------------------------------------------------------------------------------------------------------|
| partibeteckning          | string         | Partibeteckning                                                                                                        |
| partiforkortning         | string         | Partiforkortning                                                                                                       |
| partikod                 | string         | Partikod (intern identifierare)                                                                                        |
| fargkod                  | string         | Färgkod                                                                                                                |
| ordningsnummer           | integer        | Ordningsnummer, de partier som saknar ordningsnummer sorteras efter a. antal röster, b. partiförkortning, c. partikod) |
| antalRoster              | integer        | Antal röster                                                                                                           |
| andelRoster              | number         | Andel röster av giltiga röster                                                                                         |
| deltaMandatfordelning    | string         | Ja - partiet över spärren i valområdet eller valkretsen / Nej - annars                                                 |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val                                                                                            |
| andelRosterForegaendeVal | integer / null | Andel röster föregående val                                                                                            |
| forandringAntalRoster    | integer / null | Förändring antal röster                                                                                                |
| forandringAndelRoster    | integer / null | Förändring andel röster                                                                                                |
| listRoster               | array / null   | Array med kandidaturer på partiets listor                                                                              |
| summeradePersonroster    | array / null   | Array med summerade personröster för partiet                                                                           |

---

## Root-objekt.valomrade.rostfordelning.rosterPaverkaMandat.partiRoster[].listRoster[]

| Fält                     | Typ     | Beskrivning                                    |
|--------------------------|---------|------------------------------------------------|
| listnummer               | string  | Identitet för listan                           |
| antalRoster              | integer | Antal röster på listan                         |
| antalRosterMedPersonrost | integer | Antal personröster på listan                   |
| personroster             | array   | Array med kandidaternas personröster på listan |

---

## Root-objekt.valomrade.rostfordelning.rosterPaverkaMandat.partiRoster[].listRoster[].personroster[]

| Fält                   | Typ     | Beskrivning                       |
|------------------------|---------|-----------------------------------|
| namn                   | string  | Kandidatens namn på listan        |
| kandidatNummerPaListan | integer | Kandidatens nummer på listan      |
| kandidatNummer         | integer | Unik identifierare                |
| antalPersonroster      | integer | Antal personröster för kandidaten |

---

## Root-objekt.valomrade.rostfordelning.rosterPaverkaMandat.partiRoster[].summeradePersonroster[]

| Fält              | Typ     | Beskrivning                    |
|-------------------|---------|--------------------------------|
| namn              | string  | Kandidatens folkbokföringsnamn |
| kandidatnummer    | integer | Unik identifierare             |
| antalPersonroster | integer | Antal personröster             |

---

## Root-objekt.valomrade.rostfordelning.rosterPaverkaMandat.rosterOvrigaPartier

| Fält                     | Typ            | Beskrivning                    |
|--------------------------|----------------|--------------------------------|
| antalRoster              | integer        | Antal röster                   |
| andelRoster              | number         | Andel röster av giltiga röster |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val    |
| andelRosterForegaendeVal | integer / null | Andel röster föregående val    |
| forandringAntalRoster    | integer / null | Förändring antal röster        |
| forandringAndelRoster    | integer / null | Förändring andel röster        |

---

## Root-objekt.valomrade.rostfordelning.rosterEjPaverkaMandat

| Fält                                        | Typ            | Beskrivning                                                        |
|---------------------------------------------|----------------|--------------------------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | integer / null | Andel röster av totalt antal röster föregående val                 |
| forandringAntalRoster                       | integer / null | Förändring antal röster                                            |
| forandringAndelRosterAvTotaltAntalRoster    | integer / null | Förändring andel röster av totalt antal röster                     |
| rosterEjAnmaltDeltagande                    | object         | json-objekt med info om röster på partier som ej anmalt deltagande |
| blankaRoster                                | object         | json-objekt med information omblanka röster                        |
| ovrigaOgiltiga                              | object         | json-objekt med information om övriga ogiltiga röster              |

---

## Root-objekt.valomrade.rostfordelning.rosterEjPaverkaMandat.rosterEjAnmaltDeltagande

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | integer / null | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | integer / null | Förändring andel röster av totalt antal röster     |

---

## Root-objekt.valomrade.rostfordelning.rosterEjPaverkaMandat.rosterEjPaverkaMandat.blankaRoster

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | integer / null | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | integer / null | Förändring andel röster av totalt antal röster     |

---

## Root-objekt.valomrade.rostfordelning.rosterEjPaverkaMandat.rosterEjPaverkaMandat.ovrigaOgiltiga

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | integer / null | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | integer / null | Förändring andel röster av totalt antal röster     |

---

## Root-objekt.valomrade.kvalificeradeForPersonvalLista[]

Definitionen gäller både för root-objekt.valomrade.kvalificeradeForPersonvalLista och root-objekt.valomrade.valkretsLista[].kvalificeradeForPersonvalLista.

| Fält              | Typ           | Beskrivning                                                                |
|-------------------|---------------|----------------------------------------------------------------------------|
| partikod          | string        | Partikod                                                                   |
| partifarg         | string        | Partifärg                                                                  |
| partiforkortning  | string        | Partiförkortning                                                           |
| namn              | string        | Kandidatens folkbokföringsnamn                                             |
| kandidatnummer    | integer       | Unik identifierare                                                         |
| antalPersonroster | integer       | Antal personröster                                                         |
| andelPersonroster | number        | Andel personröster                                                         |
| valkretskod       | string / null | Valkretskod, finns enbart för valkretsindelade valområden i valkretslistan |

---

## Root-objekt.valomrade.mandatfordelning

| Fält       | Typ   | Beskrivning                                  |
|------------|-------|----------------------------------------------|
| partiLista | array | Array innehållandes info om mandat per parti |

---

## Root-objekt.valomrade.mandatfordelning.partiLista[]

| Fält                               | Typ     | Beskrivning                     |
|------------------------------------|---------|---------------------------------|
| partibeteckning                    | string  | Partiets namn                   |
| partikod                           | string  | Partikod                        |
| partiforkortning                   | string  | Partiförkortning                |
| antalMandat                        | integer | Totalt antal mandat             |
| antalFastaMandat                   | integer | Antal fasta mandat              |
| antalUtjamningsmandat              | integer | Antal utjämningsmandat          |
| antalMandatForegaendeVal           | integer | Mandat föregående val           |
| antalFastaMandatForegaendeVal      | integer | Fasta mandat föregående val     |
| antalUtjamningsMandatForegaendeVal | integer | Utjämningsmandat föregående val |
| forandringAntalMandat              | integer | Förändring antal mandat         |

---

## Root-objekt.valomrade.valda

Definitionen gäller för både root-objekt.valomrade.valda och root-objekt.valomrade.valkretsLista[].valda

| Fält                | Typ   | Beskrivning                                     |
|---------------------|-------|-------------------------------------------------|
| partiLedamoterLista | array | Array innehållandes info om ledamöter per parti |

---

## Root-objekt.valomrade.valda.partiLedamoterLista[]

| Fält             | Typ     | Beskrivning                                 |
|------------------|---------|---------------------------------------------|
| partibeteckning  | string  | Partiets namn                               |
| partikod         | string  | Partikod                                    |
| partiforkortning | string  | Partiförkortning                            |
| partifarg        | string  | Partifarg                                   |
| antalTommaStolar | integer | Antal mandat som partiet inte kan tillsätta |
| ledamoter        | array   | Array innehållandes info om ledamoten       |

---

## Root-objekt.valomrade.valda.partiLedamoterLista[].ledamoter[]

Definitionen gäller för både

| Fält           | Typ           | Beskrivning                                       |
|----------------|---------------|---------------------------------------------------|
| valkretsnamn   | string / null | Valkretsnamn, finns för valkretsindelat valomrade |
| valkretskod    | string / null | Valkretskod, finns för valkretsindelat valomrade  |
| invalsordning  | integer       | Ordning ledamoten är invald för partiet           |
| kandidatnummer | integer       | Unik identifierare                                |
| namn           | string        | Kandidatens folkbokföringsnamn                    |
| valgrundId     | integer       | Valgrundens id                                    |
| valgrundText   | string        | Valgrund i klartext                               |
| ersattargrupp  | string        | Nummer på ersättargruppen                         |
| ersattareList  | array         | Array innehållandes info om ersättare             |

---

## Root-objekt.valomrade.valda.partiLedamoterLista[].ledamoter[].ersattareList[]

| Fält            | Typ     | Beskrivning                    |
|-----------------|---------|--------------------------------|
| ersattarordning | integer | Ordning ersättaren är vald     |
| kandidatnummer  | integer | Unik identifierare             |
| namn            | string  | Kandidatens folkbokföringsnamn |
| valgrundId      | integer | Valgrundens id                 |
| valgrundText    | string  | Valgrund i klartext            |

---

## Root-objekt.valomrade.valkretsLista[]

| Fält                                    | Typ            | Beskrivning                                                |
|-----------------------------------------|----------------|------------------------------------------------------------|
| namnValkrets                            | string         | Valkretsens namn                                           |
| kod                                     | string         | Valkretskod                                                |
| rapporteringsTid                        | string / null  | Senaste rapporteringstid för ett distrikt i valkretsen     |
| totaltAntalFastaMandat                  | integer        | Fasta mandat i kretsen                                     |
| antalRostberattigade                    | integer        | Röstberättigade i valkretsen                               |
| totaltAntalRoster                       | integer        | Totalt antal röster i kretsen                              |
| valdeltagande                           | number         | Valdeltagande                                              |
| antalRostberattigadeIRaknadeValdistrikt | integer        | Röstberättigade i räknade distrikt                         |
| antalValdistriktRaknade                 | integer        | Räknade valdistrikt                                        |
| antalValdistriktSomSkaRaknas            | integer        | Totalt antal valdistrikt                                   |
| lankTillProtokoll                       | string / null  | URL till huvudprotokoll, gäller endast RD-val              |
| valkretskodForegaendeVal                | array<string>  | Kod(er) föregående val                                     |
| totaltAntalRosterForegaendeVal          | integer        | Röster föregående val                                      |
| totaltAntalFastaMandatForegaendeVal     | integer / null | Fasta mandat föregående val                                |
| antalRostberattigadeForegaendeVal       | integer        | Röstberättigade föregående val                             |
| valdeltagandeForegaendeVal              | number         | Valdeltagande föregående val                               |
| forandringTotaltAntalRoster             | integer / null | Förändring röster                                          |
| forandringValdeltagande                 | number / null  | Förändring valdeltagande                                   |
| forandringAntalRostberattigade          | integer        | Förändring röstberättigade                                 |
| statusJamforelse                        | string         | Kan jämföras / Kan ej jämföras                             |
| rostfordelning                          | object / null  | Json-objekt som innehåller röstetal för valkretsen         |
| kvalificeradeForPersonvalLista          | array          | Array med personer som klarat personröstspärren            |
| mandatfordelning                        | object / null  | Json-objekt som innehåller mandatfördelning för valkretsen |
| valda                                   | object / null  | Json-objekt som innehåller valda för valkretsen            |                                                                                                                 |

---

## Root-objekt.valomrade.valkretsLista[].rostfordelning

se Root-objekt.valomrade.rostfordelning

---

## Root-objekt.valomrade.valkretsLista[].kvalificeradeForPersonvalLista[]

se Root-objekt.valomrade.kvalificeradeForPersonvalLista

---

## Root-objekt.valomrade.valkretsLista[].mandatfordelning

se Root-objekt.valomrade.mandatfordelning

---

## Root-objekt.valomrade.valkretsLista[].valda

se Root-objekt.valomrade.valda

---


