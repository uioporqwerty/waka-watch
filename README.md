# Waka Watch

<a href="https://apps.apple.com/us/app/waka-watch/id1607453366" style="vertical-align: top;"> <img src="./App_Store_Badge.svg"/></a> <img src="https://tools-qr-production.s3.amazonaws.com/output/apple-toolbox/f8763eccc692e56079f3d459518d7e84/ffcf1aa29fa16f28c6cf3a758e476c39.png" style="width: 80px; height: 80px;">

[![Build and Deploy](https://github.com/uioporqwerty/waka-watch/actions/workflows/build.yml/badge.svg)](https://github.com/uioporqwerty/waka-watch/actions/workflows/build.yml)

Waka Watch is an iOS and Apple Watch® application for [Wakatime](https://wakatime.com). Wakatime provides metrics about your coding activity.

# Screenshots

![Loading Screen](./screenshots/Loading.png "Loading Screen")

![Connect Screen](./screenshots/Connect.png "Connect Screen")

![Summary Screen](./screenshots/Summary.png "Summary Screen")

![Leaderboard Screen](./screenshots/Leaderboard.png "Leaderboard Screen")

![Profile Screen](./screenshots/Profile.png "Prfoile Screen")

![Connected Companion App Screen](./screenshots/Connected-Phone.jpeg "Connected Companion App Screen")

## Technical Notes

Changes to the xcconfig require that the development version is symmetrically encrypted using the following command and the encrypted file committed to source control:

`gpg --symmetric --batch --yes --passphrase "$passphrase" --output ../Config.xcconfig.asc Config.xcconfig `
