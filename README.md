
# BumpLess (DECO3801 Project)
BumpLess is a mobile application that helps you Bump Less!

## Authors
**BnY Innovators**
- Alvin Benny (Second Year Student of Computer Science and Cyber Security)
- Kit Man Marco Tam (Second Year Student of Computer Science and Commerce)
- Janvi Rattan Atre (Final Year Student of Computer Science)
- Chua Yi Xun (Final Year Student of Computer Science)
- Toh Weiheng Jerome (Second Year Student of Computer Science and Data Science)
- Arjun Srikanth (Final Year Student of Computer Science)

## Project Overview
Our solution, driven by the motto "Empowering vision at every corner" is to develop an app using swift that enhances the independence and safety of visually impaired individuals.
The app will scan the environment, accept user commands via buttons or voice, and project a path to help users navigate to specific locations or items using audio and haptic feedback.
This intuitive tool will provide real-time, non-visual guidance, allowing users to confidently and safely navigate their homes.

## Repository Overview
- `NavSense/Feature Targets/ContentView.swift`: Contains the SwiftUI-based UI for displaying the AR view and depth points on the screen.
- `NavSense/Feature Targets/CustomARView.swift`: ARKit-based custom view that processes scene depth data and sends audio feedback based on detected object distance.
- `NavSense/Feature Targets/AudioManager.swift`: Manages all audio feedback based on proximity, converting distance ranges into specific audio cues.
- `NavSense/Feature Targets/CustomARViewRepresentable.swift`: SwiftUI wrapper for the CustomARView class, integrating AR functionalities with the SwiftUI view hierarchy.
- `README.md`: Project documentation.

## Results
Our testing showed that BumpLess accurately detects objects at various distances and provides real-time feedback to users. The app improves mobility by using audio cues that correlate to the user’s distance from obstacles, helping them navigate through their environment safely and confidently.
