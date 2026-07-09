importScripts("/scram/scramjet.all.js");

const { ScramjetServiceWorker } = $scramjetLoadWorker();
const scramjet = new ScramjetServiceWorker();

// Take over promptly so the proxied iframe is always SW-controlled rather than
// racing a network fetch (which Traefik 404s, and which the frame can't render).
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));

async function handleRequest(event) {
	await scramjet.loadConfig();
	if (scramjet.route(event)) {
		return scramjet.fetch(event);
	}
	return fetch(event.request);
}

self.addEventListener("fetch", (event) => {
	const url = new URL(event.request.url);
	const sameOrigin = url.origin === location.origin;

	// Let Authentik forward-auth (cookie + redirect based) and the app-shell
	// navigation reach the network untouched. Scramjet's blanket fetch()
	// passthrough mangles the SSO handshake, which loops re-auth and blanks the
	// proxied frame. Everything scramjet actually proxies lives under /scramjet/.
	if (
		sameOrigin &&
		(url.pathname.startsWith("/outpost.goauthentik.io/") ||
			(event.request.mode === "navigate" &&
				!url.pathname.startsWith("/scramjet/")))
	) {
		return;
	}

	event.respondWith(handleRequest(event));
});
