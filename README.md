# genesis-core_v1

GenesisCore App / Functions monorepo scaffold (PR1).

## Documents
- [GenesisCore App 設計 v0.1](docs/genesiscore-app-design-v0.1.md)
- [TASKS](TASKS.md)
- [IMPLEMENTATION PLAN](IMPLEMENTATION_PLAN.md)

## Repository structure
- `app/`: Flutter app scaffold (Riverpod + go_router + 5-tab shell)
- `functions/`: Firebase Functions TypeScript scaffold
- `docs/`: design and spec docs

## App setup (Flutter)
1. Install Flutter SDK (stable).
2. `cd app`
3. `flutter pub get`
4. `flutter run`

## Functions setup
1. Install Node.js 20+
2. `cd functions`
3. `npm install`
4. `npm run build`
5. `npm run serve`

## Current status
Implemented in PR1:
- App architecture scaffold
- Dark GenesisCore theme
- Bottom tabs: Home / My Core / AI Chat / Log / Lab
- Firebase bootstrap placeholder
- Functions health endpoint scaffold

Out of scope in PR1:
- Future prediction
- Paid subscription processing
- SNS/community/avatar/voice/multilingual
