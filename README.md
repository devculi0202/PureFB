# PureFB

PureFB is an iOS client/reader app for Facebook that follows the principle of "Less is more". It transforms a cluttered Facebook feed into a high-end digital magazine, giving users full control over their information flow and helping them avoid addictive algorithms.

## Project Vision

PureFB aims to provide a clean and focused experience by displaying posts only from whitelisted sources, eliminating ads, suggested posts, and unfamiliar groups. The app's design is centered around simplicity and readability, with a monochromatic color scheme, ample whitespace, optimized typography using the San Francisco font, and zero cognitive load.

## Core Features

- **Whitelist-Only Feed:** Display posts only from selected users/pages. No ads, no suggested posts, no unfamiliar groups.
- **De-Cluttered UI/UX:** Remove avatars, interaction buttons (Like, Share, Comment), and interaction counts to provide an objective reading experience.
- **Typography-Focused Design:** Monochromatic design with large whitespace, optimized line-height, and the San Francisco font for reduced cognitive load.
- **"Read & Done" Gesture:** Swipe left to hide read posts, helping users maintain a clean timeline (similar to Inbox Zero).
- **Tap to View Source:** Hold tap for 2 seconds to open an internal WebView containing the original Facebook post if further interaction is desired.

## Architecture (Local Hybrid Scraper)

PureFB operates entirely on the client side, bypassing backend and serverless solutions. This approach saves costs and eliminates the need for complex headless browsers like Playwright/Selenium running in the cloud.

- **Zero Account Ban Risk:** Users manually log in once using a hidden `WKWebView`. Data scraping is performed using the user's home/4G network IP, avoiding detection by Facebook's IP-blocking algorithms and 2FA errors.
- **Instant Parsing:** Use `evaluateJavaScript` to inject JavaScript scripts that parse the local DOM HTML directly from the WebView. The data is then standardized into JSON format and sent to the native Swift layer via `WKScriptMessageHandler` for processing.

## Tech Stack & Structure

- **Language:** Swift 5
- **UI Framework:** SwiftUI (Declarative layout)
- **Architectural Pattern:** MVVM (Model-View-ViewModel)
- **Core Components:** `WKWebView`, `UIViewRepresentable`, `LazyVStack` & `ScrollView` for smooth rendering and memory efficiency.

## Getting Started (Sideloading)

Since PureFB is a personal utility app that scrapes data without using the official API, it is intended to be sideloaded directly onto an iPhone.

1. **Clone the Repo:**
   ```sh
   git clone https://github.com/yourusername/PureFB.git
   ```
2. **Open Project Structure with VS Code:**
   - Open the cloned repository in Visual Studio Code to make any necessary modifications to the logic.

Feel free to reach out if you have any questions or need further assistance!

---

**Contributing:**
We welcome contributions! Please fork the repository and submit a pull request with your changes. Make sure to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

**License:**
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Contact:**
For any inquiries or support, please contact us at [support@purefb.com](mailto:support@purefb.com).

---

🌟 Thank you for using PureFB! 🌟