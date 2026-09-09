# Överordnad summering – röst- och mandatfördelning

Övergripande beskrivning: Sammanställning av resultatet för kommunval i hela Sverige.
Dokumentationen skapad: 2026-04-14

---

## Root-objekt

| Fält                         | Typ     | Beskrivning                                      |
|------------------------------|---------|--------------------------------------------------|
| valtillfalle                 | string  | Valtillfälle som röstfördelningen avser          |
| valklass                     | string  | ordinarie val, extraval eller omval              |
| rakningstillfalle            | string  | preliminär eller slutlig                         |
| valtyp                       | string  | KF                                               |
| valdatum                     | string  | Valdatum t ex 2026-09-13                         |
| tidigareValdatum             | string  | Tidigare valdatum t ex 2022-09-11                |
| test                         | boolean | Om true innehåller filen testdata                |
| senasteUppdateringstid       | string  | Senaste uppdateringstid t ex 2026-03-26T15:29:34 |
| antalUppdateringar           | integer | Antal gånger denna fil skrivits över             |
| antalValdistriktRaknade      | integer | Antal valdistrikt räknade                        |
| antalValdistriktSomSkaRaknas | integer | Antal valdistrikt som ska räknas                 |
| helaLandet                   | object  | Summering för riket                              |

---

## Root.helaLandet

| Fält                                    | Typ     | Beskrivning                                                   |
|-----------------------------------------|---------|---------------------------------------------------------------|
| namn                                    | string  | Riket                                                         |
| senasteRapporteringstid                 | string  | Senaste rapporteringstid för ett distrikt i riket             |
| totaltAntalMandat                       | integer | Summan av alla mandat i regionerna/kommunerna                 |
| antalValdistriktRaknade                 | integer | Antal räknade valdistrikt                                     |
| antalValdistriktSomSkaRaknas            | integer | Antal valdistrikt som ska räknas                              |
| totaltAntalRoster                       | integer | Totalt antal röster                                           |
| antalRostberattigade                    | integer | Antal röstberättigade                                         |
| antalRostberattigadeIRaknadeValdistrikt | integer | Antal röstberättigade i räknade distrikt                      |
| valdeltagande                           | number  | Andel röster / antal röstberättigade                          |
| totaltAntalMandatForegaendeVal          | integer | Summan av alla mandat i regionerna, förra valet               |
| totaltAntalRosterForegaendeVal          | integer | Antal röster, förra valet                                     |
| antalRostberattigadeForegaendeVal       | integer | Antal röstberättigade, förra valet                            |
| valdeltagandeForegaendeVal              | number  | Valdeltagande föregående vaö                                  |
| forandringTotaltAntalRoster             | integer | Antal röster innevarande val - antal röster föregående val    |
| forandringValdeltagande                 | number  | Förändring i valdeltagande                                    |
| forandringAntalRostberattigade          | integer | Förändring i antal röstberättigade                            |
| statusJamforelse                        | string  | Kan alltid jämföras (hela landet)                             |
| rostfordelning                          | object  | Som i filen röstfördelning, men aggregerat över hela landet   |
| mandatfordelning                        | object  | Som i filen mandatfördelning, men aggregerat över hela landet |
| lan                                     | array   | Array med aggregerad länsdata (endast för KF)                 |

---

## Root.helaLandet.lan[]

| Fält                                    | Typ     | Beskrivning                                                  |
|-----------------------------------------|---------|--------------------------------------------------------------|
| namn                                    | string  | Namn på länet                                                |
| lankod                                  | string  | Länets kod                                                   |
| senasteRapporteringstid                 | string  | Senaste rapporteringstid för ett distrikt i länet            |
| totaltAntalMandat                       | integer | Summan av alla mandat i kommunerna i länet                   |
| antalValdistriktRaknade                 | integer | Antal räknade valdistrikt                                    |
| antalValdistriktSomSkaRaknas            | integer | Antal valdistrikt som ska räknas                             |
| totaltAntalRoster                       | integer | Totalt antal röster                                          |
| antalRostberattigade                    | integer | Antal röstberättigade                                        |
| valdeltagande                           | number  | Antal röstberättigade i räknade distrikt                     |
| antalRostberattigadeIRaknadeValdistrikt | integer | Andel röster / antal röstberättigade                         |
| totaltAntalMandatForegaendeVal          | integer | Summan av alla mandat i kommunerna, förra valet              |
| totaltAntalRosterForegaendeVal          | integer | Antal röster, förra valet                                    |
| antalRostberattigadeForegaendeVal       | integer | Antal röstberättigade, förra valet                           |
| valdeltagandeForegaendeVal              | number  | Valdeltagande föregående val                                 |
| forandringTotaltAntalRoster             | integer | Antal röster innevarande val - antal röster föregående val   |
| forandringValdeltagande                 | number  | Förändring i valdeltagande                                   |
| forandringAntalRostberattigade          | integer | Förändring i antal röstberättigade                           |
| statusJamforelse                        | string  | Kan jämföras / kan ej jämföras                               |
| rostfordelning                          | object  | Som i filen röstfördelning, men aggregerat över hela länet   |
| mandatfordelning                        | object  | Som i filen mandatfördelning, men aggregerat över hela länet |
| kommuner                                | array   | Array med aggregerad kommundata                              |

---

## Root.helaLandet.lan[].kommuner[]

| Fält           | Typ    | Beskrivning               |
|----------------|--------|---------------------------|
| namn           | string | Kommunens namn            |
| kommunkod      | string | Kommunens kod             |
| rostfordelning | object | Röstfördelning i kommunen |

---

## Root.helaLandet.rostfordelning

| Fält                  | Typ    | Beskrivning                                |
|-----------------------|--------|--------------------------------------------|
| rosterPaverkaMandat   | object | Röster påverka mandat (giltiga röster)     |
| rosterEjPaverkaMandat | object | Röster ej påverka mandat (ogiltiga röster) |

---

## Root.helaLandet.rostfordelning.rosterPaverkaMandat

| Fält                     | Typ     | Beskrivning                                  |
|--------------------------|---------|----------------------------------------------|
| antalRoster              | integer | Antal röster                                 |
| antalRosterForegaendeVal | null    | Antal röster föregående val                  |
| forandringAntalRoster    | null    | Förändring antal röster                      |
| partiRoster              | array   | Röster per parti                             |
| rosterOvrigaPartier      | object  | Röster övriga partier, dvs ej rapportpartier |

---

## Root.helaLandet.rostfordelning.rosterPaverkaMandat.partiRoster[]

| Fält                     | Typ            | Beskrivning                 |
|--------------------------|----------------|-----------------------------|
| partibeteckning          | string         | Partibeteckning             |
| partiforkortning         | string         | Partiförkortning            |
| partikod                 | string         | Kod för partiet             |
| fargkod                  | string         | Färgkod                     |
| ordningsnummer           | integer        | Ordningsnummer              |
| antalRoster              | integer        | Antal röster                |
| andelRoster              | number         | Andel röster                |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val |
| andelRosterForegaendeVal | number / null  | Andel röster föregående val |
| forandringAntalRoster    | integer / null | Förändring antal röster     |
| forandringAndelRoster    | number / null  | Förändring andel röster     |

---

## Root.helaLandet.rostfordelning.rosterPaverkaMandat.rosterOvrigaPartier

| Fält                     | Typ            | Beskrivning                 |
|--------------------------|----------------|-----------------------------|
| antalRoster              | integer        | Antal röster                |
| andelRoster              | number         | Andel röster                |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val |
| andelRosterForegaendeVal | number / null  | Andel röster föregående val |
| forandringAntalRoster    | integer / null | Förändring antal röster     |
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
| rosterEjAnmaltDeltagande                    | object         | Röster på partier som ej anmalt deltagande         |
| blankaRoster                                | object         | Antal blanka röster                                |
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

| Fält       | Typ   | Beskrivning                                 |
|------------|-------|---------------------------------------------|
| partiLista | array | Mandat per parti i alla valområden i landet |

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

Se Root.helaLandet.rostfordelning

---

## Root.helaLandet.lan[].mandatfordelning

Se Root.helaLandet.rostfordelning

---

## Root.helaLandet.lan[].kommuner[].rostfordelning

Se Root.helaLandet.rostfordelning. Föregående och förändring finns inte med.

---
