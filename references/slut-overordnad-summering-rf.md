# Överordnad summering – röst- och mandatfördelning

Övergripande beskrivning: Sammanställning av resultatet för regionval i hela Sverige.
Dokumentationen skapad: 2026-04-17

---

## Root-objekt

| Fält                         | Typ     | Beskrivning                                      |
|------------------------------|---------|--------------------------------------------------|
| valtillfalle                 | string  | Valtillfälle som röstfördelningen avser          |
| valklass                     | string  | T ex ordinarie val                               |
| rakningstillfalle            | string  | preliminär eller slutlig                         |
| valtyp                       | string  | RF                                               |
| valdatum                     | string  | Valdatum t ex 2026-09-13                         |
| tidigareValdatum             | string  | Tidigare valdatum t ex 2022-09-11                |
| test                         | boolean | Test                                             |
| senasteUppdateringstid       | string  | Senaste uppdateringstid t ex 2026-03-26T15:29:34 |
| antalUppdateringar           | integer | Antal uppdateringar                              |
| antalValdistriktRaknade      | integer | Antal valdistrikt räknade                        |
| antalValdistriktSomSkaRaknas | integer | Antal valdistrikt som ska räknas                 |
| helaLandet                   | object  | Summering för riket                              |

---

## Root.helaLandet

| Fält                                    | Typ     | Beskrivning                              |
|-----------------------------------------|---------|------------------------------------------|
| namn                                    | string  | Riket                                    |
| senasteRapporteringstid                 | string  | Senaste rapporteringstid                 |
| totaltAntalMandat                       | integer | Totalt antal mandat i landet             |
| antalValdistriktRaknade                 | integer | Antal valdistrikt som räknats            |
| antalValdistriktSomSkaRaknas            | integer | Antal distrikt som ska räknas            |
| totaltAntalRoster                       | integer | Totalt antal röster                      |
| antalRostberattigade                    | integer | Antal röstberättigade                    |
| antalRostberattigadeIRaknadeValdistrikt | integer | Antal röstberättigade i räknade distrikt |
| valdeltagande                           | number  | Valdeltagande                            |
| totaltAntalMandatForegaendeVal          | integer | Antal mandat föregående val              |
| totaltAntalRosterForegaendeVal          | integer | Antal röster föregående val              |
| antalRostberattigadeForegaendeVal       | integer | Antal röstberättigade föregående val     |
| valdeltagandeForegaendeVal              | number  | Valdeltagande föregående val             |
| forandringTotaltAntalRoster             | integer | Förändring antal röster                  |
| forandringValdeltagande                 | number  | Förändring valdeltagande                 |
| forandringAntalRostberattigade          | integer | Förändring antal röstberättigade         |
| statusJamforelse                        | string  | Kan jämföras (hela riket)                |
| rostfordelning                          | object  | Innehåller röstfördelning                |
| mandatfordelning                        | object  | Innehåller mandatfördelning              |
| lan                                     | array   | Array över län                           |

---

## Root.helaLandet.lan[]

| Fält                                    | Typ     | Beskrivning                                    |
|-----------------------------------------|---------|------------------------------------------------|
| namn                                    | string  | Namn på län                                    |
| lankod                                  | string  | Kod för län                                    |
| senasteRapporteringstid                 | string  | Senaste tid ett distrikt i länet rapporterades |
| totaltAntalMandat                       | integer | Antal mandat i länet                           |
| antalValdistriktRaknade                 | integer | Räknade distrikt                               |
| antalValdistriktSomSkaRaknas            | integer | Distrikt som ska räknas                        |
| totaltAntalRoster                       | integer | Totalt antal röster                            |
| antalRostberattigade                    | integer | Totalt antal röstberättigade                   |
| valdeltagande                           | number  | Valdeltagande                                  |
| antalRostberattigadeIRaknadeValdistrikt | integer | Antal röstberättigade i räknade valdistrikt    |
| totaltAntalMandatForegaendeVal          | integer | Antal mandat föregående val                    |
| totaltAntalRosterForegaendeVal          | integer | Antal röster föregående val                    |
| antalRostberattigadeForegaendeVal       | integer | Antal röstberättigade föregående val           |
| valdeltagandeForegaendeVal              | number  | Valdeltagande föregående val                   |
| forandringTotaltAntalRoster             | integer | Förändring antal röster                        |
| forandringValdeltagande                 | number  | Förändring valdeltagande                       |
| forandringAntalRostberattigade          | integer | Förändring antal röstberättigade               |
| statusJamforelse                        | string  | Kan jämföras / kan ej jämföras                 |
| rostfordelning                          | object  | Innehåller röstfördelning                      |
| mandatfordelning                        | object  | Innehåller mandatfördelning                    |
| kommuner                                | array   | Array över kommuner                            |

---

## Root.helaLandet.lan[].kommuner[]

| Fält           | Typ    | Beskrivning               |
|----------------|--------|---------------------------|
| namn           | string | Kommunens namn            |
| kommunkod      | string | Kommunens kod             |
| rostfordelning | object | Innehåller röstfördelning |

---

## Root.helaLandet.rostfordelning

| Fält                  | Typ    | Beskrivning                                           |
|-----------------------|--------|-------------------------------------------------------|
| rosterPaverkaMandat   | object | Röster som påverkar mandatfördelning (giltiga röster) |
| rosterEjPaverkaMandat | object | Röster ej påverka mandatfördelning (ogiltiga röster)  |

---

## Root.helaLandet.rostfordelning.rosterPaverkaMandat

| Fält                     | Typ            | Beskrivning                 |
|--------------------------|----------------|-----------------------------|
| antalRoster              | integer        | Antal röster                |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val |
| forandringAntalRoster    | integer / null | Förändring antal röster     |
| partiRoster              | array          | Innehåller röster per parti |
| rosterOvrigaPartier      | object         | Röster övriga partier       |

---

## Root.helaLandet.rostfordelning.rosterPaverkaMandat.partiRoster[]

| Fält                     | Typ            | Beskrivning                                  |
|--------------------------|----------------|----------------------------------------------|
| partibeteckning          | string         | Partibeteckning                              |
| partiforkortning         | string         | Partiförkortning                             |
| partikod                 | string         | Partikod                                     |
| fargkod                  | string         | Färgkod                                      |
| ordningsnummer           | integer        | Ordningsnummer                               |
| antalRoster              | integer        | Antal röster                                 |
| andelRoster              | number         | Andel röster                                 |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val                  |
| andelRosterForegaendeVal | number / null  | Andel röster föregående val                  |
| forandringAntalRoster    | integer / null | Förändring antal röster                      |
| forandringAndelRoster    | number / null  | Förändring andel röster                      |
| summeradePersonroster    | array / null   | Array med summerade personröster för partiet |

---

## Root.helaLandet.rostfordelning.rosterPaverkaMandat.partiRoster[].summeradePersonroster[]

| Fält              | Typ     | Beskrivning                    |
|-------------------|---------|--------------------------------|
| namn              | string  | Kandidatens folkbokföringsnamn |
| kandidatnummer    | integer | Unik identifierare             |
| antalPersonroster | integer | Antal personröster             |

---

## Root.helaLandet.rostfordelning.rosterPaverkaMandat.rosterOvrigaPartier

| Fält                     | Typ            | Beskrivning                 |
|--------------------------|----------------|-----------------------------|
| antalRoster              | integer        | Antal röster                |
| andelRoster              | number         | Andel röster                |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val |
| andelRosterForegaendeVal | number / null  | Andel röster föregående val |
| forandringAntalRoster    | integer / null | förändring antal röster     |
| forandringAndelRoster    | number / null  | Förändring andel röster     |

---

## Root.helaLandet.rostfordelning.rosterEjPaverkaMandat

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |
| rosterEjAnmaltDeltagande                    | object         | Röster på partier som ej anmält deltagande         |
| blankaRoster                                | object         | Blanka röster                                      |
| ovrigaOgiltiga                              | object         | Övriga ogiltiga röster                             |

---

## Root.helaLandet.rostfordelning.rosterEjPaverkaMandat.rosterEjAnmaltDeltagande

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |

---

## Root.helaLandet.rostfordelning.rosterEjPaverkaMandat.blankaRoster

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |

---

## Root.helaLandet.rostfordelning.rosterEjPaverkaMandat.ovrigaOgiltiga

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |

---

## Root.helaLandet.mandatfordelning

| Fält       | Typ   | Beskrivning                |
|------------|-------|----------------------------|
| partiLista | array | Mandatfördelning per parti |

---

## Root.helaLandet.mandatfordelning.partiLista[]

| Fält                     | Typ     | Beskrivning             |
|--------------------------|---------|-------------------------|
| partibeteckning          | string  | Partiets namn           |
| partikod                 | string  | Partikod                |
| partiforkortning         | string  | Partiförkortning        |
| antalMandat              | integer | Totalt antal mandat     |
| antalMandatForegaendeVal | integer | Mandat föregående val   |
| forandringAntalMandat    | integer | Förändring antal mandat |

---

## Root.helaLandet.lan[].rostfordelning

Se Root.helaLandet.rostfordelning. Föregående och förändring finns inte med.

---
