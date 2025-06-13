# Gig Task Manager App – Flutter Developer Intern Assignment

## 📄 Overview

This is a task management mobile application built as part of the internship assignment for **Whatbytes**. The app is designed for gig workers to manage their tasks efficiently with features such as authentication, task CRUD operations, task filtering, and responsive UI design.

This submission demonstrates my skills in Flutter, state management using **Riverpod/BLoC**, and clean architecture principles.

---

## 🚀 Features Implemented

### ✅ User Authentication (via Firebase)
- Email/password registration and login
- Form validation and error messages for invalid credentials
- Firebase Authentication integration

### 📝 Task Management
- Create, edit, delete, and view tasks
- Task fields: Title, Description, Due Date, Priority (Low, Medium, High)
- Tasks stored using Firebase Cloud Firestore
- Toggle task status (Completed / Incomplete)

### 🔍 Task Filtering & Sorting
- Filter by priority and completion status
- Tasks sorted by due date (earliest to latest)

### 🎨 User Interface
- Clean, responsive UI based on Material Design
- Adaptive design for Android and iOS
- Follows best practices for spacing, typography, and color usage

---

## 🧱 Architecture

- **Flutter** for UI and logic
- **Clean Architecture** with domain, data, and presentation layers
- **Firebase Firestore** for backend data storage
- **Firebase Auth** for user authentication

---

## 📁 Folder Structure

```plaintext
lib/
├── core/
├── data/
├── domain/
├── presentation/
│   ├── screens/
│   ├── widgets/
├── main.dart
