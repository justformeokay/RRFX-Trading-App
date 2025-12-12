// EXAMPLE USAGE OF PENDING VERIFICATION POPUP
// Import the popup
import 'package:flutter/material.dart';
import 'package:rrfx/src/components/popups/pending_verification_popup.dart';

// SIMPLE USAGE - Show with default values
void example1() {
  showPendingVerificationPopup();
}

// CUSTOM USAGE - Show with custom values
void example2() {
  showPendingVerificationPopup(
    title: 'Account Under Review',
    message: 'Your KYC documents are being verified by our compliance team. We appreciate your patience.',
    submittedDate: 'December 11, 2025',
    onContactSupport: () {
      // Handle contact support action
      // Example: Open WhatsApp, Email, or Support Chat
      print('Contact support tapped');
    },
  );
}

// USAGE IN WIDGET
class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showPendingVerificationPopup(
          submittedDate: 'Today',
          onContactSupport: () {
            // Navigate to support page or open contact method
          },
        );
      },
      child: Text('Show Pending Popup'),
    );
  }
}

// USAGE WITH API RESPONSE
void showPendingBasedOnStatus(dynamic apiResponse) {
  if (apiResponse['status'] == 'pending_verification') {
    showPendingVerificationPopup(
      submittedDate: apiResponse['submitted_at'] ?? 'Recently',
      message: apiResponse['message'] ?? 'Your account is under review.',
    );
  }
}
