# 📸 PhotoKids Studio

[![Flutter Version](https://img.shields.io/badge/Flutter-3.50.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.14.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-brightgreen)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![State Management](https://img.shields.io/badge/State-Riverpod%202.x-blueviolet)](https://riverpod.dev)
[![Design](https://img.shields.io/badge/Design-Material%203-pink)](https://m3.material.io)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Eine moderne, familienfreundliche und kindgerechte Fotoverwaltungs- und Bildbearbeitungs-App, entwickelt mit **Flutter**, **Clean Architecture**, **Riverpod** und **Material Design 3**.

---

## 🌟 Über das Projekt

**PhotoKids Studio** wurde mit Liebe für Kinder und Familien entworfen. Kinder können ihre Lieblingsfotos in einer sicheren, fröhlichen Umgebung eigenständig erkunden, organisieren und mit lustigen Werkzeugen kreativ bearbeiten.

Gleichzeitig bietet die App Eltern maximale Sicherheit durch einen **PIN-geschützten Elternbereich**, sodass keine Fotos unabsichtlich gelöscht oder Systemeinstellungen verändert werden können. Unter der Haube sorgt eine performante SQLite-Architektur mit Hintergrund-Isolates und Thumbnail-Caching dafür, dass selbst Sammlungen mit **über 10.000 Fotos** flüssig mit 60 FPS dargestellt werden.

---

## ✨ Hauptfunktionen

### 🖼️ 1. Galerie & Organisation
* **Flexibles Grid & Zoom:** Stufenloser Zoom von 2 bis 6 Spalten – ideal für kleine Kinderhände und Tablets.
* **Listenansicht:** Übersichtliche Ansicht mit Dateinamen, Dateigröße, Format und Aufnahmedatum.
* **Sortierung:** Nach Datum (neueste/älteste), Name (A–Z / Z–A), Dateigröße oder Favoriten zuerst.
* **Schnellsuche:** Live-Filterung nach Dateinamen, Kategorien und Schlagwörtern (Tags).
* **Alben-System:** Alben mit fröhlichen Emojis (🏖️, 🐶, 🎂, 🚀) erstellen und Fotos per Fingertipp zuordnen.
* **Favoriten-Markierung:** Markiere Bilder als *Favorit ⭐*, *Wichtig 📌* oder *Später bearbeiten 🎨*.

### 🔍 2. Professioneller Bildviewer
* **Pinch-to-Zoom & Double-Tap:** Stufenlose Skalierung von 0.8x bis 5.0x via `InteractiveViewer`.
* **EXIF-Inspektor:** Auf einen Klick technische Details wie Auflösung, Format, Dateigröße und Aufnahmedatum einsehen.
* **Vollbildmodus & Bilddrehung:** Automatische Ausblendung der Navigationselemente für ungestörtes Betrachten.
* **Teilen-Funktion:** Sicheres Teilen via WhatsApp, E-Mail, AirDrop oder Messenger.

### 🎨 3. Kreativer Studio-Editor
* **✂️ Zuschneiden (Crop):** Standardformate (Frei, 1:1 Quadrat, 4:3, 16:9 Breitbild, 3:2 Fotoformat).
* **🖌️ Zeichenmodus:** Stift, Marker, Pinsel und Radiergummi mit bunter Farbpalette, Pinselgrößen-Regler und Deckkraft.
* **🔤 Textwerkzeug:** Freie Textplatzierung mit anpassbaren Schriftfarben und Schlagschatten.
* **⭐ Sticker-System:** Verspielte Sticker-Kategorien (*Tiere 🐶*, *Herzen & Sterne 💖*, *Blumen 🌸*, *Smileys 😊*) – frei verschieb-, dreh- und skalierbar.
* **🪄 Filter & Effekte:** Schnellauswahl beliebter Filter (*KidsPop*, *Vintage*, *Schwarz/Weiß*, *Cool*, *Warm*).
* **⚙️ Farbkorrektur:** Feine Justierung von Helligkeit, Kontrast und Farbsättigung.
* **🔄 Drehen & Spiegeln:** 90°-Schritte sowie horizontale/vertikale Spiegelung.
* **↩️ Undo / Redo:** Jeder Pinselstrich kann unbegrenzt rückgängig gemacht oder wiederholt werden.

### 👧 4. Kindgerechte Ergonomie & Elternschutz
* **Bunte Material 3 Oberfläche:** Fröhliches Farbschema mit Rosa, Türkis, Gelb und Violett.
* **Große Touch-Targets:** Haptisch ansprechende Buttons mit runden Formen (BorderRadius 24+).
* **Parental Gate:** Kindersicherung über Eltern-PIN oder mathematische Rechenaufgabe zur Absicherung kritischer Aktionen.
* **30-Tage-Papierkorb:** Gelöschte Fotos werden für 30 Tage mit Tagescountdown sicher aufbewahrt und können jederzeit wiederhergestellt werden.

### ⏱️ 5. Diashow (Slideshow)
* Automatische Wiedergabe mit anpassbarer Geschwindigkeit (1 bis 10 Sekunden) und sanften Überblendungen.

---

## 🏛️ Architektur & Technische Details

Die Anwendung folgt strikt den Prinzipien der **Clean Architecture** mit Feature-First Modularisierung:

```
lib/
├── core/             # Theme, Constants, GoRouter, DatabaseService, Di
├── data/             # SQLite DataSources, SharedPreferences, Models & Repository-Impls
├── domain/           # Entities (Photo, Album, Editor-Models) & Repository-Interfaces
├── features/         # Features (Gallery, Viewer, Editor, Albums, Slideshow, Settings, Cloud)
├── services/         # ImageProcessing (Isolates), ThumbnailCache (RAM/Disk), Cloud, AI Vision
└── shared/           # Wiederverwendbare Kinder-Widgets (KidButton, ParentalGateDialog)
```

### ⚡ Performance-Highlights
* **SQLite Indizierung:** Datenbank-Indizes auf `date_taken`, `album_id`, `flag` und `is_deleted` garantieren verzögerungsfreie Abfragen bei über 10.000 Fotos.
* **Isolate Processing:** Bildmanipulationen (Crop, Filter, Skalierung) laufen in separaten Dart-Hintergrund-Threads (`compute()`), damit die UI butterweich bei 60/120 FPS bleibt.
* **Zweistufiger Thumbnail-Cache:** Kombination aus schnellem LRU-RAM-Speicher (200 Bilder) und Festplatten-Cache.
* **Zukunftssicher:** Vorbereitet für **Multi-Cloud-Sync (V2)** (OneDrive, Google Drive, Dropbox, iCloud) und **On-Device KI-Vision (V3)** (Auto-Tagging, Objekterkennung, Duplikatsuche, Hintergrund entfernen).

---

## 🚀 Erste Schritte / Installation

### Voraussetzungen
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (Version >= 3.50.0 empfohlen)
* Dart SDK >= 3.14.0
* Android Studio / Xcode / VS Code

### Projekt einrichten

```bash
# 1. Repository klonen
git clone https://github.com/dein-benutzername/PhotoKids-Studio.git
cd PhotoKids-Studio

# 2. Abhängigkeiten herunterladen
flutter pub get

# 3. Anwendung starten
flutter run
```

*Hinweis:* Beim ersten Start erzeugt die App automatisch bunte Demobilder und Alben über den integrierten `SampleDataSeeder`, sodass die Funktionen sofort ohne manuelle Bildimporte ausprobiert werden können.

---

## 🧪 Tests & Qualitätssicherung

Das Projekt verfügt über eine umfassende Suite von Unit- und Widget-Tests:

```bash
# Alle Tests ausführen
flutter test

# Statische Code-Analyse prüfen
flutter analyze
```

---

## 📱 Unterstützte Plattformen

* ✅ **Android** (Smartphones & Tablets)
* ✅ **iOS** (iPhone & iPad)
* ✅ **Web** (CanvasKit / WebAssembly)
* 🔜 **Desktop** (Windows, macOS, Linux)

---

## 📄 Lizenz

Dieses Projekt ist unter der **MIT-Lizenz** lizenziert – siehe die [LICENSE](LICENSE)-Datei für Details.
Mit ❤️ entwickelt für Kinder und Familien.
