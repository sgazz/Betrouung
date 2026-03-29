# Plan: ProfileDetail i EditProfile poboljšanja

Redosled rada:

1. **CareProfileViewModel** — Jedan izvor istine za validaciju imena pri izmeni: `validateProfileName(_:excludingProfileId:)` da duplikat imena ne pogađa trenutni profil (`profileNameExists` sa opcionim `excludingProfileId`).

2. **Jedan tok čuvanja** — U `ProfileDetailView` ukloniti dupli poziv `container.dataService.updateCareProfile`; ostaje samo `onSaveProfile` → `viewModel.updateProfile` (već zove `dataService`).

3. **HomeView + ProfileDetailView** — Proslediti `@ObservedObject var profilesViewModel: CareProfileViewModel` u `ProfileDetailView` (i u Preview), da `EditProfileSheet` koristi iste validatore kao `CreateProfileView`.

4. **EditProfileSheet — struktura forme** — Sekcije kao kod kreiranja: Osnovno (ime, adresa), Kontakti (telefon, email, staratelj), Napomene (naslov iz `profile.edit.notes_title`).

5. **EditProfileSheet — VoiceInputButton** — Isti obrazac kao `CreateProfileView` (HStack + `VoiceInputButton`) za sva tekstualna polja.

6. **EditProfileSheet — Napomene** — `TextEditor` sa većom visinom (umesto `TextField` sa 3 linije) + voice dugme.

7. **EditProfileSheet — Validacija i Save** — `canSave` i poruke grešaka preko `CareProfileViewModel`; Save disabled kada nije validno; prikaz jedne poruke kao u create flow-u.

8. **EditProfileSheet — Nesačuvane izmene** — `isDirty` (poređenje sa `initialProfile`); `interactiveDismissDisabled(isDirty)`; na Cancel — `confirmationDialog` (Odbaci / Nastavi izmenu) + lokalizacija.

9. **ProfileDetailView — raspored kartice** — Ime → Kontakti → Adresa → Napomene.

10. **ProfileDetailView — Telefon i email** — Tap akcije: `tel:` i `mailto:` (sanitizacija telefona za URL).

11. **ProfileDetailView — Dugo ime** — `.lineLimit` + `.minimumScaleFactor` na naslovu imena u kartici.

12. **Lokalizacija** — Novi ključevi za dijalog odbacivanja izmena (EN/DE/SR).

13. **Provera** — `xcodebuild` / lint za izmenjene fajlove.

---

## Status (implementirano)

Svi koraci 1–12 su urađeni u kodu; lint na izmenjenim Swift fajlovima je čist. Build u ovom okruženju može da zakaže zbog sandbox/DerivedData — pokreni `xcodebuild` lokalno u Xcode-u za potvrdu.
