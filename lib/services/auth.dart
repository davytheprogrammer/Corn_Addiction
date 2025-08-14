import 'package:firebase_auth/firebase_auth.dart';
import 'package:corn_addiction/models/the_user.dart';
import 'package:corn_addiction/models/user_model.dart';
import 'package:corn_addiction/models/streak_model.dart';
import 'package:corn_addiction/services/firestore_service.dart';
import 'package:corn_addiction/services/local_storage_service.dart';

class AuthResult {
  final TheUser? user;
  final String? errorMessage;
  final bool success;

  AuthResult({
    this.user,
    this.errorMessage,
    required this.success,
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Convert Firebase User to our TheUser model
  TheUser? _userFromFirebaseUser(User? user) {
    return user != null ? TheUser(uid: user.uid) : null;
  }

  // Auth state changes stream
  Stream<TheUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Anonymous sign in
  Future<AuthResult> signInAnon() async {
    try {
      final UserCredential result = await _auth.signInAnonymously();
      final User? user = result.user;
      
      if (user != null) {
        // Create the user model
        final UserModel newUser = UserModel(
          uid: user.uid,
          email: 'anonymous@user.com',
          displayName: 'Anonymous User',
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
          isAnonymous: true,
        );
        
        // Save to Firestore
        await _firestoreService.createUser(newUser);
        
        // Create initial streak
        final StreakModel streak = StreakModel(
          id: '',
          userId: user.uid,
          startDate: DateTime.now(),
          daysCount: 0,
          isActive: true,
        );
        
        await _firestoreService.createStreak(streak);
        
        // Cache basic user data locally
        await LocalStorageService.saveUserData({
          'uid': user.uid,
          'displayName': 'Anonymous User',
          'isAnonymous': true,
        });
        
        return AuthResult(
          user: _userFromFirebaseUser(user),
          success: true,
        );
      }
      
      return AuthResult(
        success: false,
        errorMessage: 'Failed to sign in anonymously',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getReadableErrorMessage(e),
      );
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final User? user = result.user;
      
      if (user != null) {
        // Get user data from Firestore
        final UserModel? userData = await _firestoreService.getUser(user.uid);
        
        if (userData != null) {
          // Update last active timestamp
          await _firestoreService.updateUserField(
            user.uid, 
            'lastActive', 
            DateTime.now()
          );
          
          // Cache user data locally
          await LocalStorageService.saveUserData({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName ?? userData.displayName,
            'isAnonymous': false,
          });
        }
        
        return AuthResult(
          user: _userFromFirebaseUser(user),
          success: true,
        );
      }
      
      return AuthResult(
        success: false,
        errorMessage: 'Failed to sign in',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getReadableErrorMessage(e),
      );
    }
  }

  // Register with email and password
  Future<AuthResult> registerWithEmailAndPassword(
      String displayName, String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final User? user = result.user;
      
      if (user != null) {
        // Update user profile
        await user.updateDisplayName(displayName);
        
        // Create the user model
        final UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
          recoveryStartDate: DateTime.now(),
          isAnonymous: false,
        );
        
        // Save to Firestore
        await _firestoreService.createUser(newUser);
        
        // Create initial streak
        final StreakModel streak = StreakModel(
          id: '',
          userId: user.uid,
          startDate: DateTime.now(),
          daysCount: 0,
          isActive: true,
        );
        
        await _firestoreService.createStreak(streak);
        
        // Cache user data locally
        await LocalStorageService.saveUserData({
          'uid': user.uid,
          'email': email,
          'displayName': displayName,
          'isAnonymous': false,
        });
        
        return AuthResult(
          user: _userFromFirebaseUser(user),
          success: true,
        );
      }
      
      return AuthResult(
        success: false,
        errorMessage: 'Failed to register',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getReadableErrorMessage(e),
      );
    }
  }
  
  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(
        success: true,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getReadableErrorMessage(e),
      );
    }
  }
  
  // Update user profile
  Future<AuthResult> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        return AuthResult(
          success: false,
          errorMessage: 'No user is signed in',
        );
      }
      
      await user.updateDisplayName(displayName ?? user.displayName);
      await user.updatePhotoURL(photoURL ?? user.photoURL);
      
      // Update Firestore data
      if (displayName != null) {
        await _firestoreService.updateUserField(user.uid, 'displayName', displayName);
      }
      
      // Update local storage
      final userData = await LocalStorageService.getUserData() ?? {};
      userData['displayName'] = displayName ?? userData['displayName'];
      await LocalStorageService.saveUserData(userData);
      
      return AuthResult(
        success: true,
        user: _userFromFirebaseUser(user),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getReadableErrorMessage(e),
      );
    }
  }
  
  // Update email
  Future<AuthResult> updateEmail(String newEmail, String password) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        return AuthResult(
          success: false,
          errorMessage: 'No user is signed in',
        );
      }
      
      // Re-authenticate user for security-sensitive operations
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updateEmail(newEmail);
      
      // Update Firestore data
      await _firestoreService.updateUserField(user.uid, 'email', newEmail);
      
      // Update local storage
      final userData = await LocalStorageService.getUserData() ?? {};
      userData['email'] = newEmail;
      await LocalStorageService.saveUserData(userData);
      
      return AuthResult(
        success: true,
        user: _userFromFirebaseUser(user),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getReadableErrorMessage(e),
      );
    }
  }
  
  // Update password
  Future<AuthResult> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null || user.email == null) {
        return AuthResult(
          success: false,
          errorMessage: 'No user is signed in or user has no email',
        );
      }
      
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      
      return AuthResult(
        success: true,
        user: _userFromFirebaseUser(user),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getReadableErrorMessage(e),
      );
    }
  }
  
  // Convert anonymous account to permanent
  Future<AuthResult> convertAnonymousAccount(String email, String password, String displayName) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null || !user.isAnonymous) {
        return AuthResult(
          success: false,
          errorMessage: 'No anonymous user is signed in',
        );
      }
      
      // Create credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      // Link anonymous account with credential
      await user.linkWithCredential(credential);
      await user.updateDisplayName(displayName);
      
      // Update user data in Firestore
      await _firestoreService.updateUserField(user.uid, 'email', email);
      await _firestoreService.updateUserField(user.uid, 'displayName', displayName);
      await _firestoreService.updateUserField(user.uid, 'isAnonymous', false);
      
      // Update local storage
      final userData = await LocalStorageService.getUserData() ?? {};
      userData['email'] = email;
      userData['displayName'] = displayName;
      userData['isAnonymous'] = false;
      await LocalStorageService.saveUserData(userData);
      
      return AuthResult(
        success: true,
        user: _userFromFirebaseUser(user),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getReadableErrorMessage(e),
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await LocalStorageService.clearUserData();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
  
  // Delete account
  Future<AuthResult> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        return AuthResult(
          success: false,
          errorMessage: 'No user is signed in',
        );
      }
      
      if (!user.isAnonymous && user.email != null) {
        // Re-authenticate user for security-sensitive operations
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        
        await user.reauthenticateWithCredential(credential);
      }
      
      // Delete user data from Firestore first
      // This could be expanded to delete all collections related to the user
      
      // Delete authentication user
      await user.delete();
      
      // Clear local storage
      await LocalStorageService.clearAll();
      
      return AuthResult(
        success: true,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _getReadableErrorMessage(e),
      );
    }
  }

  // Helper to provide readable error messages
  String _getReadableErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'operation-not-allowed':
          return 'Operation not allowed. Contact support.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        case 'requires-recent-login':
          return 'Please sign in again before retrying this operation.';
        default:
          return error.message ?? 'Authentication error occurred.';
      }
    }
    return error.toString();
  }
}
