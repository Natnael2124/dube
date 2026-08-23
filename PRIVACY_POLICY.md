# Privacy Policy for Dube (ድቤ)

**Last updated:** 23 August 2026

Dube is an offline-first credit ledger for local retail shopkeepers. This policy explains what information the app stores, what it does **not** collect, and how advertising (Google AdMob) works.

By using Dube, you agree to this policy.

## 1. Local-first data storage

Dube is designed so that **your shop’s books stay on your device**.

The app stores the following information in a local SQLite database on the phone or tablet where Dube is installed:

- Customer names, phone numbers, and optional notes
- Credit (Dube) records: items sold on credit, amounts, amounts paid, due dates, and status (active, overdue, settled)
- Payment and adjustment history for each credit record
- Derived reliability summaries (for example, on-time settlement counts)

This merchant financial ledger data is **not uploaded to Dube servers**. Dube does not operate a cloud backend for shop books, does not require an account, and does not sync customer balances, debts, or payment history to a remote database.

If you uninstall Dube, this local ledger is deleted with the app (unless you have made your own backup of the device).

## 2. No remote collection of merchant financial ledger data

We do **not**:

- Collect, transmit, or store your customer list, debt amounts, payment history, or other ledger contents on our servers
- Sell or share merchant financial ledger data with third parties
- Use ledger contents for advertising profiling
- Require you to create an online account to use the app

SMS reminders and phone calls use the device’s own SMS and phone apps. Dube prepares a reminder text and opens the system composer; it does **not** send SMS on your behalf, and it does **not** read or store the contents of your message threads.

## 3. Permissions

Dube may request or declare the following Android permissions:

| Permission | Why it is used |
| --- | --- |
| `INTERNET` | Load Google AdMob advertisements and related ad resources |
| `ACCESS_NETWORK_STATE` | Detect network availability so ads can load when a connection exists |

The app may also open the system SMS app and phone dialer (for customer reminders and sponsor contact). Those actions stay on the device and are initiated by you.

## 4. Advertising (Google AdMob)

Dube shows banner advertisements through **Google AdMob** (and may rotate those ads with locally defined sponsor cards). Ads are how the app remains free to use.

When an ad is requested, **Google** (not Dube) may collect and process information such as:

- Advertising ID / device identifiers
- IP address and approximate location derived from IP
- Device type, OS version, language, and similar technical data
- Ad interaction events (impressions, clicks)

Google may use this information to provide, measure, and personalize ads, and to detect fraud, in accordance with Google’s own policies.

Dube does **not** send your shop ledger (customer names, phone numbers, debt amounts, or payment history) to AdMob or to other advertisers.

You can learn more and manage ad preferences here:

- [Google Privacy Policy](https://policies.google.com/privacy)
- [How Google uses information from apps](https://policies.google.com/technologies/partner-sites)
- [AdMob & privacy](https://support.google.com/admob/answer/6128543)
- Android Settings → Google → Ads (reset advertising ID or opt out of ads personalization, depending on your OS version)

If AdMob fails to load, Dube continues to work fully offline for ledger features and may show local sponsor cards instead.

## 5. Data we do not collect

Dube does not collect:

- Precise GPS location
- Contacts from your address book (you type customer names and phones yourself)
- Photos, files, or microphone/camera data
- Analytics about individual credit sales
- Payment card or bank account details (the app records shop credit balances only; it does not process electronic payments)

## 6. Children

Dube is intended for shopkeepers and adult merchants. It is not directed at children under 13 (or the applicable age in your country). We do not knowingly collect personal information from children.

## 7. Data retention and deletion

Ledger data remains on your device until you delete individual records in the app or uninstall Dube. Because we do not host your books, we cannot recover a deleted local database.

To stop AdMob-related data collection by Google, uninstall the app and use Google’s ad settings as described above.

## 8. Security

Ledger data is stored in the app’s private local storage, which other apps cannot read under normal Android sandboxing. You are responsible for protecting the device (screen lock, who can open the phone) and for any backups you make.

Release builds of Dube are signed and use code shrinking. That protects the application package; it does not replace a device lock or a backup strategy.

## 9. Changes to this policy

We may update this policy when the app’s data practices change (for example, if a future version adds optional cloud backup). The “Last updated” date at the top will change, and the updated policy will be posted with the app listing.

## 10. Contact

For privacy questions about Dube, contact the developer through the Google Play Store listing for this app (the support or developer contact email shown on the store page).

If your question is about Google advertising data, please also see Google’s privacy policy linked in section 4.
