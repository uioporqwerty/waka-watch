# Waka Watch

<a href="https://apps.apple.com/us/app/waka-watch/id1607453366" style="vertical-align: top;"> <img src="./App_Store_Badge.svg"/></a>  
<img src="https://tools-qr-production.s3.amazonaws.com/output/apple-toolbox/f8763eccc692e56079f3d459518d7e84/ffcf1aa29fa16f28c6cf3a758e476c39.png" style="width: 80px; height: 80px;">  
<a href="https://www.producthunt.com/posts/waka-watch?utm_source=badge-featured&utm_medium=badge&utm_souce=badge-waka&#0045;watch" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=355109&theme=dark" alt="Waka&#0032;Watch - WakaTime&#0032;Stats&#0032;on&#0032;Apple&#0032;Watch | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a>

[![Build and Deploy](https://github.com/uioporqwerty/waka-watch/actions/workflows/build.yml/badge.svg)](https://github.com/uioporqwerty/waka-watch/actions/workflows/build.yml)

Waka Watch is an iOS and Apple Watch® application for [Wakatime](https://wakatime.com). Wakatime provides metrics about your coding activity.

## Technical Notes

Changes to the xcconfig require that the development version is symmetrically encrypted using the following command and the encrypted file committed to source control:

`gpg --symmetric --batch --yes --passphrase "$passphrase" --output ../Config.xcconfig.asc Config.xcconfig`
