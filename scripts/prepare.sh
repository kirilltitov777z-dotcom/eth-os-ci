#!/usr/bin/env bash
# Готовит исходники ethereal-sol/eth-os к сборке в CI.
# Вызывается из корня чекаута upstream-репозитория.
set -euo pipefail

ROOT="upstream/ethereal - os"
[ -d "$ROOT" ] || { echo "Не найдена папка '$ROOT'"; exit 1; }

# 1. Без settings.gradle Gradle не видит модуль qazaqdlc
cat > "$ROOT/settings.gradle" <<'EOF'
rootProject.name = 'eth-os-ci'
include ':qazaqdlc'
EOF

# 2. jcenter() закрыт, AGP 7.0 слишком стар для Gradle 8
sed -i 's/jcenter()/mavenCentral()/g' "$ROOT/build.gradle"
sed -i "s/com.android.tools.build:gradle:7.0.0/com.android.tools.build:gradle:8.3.0/" "$ROOT/build.gradle"

# 3. Актуализируем конфиг модуля (AGP 8 требует namespace)
MOD="$ROOT/qazaqdlc/build.gradle"
sed -i 's/compileSdkVersion 30/compileSdk 34/' "$MOD"
sed -i "/android {/a\\    namespace 'qazaq.dlc'" "$MOD"

# 4. В репозитории нет res/mipmap, а манифест ссылается на иконку
MAN="$ROOT/qazaqdlc/src/main/AndroidManifest.xml"
sed -i '/android:icon="@mipmap\/qazaqdlc"/d' "$MAN"

# 5. Регистр имени файла в upstream не совпадает с Linux-ФС
INC="$ROOT/qazaqdlc/src/main/jni/includes.hpp"
sed -i 's/Kittyutils\.cpp/KittyUtils.cpp/' "$INC"

# 6. Путь include с заглавной буквы (на Linux папка называется utilities)
MK="$ROOT/qazaqdlc/src/main/jni/Android.mk"
sed -i 's#$(LOCAL_PATH)/Utilities#$(LOCAL_PATH)/utilities#' "$MK"

echo "Исходники eth-os подготовлены к сборке"
