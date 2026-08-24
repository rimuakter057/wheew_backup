import 'package:platchatapp/utils/language/app_string.dart';

final Map<String, String> english = {
  AppStrings.noFaqsFound: "No FAQs found",
  AppStrings.couldNotLoadImage: "Could not load image",

  AppStrings.downloads: "Downloads",

  AppStrings.ratingRequestPendingInfo:
  "You have rated this request. Waiting for admin to review and update the final status.",

  AppStrings.ratingRequestCompleteInfo:
  "This request has been completed and approved by the admin.",

  AppStrings.ratingRequestNoStatusInfo:
  "No status yet. Once you submit a rating, the status will update automatically.",

  AppStrings.camera: "Camera",
  AppStrings.document: "Document",

  AppStrings.sent: "Sent",
  AppStrings.plateUser: "Plate User",
  AppStrings.pending: "Pending",
  AppStrings.requests: "Requests",


  AppStrings.requestAccepted:
  "Request accepted!",

  AppStrings.failedToAcceptMessageRequest:
  "Failed to accept message request",

  AppStrings.failedToAcceptRequest:
  "Failed to accept request.",

  AppStrings.requestRejected:
  "Request rejected.",

  AppStrings.failedToRejectMessageRequest:
  "Failed to reject message request",

  AppStrings.failedToRejectRequest:
  "Failed to reject request.",

  AppStrings.userBlocked:
  "User blocked.",

  AppStrings.failedToBlock:
  "Failed to block",

  AppStrings.requestWithdrawn:
  "Request withdrawn.",

  AppStrings.failedToWithdrawMessageRequest:
  "Failed to withdraw message request",

  AppStrings.failedToWithdrawRequest:
  "Failed to withdraw request.",


  AppStrings.failedToUpdateGroup:
  "Failed to update group",

  AppStrings.groupNameCannotBeEmpty:
  "Group name cannot be empty",

  AppStrings.groupUpdatedSuccessfully:
  "Group updated successfully",

  AppStrings.errorUpdatingGroup:
  "An error occurred while updating group",

  AppStrings.memberRemovedSuccessfully:
  "Member removed successfully",

  AppStrings.couldNotRemoveMember:
  "Could not remove member",

  AppStrings.failedToRemoveMember:
  "Failed to remove member",

  AppStrings.all:
  "All",

  AppStrings.individual:
  "Individual",
  AppStrings.failedToSendMessageRequest:
  "Failed to send message request",
  AppStrings.messageDeletedSuccessfully:
  "Message deleted successfully",

  AppStrings.failedToDeleteMessage:
  "Failed to delete message",

  AppStrings.errorDeletingMessage:
  "An error occurred while deleting the message",

  // Group
  AppStrings.successfullyLeftThisGroup:
  "Successfully left this group",



  // Message Request
  AppStrings.messageRequestSentSuccessfully:
  "Message request sent successfully!",

  AppStrings.failedToConnect:
  "Failed to connect. Please try again.",

  // AppStrings.requestAccepted:
  // "Request accepted!",
  //
  // AppStrings.failedToAcceptMessageRequest:
  // "Failed to accept message request",
  //
  // AppStrings.failedToAcceptRequest:
  // "Failed to accept request.",

  AppStrings.requestDeclined:
  "Request declined.",

  AppStrings.failedToDeclineMessageRequest:
  "Failed to decline message request",

  AppStrings.failedToDeclineRequest:
  "Failed to decline request.",

  AppStrings.memberAddedSuccessfully:
  "Member added successfully",

  AppStrings.memberCouldNotBeAdded:
  "Member could not be added",

  AppStrings.failedToAddMember:
  "Failed to add member. Try again.",

  AppStrings.deleteAccount: "Delete Account",
  AppStrings.warning: "Warning",
  AppStrings.deleteAccountWarning:
  "Deleting your account is permanent and cannot be undone.",

  AppStrings.currentPassword: "Current Password",
  AppStrings.enterYourPassword: "Enter your password",
  AppStrings.passwordIsRequired: "Password is required",
  AppStrings.passwordMust6Character:
  "Password must be at least 6 characters",

  AppStrings.whatHappensWhenYouDelete:
  "What happens when you delete",

  AppStrings.personalInformation:
  "Personal Information",

  AppStrings.personalInformationErased:
  "Your profile and personal information will be erased",

  AppStrings.accountRecovery:
  "Account Recovery",

  AppStrings.accountRecoveryWarning:
  "You won’t be able to access your account again",

  AppStrings.deleteAccountSecurityInfo:
  "For security reasons, please enter your password to confirm account deletion.",


  AppStrings.allFieldsRequired: "All fields are required",
  AppStrings.vehicleInfoSaved: "Vehicle info saved",
  AppStrings.failedSaved: "Failed Saved",


  AppStrings.locationServicesDisabled:
  "Location services are disabled.",


  AppStrings.locationPermissionPermanentlyDenied:
  "Location permission permanently denied.",

  AppStrings.home: "Home",
  AppStrings.parking: "Parking",
  AppStrings.chatNav: "Chat",
  AppStrings.getStarted: "Get Started",
  AppStrings.alreadyHaveAccount: "Already have an account?",
  AppStrings.accountAndSettings: "Account & Settings",
  AppStrings.unknown: "Unknown",
  AppStrings.vehicleModel: "Vehicle Model:",
  AppStrings.welcomeTitle1: "Drive.\nChat.\nPark.\nBreathe.",
  AppStrings.welcomeSubtitle1: "Connect with nearby drivers using just a license plate.",
  AppStrings.tapOnTheMapToSelectParkingLocation:
  "Tap on the map to select a parking location.",
  AppStrings.addParkingSpot: "Add Parking Spot",
  AppStrings.normal: "Normal",
  AppStrings.hybrid: "Hybrid",
  AppStrings.satellite: "Satellite",
  AppStrings.terrain: "Terrain",

  AppStrings.parkMyCar: "Park My Car",
  AppStrings.durationMin15Minutes: "Duration (minutes)",
  AppStrings.parkingType: "Parking Type",
  // -------- Welcome Screen --------
  AppStrings.clientEmail: "support@platechat.app",
  AppStrings.splash:'CONNECTING DRIVERS ONE PLATE AT A TIME',
  AppStrings.welcomeMessage: "Your plate, your chat",
  AppStrings.welcomeMessage1: "See a plate, start talking:",
  AppStrings.welcomeMessage2: "quick signup to connect with",
  AppStrings.welcomeMessage3: "PLATEChatter wherever you are",
  AppStrings.signIn: 'Sign In',
  AppStrings.signUp: 'Sign Up',
  AppStrings.logIn: 'Log In',
  AppStrings.startYourJourney: "Let's Start Your Journey",

  AppStrings.doNotAccount: "Don't have an account?",
  AppStrings.alreadyAccount1: "Already have account?",

  AppStrings.nickName: 'Nickname',
  AppStrings.licenseNumberTitle: 'License Number',
  AppStrings.licenseNumber1: 'License Number',

  AppStrings.licensePlateOrNickName: 'License Plate or Nickname',
  AppStrings.enterLicensePlateOrNickName: 'Enter License Plate or Nickname',

  AppStrings.password: 'Password',
  // AppStrings.currentPassword: 'Current Password',
  // AppStrings.enterYourPassword: 'Enter your password',
  // AppStrings.passwordIsRequired: 'Password is required',
  // AppStrings.passwordMust6Character: 'Password must be at least 6 characters',

  AppStrings.forgotPassword: 'Forgot Password',
  AppStrings.licensePlateOrNicknameRequired: 'License plate or Nickname required',

  // -------- Sign Up --------
  AppStrings.nicknameIsRequired: 'Nickname is required',
  AppStrings.selectDesignation: 'Choose Role',
  AppStrings.select: 'Select',
  AppStrings.owner: 'Owner',
  AppStrings.occasionalDriver: 'Occasional Driver',
  AppStrings.pleaseSelectDesignation: 'Please select designation',

  AppStrings.nickNameHint: 'Name',
  AppStrings.licenseNumber: 'Plate Number',
  AppStrings.typeHere: 'Type here',

  AppStrings.licenseNumberIsRequired: 'License number is required',
  AppStrings.licenseNumberMustBe: 'The license plate is incorrect',
  AppStrings.licenseNumberRequired: 'License number is required',

  AppStrings.confirmPassword: 'Confirm Password',
  AppStrings.confirmYourPassword: 'Confirm your password',
  AppStrings.passwordDoNotMatch: 'Passwords do not match',

  AppStrings.emailIsRequired: 'Email is required',
  AppStrings.enterValidEmail: 'Enter valid email',

  AppStrings.iAgreeTo: 'I declare that I am at least 16 years old and I accept the',
  AppStrings.agreeTerms: 'Terms & Conditions and Privacy Policy',
  AppStrings.continueText: 'Continue',

  AppStrings.pleaseFillAllFields: 'Please fill all fields',
  AppStrings.pleaseAcceptTerms: 'To continue you must accept the terms',

  AppStrings.creatingAccount: 'Creating account...',
  AppStrings.registrationSuccessful: 'Registration successful!',
  AppStrings.ageConfirmation: 'Confirm your age',
  AppStrings.sixteenOrNot: 'Are you over 16?',

  AppStrings.yes: 'Yes',
  AppStrings.no: 'No',

  AppStrings.emailOnlyForRecoverPassword: 'Email only for password recovery',
  AppStrings.iAgreeTo1: "I consent to the use of my data for additional purposes -",
  AppStrings.agreeTerms1: "More information",
  AppStrings.emailRequired: "Email is required",

  // -------- OTP --------
  AppStrings.dontWorryEnterYourEmail: "Don't worry, enter your registered email",
  AppStrings.enterYourEmailHere: 'Enter your email here',
  AppStrings.sendOtp: 'Send OTP',
  AppStrings.email: 'Email',

  AppStrings.enterVerificationCode: 'Enter Verification Code',
  AppStrings.verificationCode: 'Verification Code',
  AppStrings.weSent6DigitCode: "We've sent a 6-digit code",

  AppStrings.send: 'Send',
  AppStrings.resetCode: 'Reset Code',
  AppStrings.newPassword: 'New password',
  AppStrings.save: 'Save',

  // -------- General --------
  AppStrings.oR: 'OR',
  AppStrings.or: 'Or',
  AppStrings.alreadyAccount: 'Already have an account?',
  AppStrings.termsAndConditions: 'Terms and Conditions',
  AppStrings.and: ' and ',
  AppStrings.privacyPolicy: 'Privacy Policy',

  AppStrings.logOut: 'Log Out',
  AppStrings.logout: 'Logout',

  // -------- Chat --------
  AppStrings.allChat: 'All Chat',
  AppStrings.searchHere: 'Search here',
  AppStrings.noChats: 'No chats yet.\n\nSearch for your friends and start a conversation.',

  // -------- Messages --------
  AppStrings.viewProfile: 'View Profile',
  AppStrings.rateUser: 'User Rate',

  AppStrings.noMessagesYet: 'No messages yet',
  AppStrings.noRecentsYet: 'No recents yet',

  AppStrings.ratingPoor: 'Poor',
  AppStrings.ratingFair: 'Fair',
  AppStrings.ratingGood: 'Good',
  AppStrings.ratingGreat: 'Great',
  AppStrings.ratingExcellent: 'Excellent',

  AppStrings.addComment: 'Add a comment (optional)...',
  AppStrings.submitRating: 'Submit Rating',
  AppStrings.updateRating: 'Update rating',
  AppStrings.tapToRate: 'Tap a star to rate',

  AppStrings.addRating: 'Add Rating',
  AppStrings.updateYourRating: 'Update your rating',

  AppStrings.ratingSubmitted: 'Rating submitted',
  AppStrings.ratingUpdated: 'Rating updated',
  AppStrings.ratingFailed: 'Could not save rating',

  // -------- Group Chat --------
  AppStrings.createGroupChat: 'Create Group Chat',
  AppStrings.groupChatSubtitle: 'Connect with multiple people at once',
  AppStrings.groupName: 'Group Name *',
  AppStrings.pleaseEnterGroupName: 'Please enter a group name',
  AppStrings.groupNameMinChars: 'Group name must be at least 3 characters',
  AppStrings.enterGroupName: 'Enter group name...',
  AppStrings.createGroup: 'Create Group',

  // -------- Messaging / Profile --------
  AppStrings.typeHere1: 'Type here',
  AppStrings.blocked: 'Blocked',
  AppStrings.unblock: 'Unblock',
  AppStrings.blockUserAction: 'Block User',

  AppStrings.blockedUser1: 'Unblock',
  AppStrings.blockedUser5: 'Blocked users',

  AppStrings.profile: 'Profile',
  AppStrings.edit: 'Edit',

  AppStrings.youCantSend: "You can't send message to this user",
  AppStrings.youveBlocked: "You've blocked this user",
  AppStrings.thisUserWontBeAble: "This user won't be able to message you until you unblock them.",

  AppStrings.language: 'Language',
  AppStrings.nickname: 'Nickname',

  // -------- Errors / Snack --------
  AppStrings.newPassRequired: 'New password is required',
  AppStrings.confirmedPassRequired: 'Confirm password is required',
  AppStrings.passNotMatch: 'Password does not match',
  AppStrings.passSixChar: 'Password must be at least 6 characters',

  AppStrings.otpRequired: 'OTP is required',
  AppStrings.emptyBlockList: 'Empty blocked user list',

  AppStrings.rememberMe: 'Remember Me',
  AppStrings.badWordError: 'This message contains inappropriate words.',

  AppStrings.onlyForRecovery: 'Account recovery only',

  AppStrings.pleaseEnterValidEmail: 'Please enter a valid email address',

  AppStrings.otpVerifySuccess: 'OTP verified successfully',
  AppStrings.somethingWentWrong: 'Something went wrong',
  AppStrings.userNotFound: 'User not found',

  AppStrings.otpSendSuccess: 'OTP sent successfully',
  AppStrings.passwordResetSuccessfully: 'Password reset successfully',

  AppStrings.userUnblockedSuccessfully: 'User unblocked successfully',
  AppStrings.failedToUnblockUser: 'Failed to unblock user',

  AppStrings.info: 'Info',
  AppStrings.pleaseSelectAnImageFirst: 'Please select an image first',

  AppStrings.success: 'Success',
  AppStrings.profileImageUpdatedSuccessfully: 'Profile image updated successfully',

  AppStrings.error: 'Error',
  AppStrings.failedToUpdateProfileImage: 'Failed to update profile image',

  AppStrings.userBlockedSuccessfully: 'User blocked successfully',
  AppStrings.failedToBlockUser: 'Failed to block user',

  AppStrings.passwordMustBe6Characters: 'Password must be at least 6 characters',

  AppStrings.delete: 'Delete account',
  AppStrings.supportRequest: 'Support Request',

  // AppStrings.deleteAccount: 'Delete Account',
  // AppStrings.warning: 'This action is permanent',
  // AppStrings.deleteAccountWarning: 'Once you delete your account, all your data, bookings,preferences, and history will be permanently deleted and can’t be recovered.',

  AppStrings.deleteAccountSuccessfully: 'Account deleted successfully',
  AppStrings.failedDeleteAccount: 'Failed to delete account',

  AppStrings.helpSupport: 'Help and Support',
  AppStrings.faq: 'FAQ',
  AppStrings.frequentlyAskedQuestions:'frequently Asked Questions',
AppStrings.findAnswersBelow:'Find Answers Below',
  AppStrings.supportText1: 'For any help and support contact us at',
  AppStrings.supportText2: 'Our support team is available to help you anytime.',

  AppStrings.emailCopied: 'Email copied',
  AppStrings.someThingWrong: 'Something went wrong',

  // -------- Toast --------
  AppStrings.invalidCredentials: 'Invalid credentials!',
  AppStrings.somethingWrong: 'Something went wrong!',
  AppStrings.success1: 'Successful!',
  AppStrings.error2: 'Error occurred!',
  AppStrings.unauthorized: 'Unauthorized!',
  AppStrings.sessionExpired: 'Session expired!',
  AppStrings.networkError: 'Network error!',
  AppStrings.notFound: 'Not found!',
  AppStrings.saved: 'Saved!',
  AppStrings.deleted: 'Deleted!',
  AppStrings.updated: 'Updated!',
  AppStrings.created: 'Created!',
  AppStrings.loadFailed: 'Load failed!',
  AppStrings.uploadSuccess: 'Uploaded!',
  AppStrings.uploadFailed: 'Upload failed!',
  AppStrings.serverError: 'Server error!',
  AppStrings.loginSuccess: 'Welcome back!',
  AppStrings.logoutSuccess: 'Logged out!',
  AppStrings.noData: 'No data!',
  AppStrings.dismiss: 'Dismiss',

  // -------- Profile --------
  AppStrings.uploadDocuments: 'Upload Documents',
  AppStrings.driversLicense: "Driver's License",
  AppStrings.carInsurance: 'Car Insurance',
  AppStrings.carTax: 'Car Tax',
  AppStrings.tapToUpload: 'Tap to upload',
  AppStrings.viewDocument: 'View document',
  AppStrings.update: 'Update',
  AppStrings.renew: 'Renew',
  AppStrings.expires: 'Expires',
  AppStrings.expired: 'Expired',
  AppStrings.daysLeft: 'days',
  AppStrings.id: 'ID',

  // -------- Scan Screen --------
  AppStrings.scanQr: 'Scan QR',
  AppStrings.myQr: 'My QR',
  AppStrings.pointCameraHint: "Point camera at another user's QR code to connect instantly.",
  AppStrings.letOthersScan: 'Let other drivers scan this to chat with you.',
  AppStrings.showQrToConnect: 'Show this QR to connect',
  AppStrings.cameraPermissionDenied: 'Camera permission denied.\nPlease enable it in Settings.',
  AppStrings.cameraUnsupported: 'Camera not supported\non this device.',
  AppStrings.cameraError: 'Camera error.\nPlease restart the app.',

  // -------- Profile Card --------
  AppStrings.giveRating: 'Give Rating',
  AppStrings.startChat: 'Start Chat',

  // -------- Profile Nav --------
  AppStrings.upload: 'Upload',
  AppStrings.usefulNumber: 'Useful Number',

  AppStrings.dropParkingPin: "Drop Parking Pin",
  AppStrings.removePin: "Remove Parking Pin",

  AppStrings.mapGettingLocation: "Getting location...",
  AppStrings.mapLoadingParkingSpots: "Loading parking spots...",
  AppStrings.mapSelectedReport: "Selected Report",
  AppStrings.mapParkingDetails: "Parking Details",
  AppStrings.mapParkingCost: "Parking Cost",
  AppStrings.mapElectricCharging: "Electric Charging",
  AppStrings.mapDisabledFacility: "Disabled Facility",
  AppStrings.mapDisabledParkingLocation: "Disabled Parking Location",
  AppStrings.mapDropPin: "Drop Pin",
  AppStrings.mapCancel: "Cancel",

  AppStrings.mapAll: "ALL",
  AppStrings.mapBack: "BACK",
  AppStrings.mapRight: "RIGHT",
  AppStrings.mapLeft: "LEFT",
  AppStrings.mapNone: "NONE",

  AppStrings.mapParkingReportSubmitted: "Parking report submitted!",
  AppStrings.mapFailedToSubmitParkingReport: "Failed to submit parking report",
  AppStrings.mapParkingAddedSuccessTitle: "Parking Added Successfully!",
  AppStrings.mapParkingAddedSuccessMessage:
      "Your parking spot has been submitted and is pending admin approval. It will appear on the map once approved.",
  AppStrings.ok: "OK",

  AppStrings.mapParkingPin: "Parking Pin",
  AppStrings.mapPaidParking: "Paid Parking",
  AppStrings.mapFreeParking: "Free Parking",
  AppStrings.mapFailedToLoadParkingData: "Failed to load parking data",

  AppStrings.mapCost: "Cost",
  AppStrings.mapEv: "EV",
  AppStrings.mapDisabled: "Disabled",

  AppStrings.scan: "scan",
  AppStrings.chat: "chat",
  AppStrings.map: "map",
  AppStrings.you: "You",

  // -------- Group Messages --------
  AppStrings.members: 'members',
  AppStrings.leaveGroup: 'Leave Group',
  AppStrings.leaveGroupConfirmation: 'Are you sure you want to leave',
  AppStrings.cancel: 'Cancel',
  AppStrings.leave: 'Leave',
  AppStrings.seeMembers: 'See Members',
  AppStrings.addMembers: 'Add Members',

  AppStrings.removeMember: 'Remove Member',
  AppStrings.removeMemberConfirmation: 'Remove from the group',
  AppStrings.remove: 'Remove',

  AppStrings.noMembersFound: 'No members found',
  AppStrings.admin: 'Admin',
  AppStrings.groupMembersTitle: 'Group Members',

  AppStrings.addMember: 'Add Member',
  AppStrings.noResultsFor: 'No results for',
  AppStrings.noContactsFound: 'No contacts found',

  AppStrings.retry: 'Retry',
  AppStrings.noUsefulNumbersFound: 'No useful numbers found nearby.',
  AppStrings.loading: 'Loading...',



  // -------- Scan --------
  AppStrings.existingChat: 'Existing Chat',
  AppStrings.newUser: 'New User',
  AppStrings.openChat: 'Open Chat',

  AppStrings.noMessages: "No message yet",
  AppStrings.tapToRetry: 'Tap to retry',
  AppStrings.profileNotFound: 'Profile not found',

  // -------- Document Upload --------
  AppStrings.uploadDocument: 'Upload Document',
  AppStrings.updateDocument: 'Update Document',
  AppStrings.uniqueNumber: 'Unique Number',
  AppStrings.expireDate: 'Expire Date',
  AppStrings.uploadFile: 'Upload File',
  AppStrings.replaceFile: 'Replace File',

  AppStrings.tapToSelectFile: 'Tap to select file',
  AppStrings.pdfJpgPngDocSupported: 'PDF, JPG, PNG, DOC supported',

  AppStrings.pleaseEnterUniqueNumber: 'Please enter a Unique Number',
  AppStrings.pleaseEnterExpireDate: 'Please enter an Expire Date',

  AppStrings.pleaseSelectFile: 'Please select a file',
  AppStrings.pleaseSelectNewFile: 'Please select a new file',

  AppStrings.couldNotOpenDocument: 'Could not open document',
  AppStrings.ddMmYyyy: 'DD/MM/YYYY',
  AppStrings.uniqueNumberHint: '123456789',

  // -------- Group Add Member --------
  AppStrings.searchMember: 'Search Member',
  AppStrings.searchByName: 'Search by name',
  AppStrings.licenceValidator: 'License plate must have at least 3 letters and 3 numbers',

  // -------- Share --------
  AppStrings.shareApp: 'Share App',
  AppStrings.tryAmazingApp: 'Try using this amazing app!',
  AppStrings.shareWithFriends: 'Share with your friends',
  AppStrings.shareThisLinkInviteFriends: 'Share this link to invite your friends',
  AppStrings.linkCopied: 'Link Copied',
  AppStrings.share: 'Share',

  AppStrings.appInvitation: "App Invitation",
  AppStrings.useAppWithMe: "Use this app with me",

  // -------- Chat --------
  AppStrings.deleteChat: 'Delete Chat',
  AppStrings.deleteChatConfirm: 'Are you sure you want to delete this chat?',

  // -------- Scanner --------
  AppStrings.cameraStarting: 'Camera starting...',
  AppStrings.cameraPermissionRequired: 'Grant camera permission (Settings > App > Camera)',
  AppStrings.noPermission: 'No permission',

  AppStrings.pointCameraAtPlate: 'Point camera at the plate',
  AppStrings.scanning: 'Scanning...',
  AppStrings.scanningFromGallery: 'Scanning from gallery...',
  AppStrings.scanFailed: 'Scan failed',
  AppStrings.galleryScanFailed: 'Gallery scan failed',

  AppStrings.tryAgain: 'Try again',
  AppStrings.carPlateScanner: 'Car Plate Scanner',
  AppStrings.gallery: 'Gallery',

  AppStrings.ocrRunning: 'Processing OCR...',
  AppStrings.pleaseWait: 'Please wait',

  // -------- Result Dialog --------
  AppStrings.plateFound: 'Plate number found!',
  AppStrings.plateNotFound: 'Not found',
  AppStrings.candidatesDetected: 'candidates detected',

  AppStrings.plateNotClear: 'Plate may not be clear in image',
  AppStrings.bestMatch: 'BEST MATCH',
  AppStrings.tapToCopy: 'Tap to copy',

  AppStrings.allCandidates: 'All candidates',
  AppStrings.plateNotIdentified: 'Plate number not identified',

  AppStrings.pointCameraDirectly:
  'Point camera directly at the number plate,\ncheck lighting is adequate and try again.',

  AppStrings.viewRawOcr: 'View Raw OCR text',

  AppStrings.close: 'Close',
  AppStrings.copy: 'Copy',
  AppStrings.copied: 'copied!',

  AppStrings.autoScanning: 'Auto scanning...',
  AppStrings.autoOn: 'AUTO',
  AppStrings.autoOff: 'OFF',

  AppStrings.automaticDetection: 'Automatic Detection',
  AppStrings.autoScanningInProgress: 'Auto scanning in progress...',
  AppStrings.manualScanModeActive: 'Manual scan mode active',
  AppStrings.scanNow: 'SCAN NOW',
  AppStrings.noPlateNumberDetected: 'No plate/number detected',
  AppStrings.scannedNumber: 'Scanned Number',

  AppStrings.checkingPlate: 'Checking plate...',

  AppStrings.unknownUser: 'Unknown User',
  AppStrings.thisUserIsBlocked: 'This user is blocked',

  // -------- Added for translation fixes --------
  AppStrings.nothingToUpdate: 'Nothing to update',
  AppStrings.profileUpdatedSuccessfully: 'Profile updated successfully',
  AppStrings.failedToUpdateProfile: 'Failed to update profile',
  AppStrings.vehicleOwnershipStatus: 'Vehicle Ownership status',
  AppStrings.vehicleVerifiedSuccess: 'Vehicle verified successfully',
  AppStrings.documentSubmittedWaiting: 'Document submitted, waiting for verification',
  AppStrings.notVerifiedSubmitDoc: 'Not verified (please submit vehicle ownership document)',
  AppStrings.noVehicleModelTapEdit: 'No vehicle model — tap Edit to add',
  AppStrings.noVehicleColorTapEdit: 'No vehicle color — tap Edit to add',

  // Missing in Screens
  AppStrings.letsAddYourVehicle: "Let's add your vehicle",
  AppStrings.pleaseFillDetailsToProceed: 'Please fill out the details below to proceed.',
  AppStrings.selectVehicleType: 'Select Vehicle Type',
  AppStrings.editGroupChat: 'Edit Group Chat',
  AppStrings.profilePicture: 'Profile Picture',
  AppStrings.groupNameHint: 'e.g. I-95 Convoy',
  AppStrings.saveAndChange: 'Save & Change',
  AppStrings.statusInfo: 'Status Info',
  AppStrings.gotIt: 'Got it',
  AppStrings.none: 'None',
  AppStrings.carInspection: 'CAR INSPECTION',
  AppStrings.vehicleOwnership: 'VEHICLE OWNERSHIP',
  AppStrings.accessDenied: 'Access Denied',
  AppStrings.ageRestrictionMessage: 'You must be at least 16 years old to use this app.',

  AppStrings.car: 'Car',
  AppStrings.motorcycle: 'Motorcycle',
  AppStrings.van: 'Van',
  AppStrings.other: 'Other',
  AppStrings.vehicleInfo: 'Vehicle Info',
  AppStrings.vehicleType: 'Vehicle Type',

  AppStrings.vehicleColor: 'Vehicle Color',
  AppStrings.submit: 'Submit',
  AppStrings.editGroup: 'Edit Group',
  AppStrings.imageSaveToGallery: 'Image Save To Gallery',
  AppStrings.notification:"Notification",
  AppStrings.submitDetails:"Submit Details",
  AppStrings.makeSureAllDocuments:"Make sure all documents are clear and readable.Blurry images may delay your approval.",
AppStrings.group:"Group",

  // -------- Notification Screen --------
  AppStrings.notifications: "Notifications",
  AppStrings.markAllRead: "Mark all read",
  AppStrings.deleteNotifications: "Delete notifications",
  AppStrings.deleteAllNotifications: "Are you sure you want to delete all notifications?",

  AppStrings.justNow: "just now",
  AppStrings.today: "Today",
  AppStrings.yesterday: "Yesterday",
  AppStrings.notificationNotYet: "No Notifications Yet",
  AppStrings.markAsRead: "Mark as read",
  AppStrings.read: "Read",

  AppStrings.deleteSuccess: "Deleted Successfully",
  AppStrings.addParking: "Add Parking",

  AppStrings.locationTurnedOff: "Location is turned off",
  AppStrings.locationOffDesc: "Please enable location from your device to see nearby parking reports on the map.",
  AppStrings.enableLocation: "Enable location",
  AppStrings.showingParking: "Showing parking within",

  AppStrings.usingCurrentLocation: "Using current location",
  AppStrings.selectedLocation: "Selected",
  AppStrings.pickOnMap: "Pick on map",
  AppStrings.change: "Change",
  AppStrings.mapFree: "Free",
  AppStrings.mapPaid: "Paid",

  AppStrings.disabledParking: "Disabled Parking",
  AppStrings.electricCharging2: "Electric Charging",
  AppStrings.paidParking: "Paid Parking",
  AppStrings.freeParking: "Free Parking",
  AppStrings.leaveSuccess: "Leave successfully",
  AppStrings.failedToLeave: "Failed to leave",

  AppStrings.plateScanner: "Plate Scanner",

  AppStrings.noPlateDetected: "No plate/number detected",

  AppStrings.ocrScanner: "OCR Scanner",
  AppStrings.scanQrCode: "Scan QR Code",
  AppStrings.ocrScannerSubtitle: "Extract text from images instantly",
  AppStrings.scanQrCodeSubtitle: "Scan any QR code with your camera",
  AppStrings.groupCreatedSuccess: "Group created successfully",
  AppStrings.groupCreatedFailed: "Failed to create group",
  AppStrings.downloading: "Downloading...",
  AppStrings.download: "Download",
   AppStrings.welcomeTitle : 'Your License Plate, Your Chat',

  AppStrings.welcomeSubtitle : 'Register quickly and connect with a wheewer wherever you go',




  // -------- Password Validation --------

  AppStrings.passwordMustBeAtLeast8Characters:
  "Password must be at least 8 characters",
  AppStrings.passwordMustContainUppercase:
  "Password must contain at least one uppercase letter",
  AppStrings.passwordMustContainLowercase:
  "Password must contain at least one lowercase letter",
  AppStrings.passwordMustContainNumber:
  "Password must contain at least one number",
  AppStrings.passwordMustContainSpecialCharacter:
  "Password must contain at least one special character",




  AppStrings.personalInformationSubtitle:
  "View and update your personal details.",


  AppStrings.myVehiclesSubtitle:
  "Manage your vehicles.",


  AppStrings.usefulNumbersSubtitle:
  "Quick access to important contacts.",


  AppStrings.notificationsSubtitle:
  "Manage your notification settings.",


  AppStrings.languageSubtitle:
  "Change app language.",

  AppStrings.english: "English",
  AppStrings.italian: "Italian",


  AppStrings.termsAndConditionsSubtitle:
  "Read our terms and conditions.",

  AppStrings.privacyPolicySubtitle:
  "Learn how we protect your privacy.",

  AppStrings.helpSupportSubtitle:
  "Get help and contact support.",

  AppStrings.faqSubtitle:
  "Find answers to common questions.",

  AppStrings.shareLinkSubtitle:
  "Share the app with your friends.",

  AppStrings.blockedUsersSubtitle:
  "Manage your blocked users.",

  AppStrings.deleteAccountSubtitle:
  "Permanently delete your account.",

  AppStrings.supportAndLegal: "Support & Legal",
  AppStrings.accountActions: "Account Actions",
  AppStrings.logOutSubtitle: "Sign out of your account.",
  AppStrings.personalInfoTitle: "Personal Info",

  AppStrings.changeAppLanguage:"Change app language.",

  AppStrings.confidenceLevel: "Confidence Level",
  AppStrings.highAccuracy: "High Accuracy",
  AppStrings.spotType: "Spot Type",
  AppStrings.paidSpot: "Paid Spot",
  AppStrings.freeSpot: "Free Spot",
  AppStrings.timeRemaining: "Time Remaining",

  // -------- Added during localization --------
  AppStrings.timeout: "Timeout",
  AppStrings.notificationSetupFailed: "Notification setup failed",
  AppStrings.loginConnectionTimeout: "Connection timeout. Please check your internet.",
  AppStrings.loginUnavailableTryAgain: "Login service is currently unavailable. Please try again.",
  AppStrings.loginFailedCheckConnection: "Login failed. Check your internet connection.",
  AppStrings.passwordChanged: "Password changed",
  AppStrings.country: "Country",
  AppStrings.countryIsRequired: "Country is required",
  AppStrings.city: "City",
  AppStrings.optional: "Optional",
  AppStrings.typing: "typing...",
  AppStrings.recording: "recording...",
  AppStrings.online: "online",
  AppStrings.micPermissionError: "Microphone permission error",
  AppStrings.addCaption: "Add caption",
  AppStrings.youveBlockedName: "You've blocked",
  AppStrings.storagePermissionRequired: "Storage permission required",
  AppStrings.downloadFailed: "Download failed",
  AppStrings.savedTo: "saved to",
  AppStrings.saveToGallery: "Save to Gallery",
  AppStrings.tapDownloadToOpen: "Tap download to open",
  AppStrings.downloadAndOpen: "Download and Open",
  AppStrings.licenseVerifiedSuccessfully: "License verified successfully",
  AppStrings.licenseVerificationFailed: "License verification failed",
  AppStrings.connectionTimeout: "Connection timeout",
  AppStrings.licenseAlreadyVerified: "License already verified",
  AppStrings.verified: "Verified",
  AppStrings.verify: "Verify",

  AppStrings.stayingDuration: "Staying Duration",
  AppStrings.forHowLongIsTheUserStayingInThatSpot: "For how long is the user staying in that spot?",
  AppStrings.parkingExpiring: "Parking Expiring",
  AppStrings.areYouLeavingThePaidSpotYourPaidSpotIsExpiringIn10Minutes: "Are you leaving the paid spot? Your paid spot is expiring in 10 minutes.",
  AppStrings.noStaying: "No, Staying",
  AppStrings.yesLeaving: "Yes, Leaving",
  AppStrings.savedParkingLocation: "Saved Parking Location",
  AppStrings.walkBackToCar: "Walk Back to Car",
  AppStrings.removeSpot: "Remove Spot",
  AppStrings.navigate: "Navigate",
  AppStrings.yourSavedParkingSpot: "Your Saved Parking Spot",

  AppStrings.searchParking: "Search parking",
  AppStrings.parkingConfirmation: "Are you about to leave your parking spot?",
  AppStrings.areYouLeavingAParkingSpotRightNow: "Your spot will become visible to nearby drivers looking for parking.",
  AppStrings.contactUsAt: "Contact us at",
  AppStrings.cropImage: "Crop Image",
  AppStrings.failedToLoadDocuments: "Failed to load documents",
  AppStrings.documentUploadedSuccessfully: "Document uploaded successfully",
  AppStrings.documentUpdatedSuccessfully: "Document updated successfully",
  AppStrings.updateFailed: "Update failed",
  AppStrings.accountSetting: "Account & Setting",
  AppStrings.takePhoto: "Take Photo",
  AppStrings.chooseFromGallery: "Choose from Gallery",
  AppStrings.browseFiles: "Browse Files",
  AppStrings.couldNotOpenCamera: "Could not open camera",
  AppStrings.couldNotOpenGallery: "Could not open gallery",
  AppStrings.pleaseAllowGalleryAccessToDownload: "Please allow gallery access to download",
  AppStrings.qrCardIsNotReadyYetPleaseTryAgain: "QR card is not ready yet. Please try again.",
  AppStrings.downloadSuccessfullyComplete: "download successfully complete",
  AppStrings.failedToDownloadQrCard: "Failed to download QR card",
  AppStrings.myQrCode: "My QR Code",
  AppStrings.vehicleDetails: "Vehicle Details",
  AppStrings.searchDrivers: "Search Drivers",
  AppStrings.searchByNameOrVehicleCode: "Search by name or vehicle code...",
  AppStrings.message: "Message",
  AppStrings.sendRequest: "Send Request",
  AppStrings.sendMessageRequest: "Send Message Request",
  AppStrings.writeAShortMessageToIntroduceYourself: "Write a short message to introduce yourself",
  AppStrings.hiCanIMessageYou: "Hi, can I message you?",
  AppStrings.messageIsRequired: "Message is required",
  AppStrings.noUsersFound: "No users found",
  AppStrings.failedToChangeLanguage: "Failed to change language",
  AppStrings.locationNotAvailableWait: "Location not available. Please wait for GPS or pick on map.",
  AppStrings.timeIsRequired: "Time is required",
  AppStrings.enterValidNumber: "Enter a valid number",
  AppStrings.minimum15MinutesRequired: "Minimum 15 minutes required",
  AppStrings.parkingLocationSavedSuccessfully: "Parking location saved successfully!",
  AppStrings.failedToSaveParkingLocation: "Failed to save parking location",
  AppStrings.usingPickedLocation: "Using picked location",
  AppStrings.pickedLocationSet: "Picked location set",
  AppStrings.savePickedLocation: "Save Picked Location",
  AppStrings.saveMyLocation: "Save My Location",
  AppStrings.free: "FREE",
  AppStrings.paid: "PAID",

  AppStrings.acknowledgedKeepingSpotActive: "Acknowledged. Keeping spot active.",
  AppStrings.parkingClearedReleasedSpotStatus: "Parking cleared. Released spot status.",
  AppStrings.confirm: "Confirm",


  // -------- Added during localization --------
  AppStrings.addYourVehicle: "Add Your Vehicle",
  AppStrings.skip: "Skip",
  AppStrings.vehicleModelAndColor: "Vehicle Model & Color",
  AppStrings.messageRequests: "Message Requests",
  AppStrings.receivedRequests: "Received Requests",
  AppStrings.requestsOthersSentToYou: "Requests others sent to you",
  AppStrings.requestsYouSentToOthers: "Requests you sent to others",
  AppStrings.sentRequests: "Sent Requests",
  AppStrings.areYouSureDeleteMessage: "Are you sure you want to delete this message?",
  AppStrings.deleteMessage: "Delete Message",
  AppStrings.accept: "Accept",
  AppStrings.decline: "Decline",
  AppStrings.reject: "Reject",
  AppStrings.block: "Block",
  AppStrings.withdraw: "Withdraw",
  AppStrings.newRequestsShowUpHere: "New requests will show up here",
  AppStrings.noPendingMessageRequests: "No pending message requests",
  AppStrings.wantsToSendYouAMessage: "wants to send you a message",
  AppStrings.noSentRequests: "No sent requests",
  AppStrings.requestsYouSendShowUpHere: "Requests you send will show up here",
  AppStrings.requestSent: "Request sent",
  AppStrings.mapType: "Map type",
  AppStrings.twoSpots: "2 spots",
  AppStrings.twoFiftyMAway: "250 m away",
  AppStrings.electric: "Electric",
  AppStrings.sideParking: "Side Parking",
  AppStrings.twentyDollarsPerHour: "\$ 20/hr",
  AppStrings.searchParkingSpotWithin: "Search Parking Spot Within",
  AppStrings.chooseDistanceRange: "Choose the distance range around you",
  AppStrings.quickSelect: "Quick Select",
  AppStrings.vehicleModelLabel: "Vehicle Model: ",




  AppStrings.pleaseEnableLocationService: "Please enable location service",
  AppStrings.locationPermissionDenied: "Location permission denied",
  AppStrings.failedToRetrieveParkingStatus: "Failed to retrieve parking status",
  AppStrings.failedToLoadNearbyHandoffSpots: "Failed to load nearby handoff spots",
  AppStrings.failedToLoadNearbyParkingAreas: "Failed to load nearby parking areas",
  AppStrings.failedToLoadNearbyParkingSpots: "Failed to load nearby parking spots",
  AppStrings.locationNotActiveOrAvailable: "Location is not active or available to report handoff",
  AppStrings.parkingSpotHandoffReportedSuccessfully: "Parking spot handoff reported successfully!",
  AppStrings.failedToRecordSpotHandoff: "Failed to record spot handoff.",
  AppStrings.failedToSetParkingModeIdle: "Failed to set parking mode to idle.",
  AppStrings.networkErrorReportingSpotHandoff: "Network error reporting spot handoff",
  AppStrings.parkModeActive: "ParkMode active: Fusing GPS and Accelerometer signals.",
  AppStrings.parkModeDeactivated: "ParkMode deactivated.",
  AppStrings.autoParkDetected: "Auto-Park Detected by Confidence Engine!",
  AppStrings.gpsLocationNotAvailable: "GPS Location not available to save spot.",
  AppStrings.savedParkingSpotRemoved: "Saved parking spot removed.",
  AppStrings.paidSpotTimerStarted: "Paid spot timer started for {minutes} minutes.",
  AppStrings.parkingSpotDurationExpired: "Parking spot duration has expired. Spot is now free.",
  AppStrings.theCarHasBeenParked: "The car has been parked.",
  AppStrings.isItAFreeSpotOrIsItAPaidSpot: "Is it a free spot or is it a paid spot?",

  AppStrings.areYouLeavingThePaidSpot: "Are you leaving the paid spot? Your paid spot is expiring in 10 minutes.",
  AppStrings.details: "Details",
  AppStrings.status: "Status",
  AppStrings.expiresAt: "Expires At",
  AppStrings.distance: "Distance",
  AppStrings.fromYourLocation: "from your location",
  AppStrings.name: "Name",
  AppStrings.description: "Description",
  AppStrings.parkingCost: "Parking Cost",
  AppStrings.isActive: "Is Active",

  AppStrings.tapToSeeWalkingRoute: "Tap to see walking route",
  AppStrings.polygonPoints: "Polygon Points",
  AppStrings.points: "points",
  AppStrings.paidSpotTimerStartedForMinutes:
  "Paid spot timer started for @minutes minutes.",

  AppStrings.failedToConnectToParkingService: "Failed to connect to parking service: @error",
  AppStrings.failedToLoadNearbyParkingSpotsWithError: "Failed to load nearby parking spots: @error",
  AppStrings.networkErrorReportingSpotHandoffWithError: "Network error reporting spot handoff: @error",
  AppStrings.parkingLocationSavedAsFreeSpot: "Parking location saved as Free Spot.",
  AppStrings.failedToLoadHandoffDetails: "Failed to load handoff details",
  AppStrings.networkErrorLoadingHandoffDetails: "Network error loading handoff details: @error",

  AppStrings.sendMessageTab: "Send Message",
  AppStrings.receiveRequestTab: "Receive Request",

  AppStrings.inAppNavigation: "Navigation",
  AppStrings.loadingRoute: "Loading route...",
  AppStrings.couldNotLoadRoute: "Couldn't load the route. Please try again.",
  AppStrings.locationPermissionRequiredForNavigation: "Location permission is required for navigation.",
  AppStrings.openSettings: "Open Settings",

  AppStrings.navModeWalking: "Walking",
  AppStrings.navModeDriving: "Driving",

  AppStrings.verifyAccountBecomeWheewer: "Verify your account to become a verified Wheewer user.",

  // -------- Parking Screen --------
  AppStrings.youreParked: "You're Parked",
  AppStrings.exitParking: "Exit Parking",
  AppStrings.yourParkingSpot: "Your Parking Spot",
  AppStrings.stopSearching: "Stop Searching",
  AppStrings.findParkingSpot: "Find Parking Spot",
  AppStrings.active: "Active",

  // -------- Vehicle Info Screen --------
  AppStrings.addYourVehicleSubtitle: "Tell us about your vehicle so we can personalize your experience.",
  AppStrings.enterVehicleModel: "Enter vehicle model",

  // -------- Message / Request Screens --------
  AppStrings.pendingReview: "Pending Review",
  AppStrings.withdrawRequestLabel: "Withdraw Request",
  AppStrings.youreNotFollowing: "You're not following this person",
  AppStrings.sendRequestDesc: "Send a request to start a conversation.\nThey'll review your request before you can message each other.",
  AppStrings.requestSentDesc: "Your request has been sent to @name. They will review it before you can start messaging.",
  AppStrings.withdrawRequestQuestion: "Withdraw your message request to @name?",
  AppStrings.withdrawRequestTitle: "Withdraw request?",
  AppStrings.acceptRequestFrom: "Accept request from @name?",
  AppStrings.acceptRequestDesc: "If you accept, they will also be able to message you and see info, such as your activity status and when you've read messages.",
  AppStrings.blockUserTitle: "Block @name?",
  AppStrings.blockUserDesc: "They won't be able to message you or find your profile again.",
  AppStrings.rejectRequestTitle: "Reject request?",
  AppStrings.rejectRequestFrom: "Reject the message request from @name?",
  AppStrings.acceptRequestTitle: "Accept request?",
  AppStrings.acceptRequestFromDesc: "Accept the message request from @name? You'll be able to message each other.",
  AppStrings.sendRequestTo: "Send a request to @name?",
  AppStrings.requestAcceptedDesc: "Accepted. You can now message each other.",

  // -------- Map / Parking Info --------
  AppStrings.defaultMapType: "Default",
  AppStrings.showElectricCharging: "Show location with electric charging",
  AppStrings.showDisabledParking: "Show disabled parking spot",
  AppStrings.dropPin: "Drop Pin",
  AppStrings.apply: "Apply",
  AppStrings.bookParkingSpot: "Book Parking Spot",
  AppStrings.location: "Location",

  // -------- Chat / Group --------
  AppStrings.leaveSuccessGroup: "Successfully left the group",
  AppStrings.fieldIsRequired: "Field is required",
  AppStrings.parkingFeePerHour: "Fee per hour (\$)",

  // -------- Auth --------
  AppStrings.loginSuccessful: "Login Successful",

  AppStrings.locationNotAvailable:
  "Location not available",

  AppStrings.tapMapToSelectLocation:
  "Tap on the map to select a location",

  AppStrings.mySavedParking:
  "My Saved Parking",

  AppStrings.tapToViewDetailsRoute:
  "Tap to view details & route",

  AppStrings.savePark: "Save Park",

  AppStrings.parkingSpotSaved: "Parking spot saved",
  AppStrings.failedToSaveParkingSpot: "Failed to save parking spot",
  AppStrings.duration: "Duration",
  AppStrings.mins: "mins",
  AppStrings.sessionStatus: "Session Status",
  AppStrings.na: "N/A",
  AppStrings.navigationLocationNotAvailable:
  "Navigation location not available",
  AppStrings.startWalkingNavigation:
  "Start Walking Navigation",

  AppStrings.youHaveArrived:
  "You have arrived",

  AppStrings.minSlower:
  "min slower",

  AppStrings.minFaster:
  "min faster",
  'kmh': 'km/h',
  AppStrings.licensePlateNotFound: 'License plate not found',
  AppStrings.noSavedParkingsYet: 'No saved parkings yet',
  AppStrings.saveParking: 'Save Parking',
  AppStrings.failedToLoadSavedParkings:
  'Failed to load saved parkings',
  AppStrings.couldNotOpenLink: 'Could not open link',
  AppStrings.noAppCanOpenThisLink: 'No app can open this link',


  AppStrings.invalidRequest: 'Invalid request. Please check your information.',
  AppStrings.unauthorizedPleaseSignInAgain: 'Unauthorized. Please sign in again.',
  AppStrings.noPermissionToPerformAction:
  'You do not have permission to perform this action.',
  AppStrings.requestedResourceNotFound:
  'The requested resource was not found.',
  AppStrings.documentAlreadyExists: 'This document already exists.',
  AppStrings.checkInformationAndTryAgain:
  'Please check the entered information and try again.',
  AppStrings.internalServerError:
  'Internal server error. Please try again later.',
  AppStrings.serverTemporarilyUnavailable:
  'Server is temporarily unavailable. Please try again later.',
  AppStrings.failedToLoadQrCard: 'Failed to load QR card',
  AppStrings.somethingWentWrongWhileLoadingQrCard:
  'Something went wrong while loading QR card',
  AppStrings.invalidPlateNumber: 'Invalid Plate Number',

  AppStrings.qrCardNotReady:
  'QR card is not ready yet. Please try again.',

  AppStrings.couldNotLaunchDialer: 'Could not launch dialer.',
  AppStrings.callNow: 'Call Now',

};

