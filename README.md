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


## Screenshots

<table>
<tr>
<td><img width="250" alt="Dashboard" src="https://github.com/user-attachments/assets/e52434f4-4cc7-441d-8072-4dfebc0b4f75" /></td>
<td><img width="250" alt="Products" src="https://github.com/user-attachments/assets/6b4a779f-80a7-4e4e-bc6a-864089c16c08" /></td>
</tr>
<tr>
<td><img width="250" alt="Sell and cart" src="https://github.com/user-attachments/assets/02c05f10-fb44-4f72-9231-eab1195973d7" /></td>
<td><img width="250" alt="Sales history" src="https://github.com/user-attachments/assets/595f0f65-bb41-474b-9ae0-d9c21fc2d3b6" /></td>
</tr>
</table>

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
