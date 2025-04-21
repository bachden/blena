

# Blena - BL[E]NAbled iOS Browser

## **Project Overview**
Blena is an open-source browser for iOS targeted at web developers whose products require features related to the Web Bluetooth API. Blena is designed to be simple, user-friendly, and includes many debugging features. With the motto: "developers' product serving developers," we always listen to community feedback and update the product to meet the most appropriate requirements.
---

## **Key Features**

### 1. **Bluetooth Low Energy (BLE) Communication**
- **Purpose**: Enable secure and efficient interaction with BLE devices.
- **Capabilities**:
    - Scanning and discovering BLE devices in range.
    - Establishing a connection to BLE peripherals.
    - Sending and receiving data through BLE protocols.

### 2. **Vibration API**
- **Purpose**: enable vibration function on web Navigator object

### 3. **Modern iOS Development Practices**
- **Minimum iOS Support**: iOS 12.0 ensures compatibility with a wide range of devices.
- **Framework Integration**:
    - **CocoaPods**: Simplified dependency management.
    - **EasyTipView**: Offers intuitive tooltip overlays for a smooth user interface experience.

### 4. **Testing Support**
- **Unit Tests**: Validate core functionalities through automated testing in the `BlenaTests` target.
- **UI Tests**: Test end-to-end user flows and interface behaviors in `BlenaUITests`.

### 5. **Legal Compliance**
- Includes pre-built legal documents:
    - **Terms and Conditions**
    - **Privacy Policy**
- Easily customizable HTML templates for compliance.

### 6. **Extensible Architecture**
- Modular structure designed to facilitate future enhancements.
- Separate modules for features such as intent handling (`IntentExtensionUI`) and widgets (`widget`).

---

## **Project Structure**
The project is divided into the following key components:

### Main Modules:
- **Blena**: The core application module for BLE functionalities.
- **BlenaUITests**: Automated UI tests for integration and user flow verification.
- **BlenaTests**: Unit tests for verifying individual functionalities.

### Supporting Modules:
- **IntentExtensionUI**: Enables custom user interactions for Siri-like extensions.
- **widget**: Adds widget functionality for quick user access.

### Other Directories:
- **Docs**: Contains HTML-based terms and policy documentation.
- **Graphics**: Houses graphical assets and icons.
- **Policy**: Includes security and compliance policies.

---
