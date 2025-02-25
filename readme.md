# Finvu iOS Demo App

This demo application showcases the implementation and flows of the Finvu iOS SDK. It demonstrates account discovery, linking, and consent management functionalities.

## Getting Started

1. **Clone the Repository**: 
   ```bash
   git clone <repository-url>
   cd FinvuiOSClientDemo
   ```

2. **Install Dependencies**: 
   Make sure you have CocoaPods installed. If not, install it using:
   ```bash
   sudo gem install cocoapods
   ```
   Then, navigate to the project directory and run:
   ```bash
   pod install
   ```

3. **Open the Project**: 
   Open the `.xcworkspace` file in Xcode:
   ```bash
   open FinvuiOSClientDemo.xcworkspace
   ```

4. **Build and Run the Application**: 
   Use Xcode to build and run the application on a simulator or a physical device.

5. **Use Test Credentials**: 
   Use the provided test credentials to explore the flows.

6. **Follow the Sequential Flows**: 
   Navigate through the application from login to consent management.

## Key Flows

### 1. Authentication Flow
- Initial login screen where user enters:
    - Username
    - Mobile number
    - Consent Handle ID
- OTP verification
- On successful verification, user is redirected to main dashboard

### 2. Main Dashboard Flow
- Displays list of linked accounts
- Provides options to:
    - Add new account
    - Process consent
- Fetches and displays all linked accounts in a recycler view

### 3. Account Discovery & Linking Flow
1. Popular Search
    - Displays list of available FIPs (Financial Information Providers)
    - User selects a FIP to proceed

2. Account Discovery
    - User enters mobile number (mandatory)
    - Optional PAN number input
    - Fetches available accounts from selected FIP
    - Shows both unlinked and already linked accounts
    - Allows selection of multiple accounts for linking

3. Account Linking Confirmation
    - OTP verification for selected accounts
    - On successful verification, accounts are linked
    - Redirects back to main dashboard

### 4. Consent Management Flow

#### Pre-defined Consent Handle IDs
For demonstration purposes, the app uses predefined consent handle IDs:

```swift
let consentHandleIds = [
    "e5dbe1e5-d77a-4646-bb6c-2f60fd2c326f",
    "765d488a-8834-42ec-88c0-b236bf3c4aa2",
    "fe8ae48b-ef52-407e-adcf-78583bfe9462"
]
```


#### A. Consent Details Display
- Shows comprehensive consent information:
    - Purpose
    - Data fetch frequency
    - Data usage period
    - Date ranges
    - Account types requested

#### B. Account Selection
- Lists linked accounts
- Allows selection of accounts for consent

#### C. Consent Actions
1. **Multi Consent Flow**
    - Uses a single consent handle ID (index 0) for all selected accounts.
    - Processes all accounts in one API call.
    - Simpler implementation for basic use cases.
    - Example implementation:
    ```swift
    private func multiConsentFlow() {
        finvuManager.approveAccountConsentRequest(
            consentDetailList[LoginView.consentHandleIds[0]]!,
            linkedAccounts
        ) { result, error in
            // Handle success/failure
        }
    }
    ```

2. **Split Consent Flow**
    - Creates separate consent requests for each selected account.
    - Uses different consent handle IDs for each account.
    - The first account is treated as the parent consent, others as child consents.
    - Validates selected accounts match available consent handle IDs.
    - Example implementation:
    ```swift
    private func splitConsentFlow() {
        guard selectedAccounts.count == LoginView.consentHandleIds.count else {
            // Show error if mismatch
            return
        }
        
        for (index, account) in selectedAccounts.enumerated() {
            finvuManager.approveAccountConsentRequest(
                consentDetailList[LoginView.consentHandleIds[index]]!,
                linkedAccounts: [account]
            ) { result, error in
                // Handle each account processing
            }
        }
    }
    ```

3. **Reject Consent**
    - Denies the consent request using the first consent handle ID.
    - Cancels the entire consent process.

#### Important Implementation Notes
##### Consent Handle ID Management:

    - Demo uses predefined IDs for simplicity
    - In production, generate new consent handle IDs for each selected account
    - Number of selected accounts must match available consent handle IDs

## Dependencies

The app uses the following Finvu SDK components:
- `pod 'FinvuSDK', :git => 'https://github.com/Cookiejar-technologies/finvu_ios_sdk.git', :tag => '1.0.3'`

## Production Considerations
1. Replace hardcoded consent handle IDs with dynamically generated ones.
2. Implement proper validation for consent expiry and other parameters.

**Note**: This is a demo application intended to showcase the Finvu iOS SDK implementation. For production use, please refer to the official documentation and implement appropriate security measures.
