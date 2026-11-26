# Inventory App

An inventory and sales management app for small shops, built with Flutter and Firebase.
It supports two roles, admin and seller, with a dashboard, product management, and cart-based sales.

## Features

- Two roles, admin and seller, each with its own permissions.
- Product management: add, edit, hide, and low-stock alerts.
- Cart-based sales with automatic stock updates and sale cancellation.
- Admin dashboard with daily and monthly sales and profit.

## Tech Stack

- Flutter (Dart) for the user interface.
- Firebase Authentication and Cloud Firestore for sign-in and data storage.
- Provider for state management.

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/mohamad-mobarak/inventory_app.git
   cd inventory_app
   ```

2. Create your own Firebase project, enable **Authentication** (Email/Password) and **Firestore**, then add a **Web** app to it. Then copy the security rules from `firestore.rules` and paste them into the **Rules** tab in Firestore, then click **Publish**.
3. Copy `lib/firebase_options.example.dart` to `lib/firebase_options.dart` and paste your own keys: `apiKey`, `appId`, `messagingSenderId`, `projectId`, `authDomain`.
4. Install the dependencies and run the app:

   ```bash
   flutter pub get
   flutter run -d chrome
   ``` 

 
## Live Demo

🔗 https://inventory-app-demo-9e152.web.app

| Role   | Email                    | Password |
|--------|--------------------------|----------|
| Admin  | demo-admin@example.com   | 000111   |
| Seller | demo-seller@example.com  | 000111   |


## Download Android APK

[Download APK](https://github.com/mohamad-mobarak/inventory_app/releases/download/v1.0.0/inventory-app-v1.0.0.apk)
