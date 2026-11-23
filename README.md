# 📸 PhotoKids Studio

<p align="center">
  <img src="assets/img/icon.png" alt="PhotoKids Studio Icon" width="160" style="border-radius: 36px; box-shadow: 0 10px 30px rgba(0,0,0,0.25);" />
</p>

[![Flutter Version](https://img.shields.io/badge/Flutter-3.50.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.14.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-brightgreen)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![State Management](https://img.shields.io/badge/State-Riverpod%202.x-blueviolet)](https://riverpod.dev)
[![Design](https://img.shields.io/badge/Design-Material%203-pink)](https://m3.material.io)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Eine moderne, familienfreundliche und kindgerechte Fotoverwaltungs- und Bildbearbeitungs-App, entwickelt mit **Flutter**, **Clean Architecture**, **Riverpod** und **Material Design 3**.

---

## 📖 Ausführliche Benutzeranleitung
👉 **Hier geht es zur vollständigen Schritt-für-Schritt-Anleitung:**  
[📘 Zur Offiziellen Benutzeranleitung (BENUTZERANLEITUNG.md)](BENUTZERANLEITUNG.md)

---

## 🌟 Über das Projekt

**PhotoKids Studio** wurde mit ganz viel Liebe von **Robert Hofer (Zürich, Schweiz 🇨🇭)** für seine Tochter Denis und die ganze Familie entworfen. Kinder können ihre Lieblingsfotos in einer sicheren, fröhlichen Umgebung eigenständig erkunden, organisieren und mit zauberhaften Werkzeugen kreativ bearbeiten.

Gleichzeitig bietet die App Eltern maximale Sicherheit durch einen **PIN-geschützten Elternbereich**, sodass keine Fotos unabsichtlich gelöscht oder Systemeinstellungen verändert werden können. Unter der Haube sorgt eine performante SQLite-Architektur mit Hintergrund-Isolates und Thumbnail-Caching dafür, dass selbst Sammlungen mit **über 10.000 Fotos** butterweich mit 60 FPS dargestellt werden.

---

## ✨ Hauptfunktionen im Überblick

### 🖼️ 1. Galerie & Organisation
* **Flexibles Grid & Zoom:** Stufenlose Auswahl von 2, 3 oder 4 Spalten – ideal für kleine Kinderhände und Tablets.
* **Listenansicht:** Übersichtliche Ansicht mit Dateinamen, Dateigröße, Format und Aufnahmedatum.
* **Sortierung & Suche:** Nach Datum, Name (A–Z), Dateigröße oder Favoriten zuerst sowie Live-Suchleiste.
* **Alben-System:** Eigene Alben mit bunten Emojis (🏖️, 🐶, 🎂, 🚀) erstellen.
* **Favoriten- & Papierkorb-Tabs:** Markiere Bilder als *Favoriten ⭐* oder stelle gelöschte Fotos innerhalb von **30 Tagen** wieder her.

### 🔍 2. Professioneller Bildviewer
* **Pinch-to-Zoom & Double-Tap:** Stufenlose Skalierung von 0.8x bis 5.0x via `InteractiveViewer`.
* **EXIF-Inspektor:** Auflösung, Format, Dateigröße und Aufnahmedatum auf einen Blick.
* **Vollbildmodus & Bilddrehung:** Automatische Ausblendung der Navigationselemente für ungestörtes Betrachten.
* **Direktzugriff:** Bearbeiten 🎨, Web-Größe 🌐 und Diashow 🎬 direkt am unteren Bildschirmrand.

### 🎨 3. Kreativer Studio-Editor
* **🖼️ Magische Bilderrahmen:** Handgezeichnete Vektor-Rahmen (*Einhorn Glitzer 🦄*, *Weltraum Rakete 🚀*, *Sommerstrand 🏖️*, *Geburtstagsparty 🎂*, *Zauberwald 🌸*, *Comic Hero 💥*).
* **🖍️ Malbuch-Modus:** Verwandelt jedes Foto in eine saubere schwarz-weiße Ausmalseite mit Stift-, Marker- und Pinsel-Unterstützung.
* **↔️ Vorher / Nachher Vergleich:** Interaktiver Split-Schieberegler `‹ 🔍 ›` zum direkten Vergleichen des Originals mit dem Kunstwerk.
* **💬 Comic-Sprechblasen:** Beliebte Express-Vorlagen (*„BÄM! 💥“*, *„Hallo! 👋“*, *„Wuff! 🐶“*, *„Hab dich lieb! ❤️“*) und eigene Sprechblasen.
* **⭐ Sticker-Paradies:** Verspielte Sticker (*Tiere*, *Herzen & Sterne*, *Blumen*, *Smileys*) – frei verschieb-, dreh- und skalierbar.
* **🌐 Web- & Social-Media Presets:** Optimierte 2026-Standards für Full HD (1920×1080), Blog/OpenGraph (1200×630), Insta-Post (1:1), Story (9:16), Fotoblog (3:2) und Header-Banner (2:1).
* **✂️ Zuschnitt & Farbkorrektur:** Formate (1:1, 4:3, 16:9, 9:16, 3:2, 2:1) sowie Helligkeit, Kontrast und Sättigung.
* **🎉 Konfetti-Feuerwerk:** Farbenfroher Partikel-Regen und haptisches Feedback bei jedem Speichern.

### 💌 4. 1-Klick Grußkarten & Druck
* Fertig formatierte Vorlagen für Oma & Opa ❤️, Mama & Papa 💖, Geburtstage 🎂 oder Feriengrüße 🏖️ mit Direktexport zum Drucken oder Verschicken per Messenger.

### 👧 5. Kindgerechte Ergonomie & Elternschutz
* **Material Design 3:** Buntes Farbschema mit Rosa, Türkis, Gelb und Violett.
* **Parental Gate:** Kindersicherung über Eltern-PIN oder mathematische Rechenaufgabe zur Absicherung kritischer Aktionen.
* **SafeArea-Kompatibel:** Zuverlässig optimiert gegen Überdeckungen durch Android-Systemleisten.

### ⏱️ 6. Diashow (Slideshow)
* Automatische Vollbild-Wiedergabe mit anpassbarer Geschwindigkeit (1 bis 10 Sekunden) und sanften Überblendungen.

---

## 👨‍💻 Über den Entwickler & Kontakt

* **Entwickler:** Robert Hofer
* **Wohnort:** Zürich, Schweiz 🇨🇭
* **E-Mail:** [robert.hofer.zuerich@bluewin.ch](mailto:robert.hofer.zuerich@bluewin.ch)
* **GitHub Repository:** [https://github.com/roberthoferzuerich-alt/PhotoKids-Studio.git](https://github.com/roberthoferzuerich-alt/PhotoKids-Studio.git)

> *„Und wenn Du möchtest, bist Du herzlich eingeladen!“*  
> Ob für Feedback, kreative Anregungen oder gemeinsame Projekte – ich freue mich über deine Nachricht!

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
└── shared/           # Wiederverwendbare Kinder-Widgets (KidButton, ParentalGateDialog, BeforeAfterSlider, Confetti)
```

### ⚡ Performance-Highlights
* **SQLite Indizierung:** Datenbank-Indizes auf `date_taken`, `album_id`, `flag` und `is_deleted` garantieren verzögerungsfreie Abfragen bei über 10.000 Fotos.
* **Isolate Processing:** Bildmanipulationen (Crop, Filter, Skalierung, Kanten-Extraktion) laufen in separaten Dart-Hintergrund-Threads (`compute()`), damit die UI flüssig bei 60/120 FPS bleibt.
* **Zweistufiger Thumbnail-Cache:** Kombination aus schnellem LRU-RAM-Speicher (200 Bilder) und Festplatten-Cache.

---

## 🚀 Erste Schritte / Installation

```bash
# 1. Repository klonen
git clone https://github.com/roberthoferzuerich-alt/PhotoKids-Studio.git
cd PhotoKids-Studio

# 2. Abhängigkeiten herunterladen
flutter pub get

# 3. Anwendung starten
flutter run
```

---

## 🧪 Tests & Qualitätssicherung

```bash
# Alle Tests ausführen (13/13 bestanden)
flutter test

# Statische Code-Analyse prüfen (0 Probleme)
flutter analyze
```

---

## 📄 Lizenz

Dieses Projekt ist unter der **MIT-Lizenz** lizenziert – siehe die [LICENSE](LICENSE)-Datei für Details.  
*Mit ❤️ entwickelt für Kinder und Familien.*
