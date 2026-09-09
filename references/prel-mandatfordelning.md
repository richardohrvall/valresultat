# README – JSON-format mandatfördelning

Övergripande beskrivning: Filen innehåller information om mandatfördelningen för ett valområde.
Dokumentationen skapad: 2026-04-14

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

| Fält                                     | Typ           | Beskrivning                                                                                |
|------------------------------------------|---------------|--------------------------------------------------------------------------------------------|
| namn                                     | string        | Namn på valområdet                                                                         |
| kod                                      | string        | Valområdeskod                                                                              |
| rapporteringsTid                         | string / null | Tidpunkt för senaste rapport av ett distrikt i valområdet                                  |
| totaltAntalMandat                        | integer       | Totalt antal mandat                                                                        |
| totaltAntalFastaMandat                   | integer       | Totalt antal fasta mandat                                                                  |
| totaltAntalUtjamningsMandat              | integer       | Totalt antal utjämningsmandat                                                              |
| antalValdistriktRaknade                  | integer       | Antal räknade valdistrikt                                                                  |
| antalValdistriktSomSkaRaknas             | integer       | Totalt antal valdistrikt                                                                   |
| totaltAntalRoster                        | integer       | Totalt antal röster                                                                        |
| antalRostberattigade                     | integer       | Antal röstberättigade                                                                      |
| valdeltagande                            | number        | Valdeltagande                                                                              |
| antalRostberattigadeIRaknadeValdistrikt  | integer       | Röstberättigade i räknade distrikt                                                         |
| valomradessparrProcent                   | number        | Spärrprocent för valområdet                                                                |
| valkretssparrProcent                     | number        | 12% om RD, för andra val tas denna bort                                                    |
| meddelandetext                           | string        | meddelandetext för publicering i valresultatpresentation, obsolet                          |
| valomradeskodForegaendeVal               | array<string> | Valområdeskod föregående val                                                               |
| totaltAntalMandatForegaendeVal           | integer       | Mandat föregående val                                                                      |
| totaltAntalFastaMandatForegaendeVal      | integer       | Fasta mandat föregående val                                                                |
| totaltAntalUtjamningsMandatForegaendeVal | integer       | Utjämningsmandat föregående val                                                            |
| totaltAntalRosterForegaendeVal           | integer       | Röster föregående val                                                                      |
| antalRostberattigadeForegaendeVal        | integer       | Röstberättigade föregående val                                                             |
| valdeltagandeForegaendeVal               | number        | Valdeltagande föregående val                                                               |
| forandringTotaltAntalRoster              | integer       | Förändring antal röster                                                                    |
| forandringValdeltagande                  | number        | Förändring valdeltagande                                                                   |
| forandringAntalRostberattigade           | integer       | Förändring röstberättigade                                                                 |
| statusJamforelse                         | string        | Status för jämförelse (Jämförbart / Ej jämförbart)                                         |
| rostfordelning                           | object        | Json-objekt som innehåller röstetal för valområdet                                         |
| mandatfordelning                         | object / null | Json-objekt som innehåller mandatfördelning för valområdet                                 |
| valkretsLista                            | array         | Json-objekt som innehåller information per valkrets om röstfördelning och mandatfördelning |

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

## Root-objekt.valomrade.rostfordelning.rosterPaverkaMandat.partiRoster[]

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
| mandatfordelning                        | object / null  | Json-objekt som innehåller mandatfördelning för valkretsen |

---

## Root-objekt.valomrade.valkretsLista[].rostfordelning

se Root-objekt.valomrade.rostfordelning

---

## Root-objekt.valomrade.valkretsLista[].mandatfordelning

se Root-objekt.valomrade.mandatfordelning

---
