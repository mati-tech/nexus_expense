// web/flutter_bootstrap.js
window.addEventListener('load', function(ev) {
  _flutter.loader.loadEntrypoint({
    entrypointUrl: "main.dart.js?" + new Date().getTime(),
    serviceWorker: {
      serviceWorkerVersion: null,  // Disables service worker
    }
  });
});