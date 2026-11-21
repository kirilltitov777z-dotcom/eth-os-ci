# eth-os CI

Сборкаopensource-чита [ethereal-sol/eth-os](https://github.com/ethereal-sol/eth-os)
(qazaqdlc, C++ / ARM64) через GitHub Actions — без Android Studio на телефоне.

## Как работает

Workflow `.github/workflows/build.yml`:

1. качает исходники eth-os напрямую из upstream-репозитория;
2. ставит JDK 17, Gradle 8.7, Android SDK 34 и NDK 22.0.7026061;
3. запускает `scripts/prepare.sh` — он чинит известные проблемы upstream:
   - создаёт `settings.gradle` (без него модуль `qazaqdlc` не включается в сборку),
   - меняет закрытый `jcenter()` на `mavenCentral()`, AGP 7.0 → 8.3,
   - добавляет `namespace` и обновляет `compileSdk`,
   - убирает ссылку на несуществующую иконку в манифесте,
   - исправляет регистр `KittyUtils.cpp` и путь `utilities` (важно для Linux);
4. собирает `gradle assembleDebug` (gradle + ndk-build);
5. кладёт APK и `libqazaqdlc.so` в Artifacts и публикует Release.

## Запуск

- Нажми **Actions → Build eth-os (qazaqdlc) via CI → Run workflow**, либо
- сделай `git push` в `main` — сборка стартует автоматически. Есть также
  ежедневный ночной запуск.

Результат: вкладка **Releases** или **Artifacts → eth-os-build**.

> Сборка идёт в облаке, исходники чита в этом репозитории не хранятся —
> только скрипты prepare и workflow. Если upstream изменит структуру,
> правки вносятся в `scripts/prepare.sh`.
