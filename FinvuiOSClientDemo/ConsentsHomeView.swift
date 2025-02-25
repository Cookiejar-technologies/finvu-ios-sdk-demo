import Foundation
import SwiftUI
import FinvuSDK

struct ConsentsHomeView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var linkedAccounts = [LinkedAccountDetailsInfo]()
    @State private var consentDetailList: [String: ConsentRequestDetailInfo] = [:] // HashMap for consent details
    @State private var showApprovalDialog = false
    @State private var showDenyConfirmation = false
    @State private var selectedAccounts: Set<LinkedAccountDetailsInfo> = []
    let finvuManager = FinvuManager.shared
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack {
            // Linked Accounts Section
            Text("Select Linked Accounts")
                .font(.headline)
            List(linkedAccounts, id: \.accountReferenceNumber) { account in
                HStack {
                    Text(account.maskedAccountNumber)
                    Spacer()
                    Image(systemName: selectedAccounts.contains(account) ? "checkmark.square.fill" : "square")
                        .onTapGesture {
                            toggle(account: account)
                        }
                }
            }
            
            Divider()
            
            // Buttons Section
            HStack {
                Button("Approve") {
                    // Set the flag to true to show the alert dialog
                    showApprovalDialog = true
                }
                .buttonStyle(.borderedProminent)
                .alert(isPresented: $showApprovalDialog) {
                    Alert(
                        title: Text("Approve Consent"),
                        message: Text("Do you want to split consents?"),
                        primaryButton: .default(Text("Split")) {
                            print("Split option selected")
                            splitConsentFlow()
                        },
                        secondaryButton: .default(Text("Multiple")) {
                            print("Multiple option selected")
                            multiConsentFlow()
                        }
                    )
                }
                
                Button("Deny") {
                    showDenyConfirmation = true
                }
                .buttonStyle(.borderedProminent)
                .alert(isPresented: $showDenyConfirmation) {
                    Alert(title: Text("Deny Consent"),
                          message: Text("Are you sure you want to deny the consent?"),
                          primaryButton: .destructive(Text("Deny")) {
                        denyConsent()
                    },
                          secondaryButton: .cancel())
                }


            }
            .padding()
        }        
        .onAppear {
            fetchLinkedAccounts()
            LoginView.consentHandleIds.forEach { consentHandleId in
                getConsentDetails(consentHandleId: consentHandleId)
            }
        }
    }
    
    private func fetchLinkedAccounts() {
        finvuManager.fetchLinkedAccounts { result, error in
            
            if let error = error {
                print("Could not get linked accounts error=\(error)")
                return
            }
            
            linkedAccounts = result?.linkedAccounts ?? []
        }
    }
    
    private func getConsentDetails(consentHandleId: String) {
        finvuManager.getConsentRequestDetails(consentHandleId: consentHandleId) { response, error in
            if let error = error {
                print("Could not fetch pending consents error=\(error)")
                return
            }
            
            // Ensure response is valid
            guard let response = response else {
                print("Invalid response received.")
                return
            }
            
            // Use the existing model to create a ConsentRequestDetailInfo instance
            let consentRequestDetail = ConsentRequestDetailInfo(
                consentId: response.detail.consentId,
                consentHandle: response.detail.consentHandle,
                statusLastUpdateTimestamp: nil, // You can set this value if needed
                financialInformationUser: FinancialInformationEntityInfo(
                    id: response.detail.financialInformationUser.id,
                    name: response.detail.financialInformationUser.name
                ),
                consentPurposeInfo: ConsentPurposeInfo(
                    code: response.detail.consentPurposeInfo.code,
                    text: response.detail.consentPurposeInfo.text
                ),
                consentDisplayDescriptions: response.detail.consentDisplayDescriptions,
                consentDateTimeRange: DateTimeRange(
                    from: response.detail.consentDateTimeRange.from,
                    to: response.detail.consentDateTimeRange.to
                ),
                dataDateTimeRange: DateTimeRange(
                    from: response.detail.dataDateTimeRange.from,
                    to: response.detail.dataDateTimeRange.to
                ),
                consentDataLifePeriod: ConsentDataLifePeriod(
                    unit: response.detail.consentDataLifePeriod.unit,
                    value: response.detail.consentDataLifePeriod.value
                ),
                consentDataFrequency: ConsentDataFrequency(
                    unit: response.detail.consentDataFrequency.unit,
                    value: response.detail.consentDataFrequency.value
                ),
                fiTypes: response.detail.fiTypes
            )
            
            consentDetailList[consentHandleId] = consentRequestDetail
        }
    }
    
    
    
    private func toggle(account: LinkedAccountDetailsInfo) {
        if selectedAccounts.contains(account) {
            selectedAccounts.remove(account)
        } else {
            selectedAccounts.insert(account)
        }
    }
    
    private func splitConsentFlow() {
        selectedAccounts.enumerated().forEach { index, account in
            finvuManager.approveAccountConsentRequest(consentDetail: consentDetailList[LoginView.consentHandleIds[index]]!,
                                                      linkedAccounts: [account]) { result, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Could not approve consent request error=\(error)")
                        return
                    }
                    
                    if index == selectedAccounts.count - 1 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func multiConsentFlow() {
        finvuManager.approveAccountConsentRequest(consentDetail: consentDetailList[LoginView.consentHandleIds[0]]!,
                                                  linkedAccounts: Array(selectedAccounts)) { result, error in
            if let error = error {
                print("Could not approve consent request error=\(error)")
                return
            }
            // navigate back to previous view
            presentationMode.wrappedValue.dismiss()
            
        }
    }
    private func denyConsent() {
        finvuManager.denyAccountConsentRequest(consentDetail: consentDetailList[LoginView.consentHandleIds[0]]!){ result, error in
            if let error = error {
                print("Could not approve consent request error=\(error)")
                return
            }
            // navigate back to previous view
            presentationMode.wrappedValue.dismiss()
            
        }
    }}
