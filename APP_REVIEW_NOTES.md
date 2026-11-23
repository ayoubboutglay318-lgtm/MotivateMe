# MotivateMe: App Review notes

These are the notes in App Store Connect for version 1.0, build 1.0.0 (4), answering Apple's Guideline 2.1 "Information Needed" request. Keep them in sync with the app: if a feature or external service changes, update both.

```
SUBJECT: Response to Guideline 2.1 - Information Needed (iOS App 1.0, build 1.0.0 (4))

Thank you for the review. We have submitted a new build (1.0.0 (4)) that simplifies the app: the optional on-device sign-in and the "Coming Soon" premium screens have been removed, so every feature in the app is complete and available without an account.

1) Screen recording
A screen recording from a physical iPhone is attached. It shows this flow:
- Launch app -> onboarding screens -> notification permission prompt
- Quotes tab: today's quote; swipe up for more quotes; tap the heart to save one
- Tap Share -> "Share as image" -> the iOS share sheet opens with the quote image
- Tap the chat bubble -> AI Coach screen -> type "I feel tired" and show the reply
- Challenge tab -> mark today's task done
- Goals tab -> add a goal and update its progress
- Profile tab -> streak and stats
- Settings -> change Motivation Mode (e.g. Gym) -> go back to Quotes to show gym quotes
- Settings -> notification start time and interval; My Wins -> log a win
- Settings -> Privacy Policy and Terms of Use

2) Devices/OS tested
iPhone 13 Pro, iOS 26.5

3) App description / target audience
Motivate Me is a daily-motivation app for people building discipline and habits (fitness, study, business, personal growth). It shows a daily motivational quote and a swipeable feed of more quotes, with six motivation modes (Classic, Sigma, Gym, Study, Business, Monk) that change which quotes appear. It includes scheduled local reminder notifications, a streak counter with an evening reminder before the streak breaks, a 30-day discipline challenge, a goal tracker, a favorites list, a private "My Wins" journal, and quote sharing as text or image.
The "AI Coach" chat screen in this build returns pre-written motivational responses chosen by keywords in the user's message. It is rule-based text matching that runs entirely on the device. It does not connect to any AI service. Messages that mention self-harm or abuse get a supportive response that points the user to a crisis line instead of motivational content.

4) Setup / accessing main features
No account, login, or setup is required. All features work immediately after the onboarding screens. There are no in-app purchases or locked features.

5) External services / SDKs used
- ZenQuotes.io public API (https://zenquotes.io): downloads a batch of motivational quotes once a day. A bundled local quote list is used when offline.
- Unsplash (images.unsplash.com): background photos behind the quotes.
- Google Fonts package: font assets.
- share_plus: opens the standard iOS share sheet.
- flutter_local_notifications: schedules local notifications on the device.
No analytics, advertising, tracking, payment, authentication, or AI/LLM services are used. No personal data leaves the device.

6) Regional differences
The app functions identically in all regions and locales.

7) Regulated industry / protected third-party material
Not applicable. The app does not operate in a regulated industry. Quotes are short attributed quotations.
```
