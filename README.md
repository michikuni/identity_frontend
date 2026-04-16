# TrustID — Identity Fabric Mobile App

Flutter mobile client cho **TrustID Identity Fabric Platform**, kết nối tới backend Spring Boot + Hyperledger Fabric để quản lý danh tính nhân viên trên blockchain.

---

## Tech Stack

| Layer | Thư viện |
|---|---|
| Navigation | `go_router ^17` |
| State Management | `flutter_bloc ^9` |
| HTTP Client | `dio ^5` |
| Dependency Injection | `get_it` + `injectable` |
| Secure Storage | `flutter_secure_storage` |
| Localization | Flutter gen-l10n (vi / en) |

---

## Cấu trúc dự án

```
lib/
├── core/
│   ├── di/               # Dependency injection (get_it + injectable)
│   ├── network/          # Dio client, API constants
│   ├── routes/           # GoRouter config (app_router.dart)
│   ├── storage/          # SecureStorage (token lưu trữ)
│   ├── themes/           # AppTheme, AppColors
│   └── utils/
├── data/
│   ├── datasources/      # Remote API calls (Dio)
│   ├── models/           # JSON <-> Entity mapping
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Pure Dart models
│   ├── repositories/     # Abstract interfaces
│   └── usecases/         # Business logic
├── l10n/                 # Localization (vi / en)
├── presentation/
│   ├── features/         # Man hinh + BLoC theo feature
│   │   ├── auth/         # Sign in, Sign up
│   │   ├── home/         # Dashboard
│   │   ├── profile/      # Thong tin ca nhan
│   │   ├── contract/     # Hop dong
│   │   ├── payroll/      # Luong
│   │   ├── ledger/       # Blockchain ledger
│   │   └── splash/       # Splash + auth guard
│   └── widgets/          # Widget dung chung
└── main.dart
```

---

## Routes

| Path | Man hinh | Ghi chu |
|---|---|---|
| `/` | SplashScreen | Kiem tra auth -> redirect |
| `/auth/sign-in` | SignInScreen | |
| `/auth/sign-up` | SignUpScreen | |
| `/app/home` | HomeScreen | Shell (bottom nav) |
| `/app/profile` | ProfileScreen | Shell |
| `/app/contract` | ContractScreen | Shell |
| `/app/payroll` | PayrollScreen | Shell |
| `/app/ledger` | LedgerScreen | Shell |

GoRouter tu dong redirect ve `/auth/sign-in` neu chua dang nhap (tru splash va auth routes).

---

## Cai dat & chay

### Yeu cau

- Flutter SDK `^3.11`
- Dart SDK `^3.11`
- Backend Spring Boot dang chay (xem `fabric-spring-backend/`)

### Buoc 1 — Cai dependencies

```bash
flutter pub get
```

### Buoc 2 — Cau hinh Base URL

Mo [lib/core/network/api_constants.dart](lib/core/network/api_constants.dart) va chinh `baseUrl`:

```dart
// Chay tren may that (cung mang WiFi)
static const String baseUrl = 'http://192.168.x.x:8080/api/v1';

// Chay tren Android Emulator
static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
```

### Buoc 3 — Build code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Buoc 4 — Chay app

```bash
flutter run
```

---

## Localization

App ho tro **Tieng Viet** (mac dinh) va **Tieng Anh**.
Cac file ARB nam trong `lib/l10n/`. Sau khi chinh sua chay lai:

```bash
flutter gen-l10n
```

---

## Ket noi Backend

Backend can chay tren **Windows** (khong phai WSL) hoac cau hinh port forwarding WSL2 -> Windows neu chay trong WSL.

```
Dien thoai that  -> WiFi -> IP Windows:8080 -> Spring Boot
Android Emulator -> 10.0.2.2:8080          -> Spring Boot
```

Dam bao Windows Firewall mo port 8080:

```cmd
netsh advfirewall firewall add rule name="Spring Boot 8080" dir=in action=allow protocol=TCP localport=8080
```
