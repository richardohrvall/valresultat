# Röstfördelning per valdistrikt

Övergripande beskrivning: Filen innehåller röstfördelning för samtliga valdistrikt som ingår i valområdet.
Dokumentationen skapad: 2026-04-17

---

## Root-objekt

| Fält                         | Typ     | Beskrivning                                            |
|------------------------------|---------|--------------------------------------------------------|
| valtillfalle                 | string  | Namn på valtillfälle                                   |
| valklass                     | string  | Ordinarie val , omval eller extra val                  |
| rakningstillfalle            | string  | preliminär eller slutlig                               |
| valtyp                       | string  | Typ av val (RD, RF, KF, E, S)                          |
| valdatum                     | string  | Valdatum t ex 2026-09-12                               |
| tidigareValdatum             | string  | Tidigare valdatum t ex 2022-09-11                      |
| test                         | boolean | Om true innehåller filen testdata, annars saknas denna |
| senasteUppdateringstid       | string  | Senaste uppdateringstid t ex 2026-03-26T15:29:34       |
| antalUppdateringar           | integer | Antal gånger filen skrivits över                       |
| antalValdistriktRaknade      | integer | Antal valdistrikt räknade                              |
| antalValdistriktSomSkaRaknas | integer | Antal valdistrikt som ska räknas                       |
| valdistrikt                  | array   | Array med information per valdistrikt                  |

---

## Root-objekt.valdistrikt[]

| Fält                              | Typ            | Beskrivning                                                 |
|-----------------------------------|----------------|-------------------------------------------------------------|
| namn                              | string         | Namn på valdistriktet                                       |
| valdistriktstyp                   | string         | Valdistrikt eller uppsamlingsdistrikt                       |
| rapporteringsTid                  | string         | Rapporterings tid t ex 2026-03-26T14:39:28                  |
| totaltAntalRoster                 | integer        | Totalt antal röster                                         |
| antalRostberattigade              | integer / null | Antal röstberattigade, är null för uppsamlingsdistrikt      |
| valdeltagandeVallokal             | number / null  | Valdeltagande i distriktet, är null för uppsamlingsdistrikt |
| valdistriktskod                   | string         | Kod för valdistriktet                                       |
| kommunkod                         | string         | Kommunkod                                                   |
| lankod                            | string         | Länkod                                                      |
| valomradeskod                     | string         | Kod för valområdet                                          |
| kretskod                          | string         | Valkretskod                                                 |
| kommunvalkretsNamn                | string         | Kommunvalkretsnamn                                          |
| kommunvalkretsKod                 | string         | Kommunvalkretskod                                           |
| valdistriktskodForegaendeVal      | string / null  | Valdistriktskod föregående val                              |
| totaltAntalRosterForegaendeVal    | integer / null | Totalt antal röster föregående val                          |
| antalRostberattigadeForegaendeVal | integer / null | Antal röstberattigade föregående val                        |
| valdeltagandeForegaendeVal        | number / null  | Valdeltagande föregående val                                |
| forandringTotaltAntalRoster       | integer / null | Förändring totalt antal röster                              |
| forandringValdeltagande           | number / null  | Förändring valdeltagande                                    |
| forandringAntalRostberattigade    | integer / null | Förändring antal röstberattigade                            |
| statusJamforelse                  | string         | Kan jämföras, kan ej jämföras, jämförs mot summerat         |
| rostfordelning                    | object         | Objekt som innehåller data över giltiga och ogiltiga röster |

---

## Root-objekt.valdistrikt[].rostfordelning

| Fält                  | Typ    | Beskrivning                                                                |
|-----------------------|--------|----------------------------------------------------------------------------|
| rosterPaverkaMandat   | object | Objekt som innehåller röster som påverka mandatfördelning (giltiga röster) |
| rosterEjPaverkaMandat | object | Objekt som innehåller ogiltiga röster                                      |

---

## Root-objekt.valdistrikt[].rostfordelning.rosterPaverkaMandat

| Fält                     | Typ            | Beskrivning                                                |
|--------------------------|----------------|------------------------------------------------------------|
| antalRoster              | integer        | Antal röster                                               |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val                                |
| forandringAntalRoster    | integer / null | Förändring antal röster                                    |
| partiRoster              | array          | Array innehållande information om röster på rapportpartier |
| rosterOvrigaPartier      | object         | Objekt innehållande röster på ej rapportpartier            |

---

## Root-objekt.valdistrikt[].rostfordelning.rosterPaverkaMandat.partiRoster[]

| Fält                     | Typ            | Beskrivning                                  |
|--------------------------|----------------|----------------------------------------------|
| partibeteckning          | string         | Partibeteckning                              |
| partiforkortning         | string         | Partiförkortning                             |
| partikod                 | string         | Kod för partiet                              |
| fargkod                  | string         | Färgkod                                      |
| ordningsnummer           | integer        | Ordningsnummer                               |
| antalRoster              | integer        | Antal röster                                 |
| andelRoster              | number         | Andel röster                                 |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val                  |
| andelRosterForegaendeVal | number / null  | Andel röster föregående val                  |
| forandringAntalRoster    | integer / null | Förändring antal röster                      |
| forandringAndelRoster    | number / null  | Förändring andel röster                      |
| listRoster               | array          | Partiets listor i valdistriktet              |
| summeradePersonroster    | array          | Array med summerade personröster för partiet |

## Root-objekt.valdistrikt[].rostfordelning.rosterPaverkaMandat.partiRoster[].listRoster[]

| Fält                     | Typ     | Beskrivning                                    |
|--------------------------|---------|------------------------------------------------|
| listnummer               | string  | Identitet för listan                           |
| antalRoster              | integer | Antal röster på listan                         |
| antalRosterMedPersonrost | integer | Antal personröster på listan                   |
| personroster             | array   | Array med kandidaternas personröster på listan |

---

## Root-objekt.valdistrikt[].rostfordelning.rosterPaverkaMandat.partiRoster[].listRoster[].personroster[]

| Fält                   | Typ     | Beskrivning                       |
|------------------------|---------|-----------------------------------|
| namn                   | string  | Kandidatens namn på listan        |
| kandidatNummerPaListan | integer | Kandidatens nummer på listan      |
| kandidatNummer         | integer | Unik identifierare                |
| antalPersonroster      | integer | Antal personröster för kandidaten |

---

## Root-objekt.valdistrikt[].rostfordelning.rosterPaverkaMandat.partiRoster[].summeradePersonroster[]

| Fält              | Typ     | Beskrivning                    |
|-------------------|---------|--------------------------------|
| namn              | string  | Kandidatens folkbokföringsnamn |
| kandidatnummer    | integer | Unik identifierare             |
| antalPersonroster | integer | Antal personröster             |

---

## Root-objekt.valdistrikt[].rostfordelning.rosterPaverkaMandat.rosterOvrigaPartier

| Fält                     | Typ            | Beskrivning                 |
|--------------------------|----------------|-----------------------------|
| antalRoster              | integer        | Antal röster                |
| andelRoster              | number         | Andel röster                |
| antalRosterForegaendeVal | integer / null | Antal röster föregående val |
| andelRosterForegaendeVal | number / null  | Andel röster föregående val |
| forandringAntalRoster    | integer / null | Förändring antal röster     |
| forandringAndelRoster    | number / null  | Förändring andel röster     |

---

## Root-objekt.valdistrikt[].rostfordelning.rosterEjPaverkaMandat

| Fält                                        | Typ            | Beskrivning                                                    |
|---------------------------------------------|----------------|----------------------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                                   |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                            |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                                    |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val             |
| forandringAntalRoster                       | integer / null | Förändring antal röster                                        |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster                 |
| rosterEjAnmaltDeltagande                    | object         | Objekt innehållande röster på partier som ej anmalt deltagande |
| blankaRoster                                | object         | Objekt innehållande blanka röster                              |
| ovrigaOgiltiga                              | object         | Objekt innehållande övriga ogiltiga röster                     |

---

## Root-objekt.valdistrikt[].rostfordelning.rosterEjPaverkaMandat.rosterEjAnmaltDeltagande

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |

---

## Root-objekt.valdistrikt[].rostfordelning.rosterEjPaverkaMandat.blankaRoster

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |

---

## Root-objekt.valdistrikt[].rostfordelning.rosterEjPaverkaMandat.ovrigaOgiltiga

| Fält                                        | Typ            | Beskrivning                                        |
|---------------------------------------------|----------------|----------------------------------------------------|
| antalRoster                                 | integer        | Antal röster                                       |
| andelRosterAvTotaltAntalRoster              | number         | Andel röster av totalt antal röster                |
| antalRosterForegaendeVal                    | integer / null | Antal röster föregående val                        |
| andelRosterAvTotaltAntalRosterForegaendeVal | number / null  | Andel röster av totalt antal röster föregående val |
| forandringAntalRoster                       | integer / null | Förändring antal röster                            |
| forandringAndelRosterAvTotaltAntalRoster    | number / null  | Förändring andel röster av totalt antal röster     |

---
