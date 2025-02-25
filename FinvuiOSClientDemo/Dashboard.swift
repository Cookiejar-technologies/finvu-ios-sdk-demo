import Foundation
import SwiftUI
import FinvuSDK

struct Dashboard: View {
    @State var linkedAccountsResponse: LinkedAccountsResponse?
    @State private var navigateToProcessConsent = false
    @State private var navigateToAddAccount = false
    private var finvuManager = FinvuManager.shared
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    init(linkedAccountsResponse: LinkedAccountsResponse? = nil) {
            self.linkedAccountsResponse = linkedAccountsResponse
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Linked Accounts Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Linked Accounts")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    // Fixed height ScrollView for linked accounts
                    ScrollView {
                        if let linkedAccounts = linkedAccountsResponse?.linkedAccounts {
                            VStack(spacing: 8) {
                                ForEach(linkedAccounts, id: \.linkReferenceNumber) { account in
                                    LinkedAccountRow(account: account)
                                        .padding(.horizontal, 16) // Add horizontal margins
                                }
                            }
                            .padding(.vertical, 16) // Add vertical margins
                        } else {
                            Text("No linked accounts found")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .frame(height: 300) // Fixed height for the accounts list
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                HStack {
                    Text("Add New Account")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    NavigationLink(destination: AccountDiscoveryView()) {
                                    Text("Add")
                    }
                    .buttonStyle(.bordered)
                }
                
                // Process Consent Button
                NavigationLink(destination: ConsentsHomeView()) {
                    Text("Process Consent")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
        }
        .onAppear {
            refreshLinkedAccounts()
        }
    }
    
    func refreshLinkedAccounts() {
        finvuManager.fetchLinkedAccounts { result, error in
            if let error = error {
                print("Got error when fetching accounts error=\(error)")
                return
            }
            
            self.linkedAccountsResponse = result
        }
    }
}
// Separate view for linked account row
struct LinkedAccountRow: View {
    let account: LinkedAccountDetailsInfo
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.fipName)
                    .font(.subheadline)
                Text("\(account.maskedAccountNumber) (\(account.accountType))")
                    .font(.footnote)
                if let lastUpdateTime = account.linkedAccountUpdateTimestamp {
                    Text("last update on \(dateFormatter.string(from: lastUpdateTime))")
                        .font(.footnote)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}


#Preview {
    Dashboard()
}
