# Pin npm packages by running ./bin/importmap

pin "application"
pin "videojs", to: "https://unpkg.com/video.js@8.3.0/dist/video.min.js"
pin_all_from "app/javascript/custom", under: "custom"