// Firestore security-rules tests for LiveHealthy: Know Your Disease
// (its own project, livehealthy-kyd). Run: cd firebase/tests && npm test
//
// The app only ever reads two public, named documents. Nobody but the
// publish script (admin SDK, which bypasses rules) may write anything, and
// nothing else in the database is reachable at all.

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import { assertFails, assertSucceeds, initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { collection, deleteDoc, doc, getDoc, getDocs, setDoc, updateDoc } from 'firebase/firestore';

let env;

before(async () => {
  const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8086').split(':');
  env = await initializeTestEnvironment({
    projectId: process.env.GCLOUD_PROJECT || 'demo-livehealthy-kyd',
    firestore: { rules: readFileSync('firebase/firestore.rules', 'utf8'), host, port: Number(port) },
  });
});

after(async () => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'kyd_manifest/current'), { contentVersion: 1 });
    await setDoc(doc(db, 'kyd_diseases/hypertension'), { id: 'hypertension', version: 1 });
    await setDoc(doc(db, 'users/someone'), { name: 'should never be readable' });
  });
});

const anon = () => env.unauthenticatedContext().firestore();
const signedIn = () => env.authenticatedContext('u1').firestore();

describe('public content', () => {
  test('anyone can read the manifest', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'kyd_manifest/current')));
  });
  test('anyone can read a disease document', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'kyd_diseases/hypertension')));
  });
  test('reading a missing document is allowed (first run before publishing)', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'kyd_diseases/not_published_yet')));
  });
  test('collections cannot be listed (the app only fetches by name)', async () => {
    await assertFails(getDocs(collection(anon(), 'kyd_diseases')));
    await assertFails(getDocs(collection(anon(), 'kyd_manifest')));
  });
});

describe('nobody writes from a client', () => {
  for (const [name, db] of [['anonymous', anon], ['signed-in', signedIn]]) {
    test(`${name}: cannot create, change or delete content`, async () => {
      await assertFails(setDoc(doc(db(), 'kyd_manifest/current'), { contentVersion: 99 }));
      await assertFails(updateDoc(doc(db(), 'kyd_diseases/hypertension'), { version: 2 }));
      await assertFails(setDoc(doc(db(), 'kyd_diseases/fake'), { id: 'fake' }));
      await assertFails(deleteDoc(doc(db(), 'kyd_diseases/hypertension')));
    });
  }
});

describe('everything else is closed', () => {
  test('other collections cannot be read or written', async () => {
    await assertFails(getDoc(doc(anon(), 'users/someone')));
    await assertFails(getDoc(doc(signedIn(), 'users/someone')));
    await assertFails(setDoc(doc(signedIn(), 'users/u1'), { x: 1 }));
    await assertFails(getDocs(collection(anon(), 'users')));
  });
  test('subcollections of content are closed', async () => {
    await assertFails(getDoc(doc(anon(), 'kyd_diseases/hypertension/secret/x')));
    await assertFails(setDoc(doc(anon(), 'kyd_manifest/current/extra/x'), { a: 1 }));
  });
});
