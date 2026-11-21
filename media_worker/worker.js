/**
 * mhn-media — the only way into the image bucket (R2 "mhn-images").
 *
 * The bucket is bound to this Worker as BUCKET, so no API key exists
 * anywhere. Reading images is public (the bucket's r2.dev / custom-domain
 * URL); writing goes through here and needs a Firebase ID token:
 *
 *   PUT    /<key>   body = the image bytes, Content-Type = image/*
 *   DELETE /<key>
 *   Authorization: Bearer <Firebase ID token>
 *
 * Who may write what (mirrors firestore.rules: admin = custom claim admin):
 *   admin    → products/, banners/, categories/, suppliers/, payments/ (put + delete)
 *   customer → receipts/<own uid>/...                         (put once, ≤ 3 MB)
 *
 * Settings → Variables: PROJECT_ID = the Firebase project id.
 * Deploy: paste this file in the dashboard editor (Edit code) → Deploy.
 */

const ADMIN_PREFIXES = ['products/', 'banners/', 'categories/', 'suppliers/', 'payments/'];
const RECEIPTS = 'receipts/';
const MAX_ADMIN_BYTES = 10 * 1024 * 1024;
const MAX_RECEIPT_BYTES = 3 * 1024 * 1024;
const TYPES = ['image/webp', 'image/jpeg', 'image/png'];
const KEY_PATTERN = /^[a-z]+\/[A-Za-z0-9_\-\/]+\.(webp|jpg|jpeg|png)$/;

// Google's public keys for Firebase ID tokens (rotated; cached per their max-age).
const JWKS_URL = 'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Authorization, Content-Type',
  'Access-Control-Max-Age': '86400',
};

const json = (status, body) =>
  new Response(JSON.stringify(body), { status, headers: { ...CORS, 'Content-Type': 'application/json' } });

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: CORS });
    if (request.method !== 'PUT' && request.method !== 'DELETE') return json(405, { error: 'method' });

    const key = decodeURIComponent(new URL(request.url).pathname.slice(1));
    if (!KEY_PATTERN.test(key) || key.includes('..')) return json(400, { error: 'key' });

    let user;
    try {
      user = await verifyIdToken(request.headers.get('Authorization'), env.PROJECT_ID);
    } catch {
      return json(401, { error: 'auth' });
    }

    const isAdmin = user.admin === true;
    const adminPath = ADMIN_PREFIXES.some((p) => key.startsWith(p));
    const ownReceipt = key.startsWith(`${RECEIPTS}${user.user_id}/`);

    if (request.method === 'DELETE') {
      if (!isAdmin || !(adminPath || key.startsWith(RECEIPTS))) return json(403, { error: 'forbidden' });
      await env.BUCKET.delete(key);
      return json(200, { key });
    }

    if (!(isAdmin && adminPath) && !ownReceipt) return json(403, { error: 'forbidden' });

    const type = (request.headers.get('Content-Type') || '').split(';')[0].trim();
    if (!TYPES.includes(type)) return json(415, { error: 'type' });

    const body = await request.arrayBuffer();
    const max = adminPath ? MAX_ADMIN_BYTES : MAX_RECEIPT_BYTES;
    if (body.byteLength === 0 || body.byteLength > max) return json(413, { error: 'size' });

    // A receipt is evidence of a payment: written once, never replaced.
    if (ownReceipt && (await env.BUCKET.head(key))) return json(409, { error: 'exists' });

    await env.BUCKET.put(key, body, {
      httpMetadata: {
        contentType: type,
        // Admin images get a new name when replaced, so they can be cached for good.
        cacheControl: adminPath ? 'public, max-age=31536000, immutable' : 'private, max-age=0',
      },
    });
    return json(200, { key });
  },
};

// ---------- Firebase ID token (RS256 JWT) ----------

let jwksCache = { keys: null, until: 0 };

async function publicKey(kid) {
  if (!jwksCache.keys || Date.now() > jwksCache.until) {
    const res = await fetch(JWKS_URL);
    const maxAge = Number(/max-age=(\d+)/.exec(res.headers.get('Cache-Control') || '')?.[1] || 3600);
    jwksCache = { keys: (await res.json()).keys, until: Date.now() + maxAge * 1000 };
  }
  const jwk = jwksCache.keys.find((k) => k.kid === kid);
  if (!jwk) throw new Error('kid');
  return crypto.subtle.importKey('jwk', jwk, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['verify']);
}

const b64url = (s) => Uint8Array.from(atob(s.replace(/-/g, '+').replace(/_/g, '/')), (c) => c.charCodeAt(0));
const decode = (s) => JSON.parse(new TextDecoder().decode(b64url(s)));

async function verifyIdToken(header, projectId) {
  const token = (header || '').replace(/^Bearer\s+/i, '');
  const [h, p, sig] = token.split('.');
  if (!h || !p || !sig || !projectId) throw new Error('format');

  const head = decode(h);
  if (head.alg !== 'RS256') throw new Error('alg');
  const ok = await crypto.subtle.verify(
    'RSASSA-PKCS1-v1_5', await publicKey(head.kid), b64url(sig), new TextEncoder().encode(`${h}.${p}`));
  if (!ok) throw new Error('signature');

  const claims = decode(p);
  const now = Math.floor(Date.now() / 1000);
  if (claims.aud !== projectId) throw new Error('aud');
  if (claims.iss !== `https://securetoken.google.com/${projectId}`) throw new Error('iss');
  if (!(claims.exp > now) || !(claims.iat <= now + 300)) throw new Error('time');
  if (!claims.user_id) throw new Error('sub');
  return claims;
}
