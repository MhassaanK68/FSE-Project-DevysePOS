# DevysePOS - Modern Point of Sale System

---

## Important Disclaimer: 

> In-store point of sale is run on tablet form factors, not phones. The UI and flows are designed and tested for larger screens only.
>
> Do not expect phones or small, narrow devices to work well. Layout, touch targets, and navigation are not adapted for mobile-sized screens and may be broken or unusable there. Use an Android tablet (or desktop/web only for development convenience).
>
> However, if a tablet is unavailable, for testing purpose we recommend using the app in landscape mode for a better user experience

---

## Description
DevysePOS is an offline-first Point of Sale application designed for Android tablets. It allows retail businesses to manage sales, inventory, and categories without requiring a constant internet connection, using role-based access for Admins and Cashiers.

## Team Members
- Hassan Mehmood (24L-2559)
- Sufyan Sohail (24L-2601)
- Muaaz Fahad (24L-2563)

## Tech Stack
- **Backend:** ExpressJS API (Server)
- **Frontend:** Flutter / UI Components (Client)
- **Database:** SQLite (Client) and MySQL (Server)

---

## How to Run

### Flutter app (this repository)

The project root is the folder that contains `pubspec.yaml`.

1. **Prerequisites:** [Flutter SDK](https://docs.flutter.dev/get-started/install) matching the Dart SDK in `pubspec.yaml` (^3.10), plus tooling for your target (e.g. Android SDK for tablets, or a desktop/web device for local testing).

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Verify your environment:
   ```bash
   flutter doctor
   ```

4. List devices and run:
   ```bash
   flutter devices
   flutter run
   ```
   Use `flutter run -d <device_id>` to pick a specific device.

### Express API / MySQL (server)

The Express backend is part of the planned stack but is **not** included in this repository yet. Run instructions for the API will be added when the server code is published alongside this client.