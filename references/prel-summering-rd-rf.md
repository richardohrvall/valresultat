# Röstfördelning - summering

Övergripande beskrivning: Filen innehåller röstfördelning för riksdags- eller regionval uppdelat per kommun.
Dokumentationen skapad: 2026-04-14

---

## Root-objekt

| Fält                         | Typ     | Beskrivning                                                       |
|------------------------------|---------|-------------------------------------------------------------------|
| valtillfalle                 | string  | Valtillfälle som röstfördelningen avser                           |
| valklass                     | string  | Ordinarie val, omval eller extraval                               |
| rakningstillfalle            | string  | preliminär eller slutlig                                          |
| valtyp                       | string  | RD eller RF                                                       |
| valdatum                     | string  | Valdatum t ex 2026-09-13                                          |
| tidigareValdatum             | string  | Föregående ordinarie valdatum t ex 2022-09-11                     |
| test                         | boolean | Om true så innehåller filen testdata, om false skrivs denna ej ut |
| senasteUppdateringstid       | string  | Senaste uppdateringstid t ex 2026-03-26T15:29:34                  |
| antalUppdateringar           | integer | Antal uppdateringar                                               |
| antalValdistriktRaknade      | integer | Antal valdistrikt raknade                                         |
| antalValdistriktSomSkaRaknas | integer | Antal valdistrikt som ska raknas                                  |
| kommuner                     | array   | Lista med kommuner                                                |

---

## Root-objekt.kommuner[]

| Fält                                    | Typ     | Beskrivning                                                              |
|-----------------------------------------|---------|--------------------------------------------------------------------------|
| senasteUppdateringstid                  | string  | Tidpunkt då filen senast uppdaterades                                    |
| senasteRapporteringstid                 | string  | Tidpunkt för senaste rapportering                                        |
| totaltAntalRoster                       | integer | Totalt antal avgivna röster i kommunen                                   |
| antalRostberattigade                    | integer | Antal röstberättigade i kommunen                                         |
| valdeltagande                           | number  | Valdeltagande i procent                                                  |
| antalRostberattigadeIRaknadeValdistrikt | integer | Antal röstberättigade i räknade valdistrikt                              |
| antalValdistriktRaknade                 | integer | Antal valdistrikt som har räknats                                        |
| antalValdistriktSomSkaRaknas            | integer | Totalt antal valdistrikt som ska räknas                                  |
| totaltAntalRosterForegaendeVal          | integer | Totalt antal avgivna röster i föregående val                             |
| antalRostberattigadeForegaendeVal       | integer | Antal röstberättigade i föregående val                                   |
| valdeltagandeForegaendeVal              | number  | Valdeltagande i föregående val                                           |
| forandringTotaltAntalRoster             | integer | Förändring i totalt antal röster                                         |
| forandringValdeltagande                 | number  | Förändring i valdeltagande                                               |
| forandringAntalRostberattigade          | integer | Förändring i antal röstberättigade                                       |
| namn                                    | string  | Namn på kommunen                                                         |
| kommunkod                               | string  | Kod för kommunen                                                         |
| lankod                                  | string  | Kod för länet                                                            |
| statusJamforelse                        | string  | Kan jämföras / Kan ej jämföras                                           |
| rostfordelning                          | object  | Röstfördelning för kommunen                                              |
| kommunvalkretsar                        | array   | Lista med kommunvalkretsar inom kommunen, om kommunen är valkretsindelad |

---

## Root-objekt.kommuner[].kommunvalkretsar[]

Objektet förekommer endast för kommuner som är indelade i kommunvalkretsar.

| Fält                                    | Typ     | Beskrivning                                      |
|-----------------------------------------|---------|--------------------------------------------------|
| namn                                    | string  | Namn på kommunvalkretsen                         |
| kod                                     | string  | Kod för kommunvalkretsen                         |
| senasteUppdateringstid                  | string  | Tidpunkt då filen senast uppdaterades            |
| senasteRapporteringstid                 | string  | Tidpunkt för senaste rapportering                |
| totaltAntalRoster                       | integer | Totalt antal avgivna röster i kommunvalkretsen   |
| antalRostberattigade                    | integer | Antal röstberättigade i kommunvalkretsen         |
| valdeltagande                           | number  | Valdeltagande i procent                          |
| antalRostberattigadeIRaknadeValdistrikt | integer | Antal röstberättigade i räknade valdistrikt      |
| antalValdistriktRaknade                 | integer | Antal valdistrikt som har räknats                |
| antalValdistriktSomSkaRaknas            | integer | Totalt antal valdistrikt som ska räknas          |
| totaltAntalRosterForegaendeVal          | integer | Totalt antal avgivna röster i föregående val     |
| antalRostberattigadeForegaendeVal       | integer | Antal röstberättigade i föregående val           |
| valdeltagandeForegaendeVal              | number  | Valdeltagande i föregående val                   |
| forandringTotaltAntalRoster             | integer | Förändring i totalt antal röster                 |
| forandringValdeltagande                 | number  | Förändring i valdeltagande                       |
| forandringAntalRostberattigade          | integer | Förändring i antal röstberättigade               |
| statusJamforelse                        | string  | Anger om jämförelse med föregående val är möjlig |
| rostfordelning                          | object  | Röstfördelning för kommunvalkretsen              |

---

## Root-objekt.kommuner[].rostfordelning

Samma modell används för både kommun och kommunvalkrets.

| Fält                  | Typ    | Beskrivning                                                |
|-----------------------|--------|------------------------------------------------------------|
| rosterPaverkaMandat   | object | Röster som påverkar mandatfördelningen, giltiga röster     |
| rosterEjPaverkaMandat | object | Röster som ej påverkar mandatfördelningen, ogiltiga röster |

---

## Root-objekt.kommuner[].rostfordelning.rosterPaverkaMandat

| Fält                     | Typ            | Beskrivning                                                   |
|--------------------------|----------------|---------------------------------------------------------------|
| antalRoster              | integer        | Antal röster                                                  |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val                                   |
| forandringAntalRoster    | number / null  | Förändring antal röster                                       |
| partiRoster              | array          | Partiröster                                                   |
| rosterOvrigaPartier      | object         | Röster övriga partier, dvs partier som inte är rapportpartier |

---

## Root-objekt.kommuner[].rostfordelning.rosterPaverkaMandat..partiRoster[]

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

## Root-objekt.kommuner[].rostfordelning.rosterPaverkaMandat.rosterOvrigaPartier

| Fält                     | Typ            | Beskrivning                 |
|--------------------------|----------------|-----------------------------|
| antalRoster              | integer        | Antal röster                |
| andelRoster              | number         | Andel röster                |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val |
| andelRosterForegaendeVal | number / null  | Andel röster föregående val |
| forandringAntalRoster    | integer / null | Förändring antal röster     |
| forandringAndelRoster    | number / null  | Förändring andel röster     |

---

## Root-objekt.kommuner[].rostfordelning.rosterEjPaverkaMandat

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |
| rosterEjAnmaltDeltagande                    | object         | Röster på partier som ej anmalt deltagande         |
| blankaRoster                                | object         | Blanka röster                                      |
| ovrigaOgiltiga                              | object         | Övriga ogiltiga röster                             |

---

## Root-objekt.kommuner[].rostfordelning.rosterEjAnmaltDeltagande

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |

---

## Root-objekt.kommuner[].rostfordelning.rosterEjPaverkaMandat.blankaRoster

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |

---

## Root-objekt.kommuner[].rostfordelning.ovrigaOgiltiga

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |

---

## Root-objekt.kommuner[].kommunvalkretsar[].rostfordelning

Se Root-objekt.kommuner[].rostfordelning

---
