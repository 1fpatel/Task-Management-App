import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/utils/firestoreconstants.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// SIGN IN WITH GOOGLE
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // If user cancels login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
        await _saveUserToSharedPreferences(user);
      }

      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /// SAVE USER DATA TO FIRESTORE
  Future<void> _saveUserToFirestore(User user) async {
    DocumentSnapshot userDoc = await _firestore.collection(FirestoreConstants.pathUserCollection).doc(user.uid).get();

    if (!userDoc.exists) {
      await _firestore.collection(FirestoreConstants.pathUserCollection).doc(user.uid).set({
        FirestoreConstants.userid: user.uid,
        FirestoreConstants.name: user.displayName ?? 'User',
        FirestoreConstants.email: user.email,
        FirestoreConstants.profileurl: user.photoURL ?? '',
        FirestoreConstants.createdAt: DateTime.now(),
      });
    }
  }

  /// SAVE USER DATA TO SHARED PREFERENCES
  Future<void> _saveUserToSharedPreferences(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(FirestoreConstants.userid, user.uid);
    await prefs.setString(FirestoreConstants.name, user.displayName ?? 'No Name');
    await prefs.setString(FirestoreConstants.email, user.email ?? '');
    await prefs.setString(FirestoreConstants.profileurl, user.photoURL ?? '');
  }

  /// LOGOUT FUNCTION
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// CLEAR SHARED PREFERENCES ON LOGOUT
  Future<void> _clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _clearSharedPreferences(); // Clear stored user data
  }
  /// GET CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }


  /// GET USER DATA FROM SHARED PREFERENCES
  Future<Map<String, String?>> getUserFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      FirestoreConstants.userid: prefs.getString(FirestoreConstants.userid),
      FirestoreConstants.name: prefs.getString(FirestoreConstants.name),
      FirestoreConstants.email: prefs.getString(FirestoreConstants.email),
      FirestoreConstants.profileurl: prefs.getString(FirestoreConstants.profileurl),
    };
  }

}



/*                              onTap: () async {
                                await Utils.setUserId(null, null);
                                profileProvider.clearProvider();
                                // Firebase Signout
                                try {
                                  await _auth.signOut();
                                  await GoogleSignIn().signOut();
                                } catch (e) {
                                  debugPrint("Logout Exception =====> $e");
                                }
                                if (!mounted) return;
                                Navigator.pop(context);
                                if (!mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Login(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
*/

/*                                      onTap: () async {

                                        final prefs = await SharedPreferences.getInstance();
                                        // prefs.setString('token', token);

                                        prefs.clear();
                                        context.read<UserDetailsProvider>().signOut();
                                        await GoogleSignIn().signOut();
                                        await FirebaseAuth.instance.signOut();
                                        final GoogleSignInAccount? googleUser = await GoogleSignIn().signOut();

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          // MaterialPageRoute(builder: (context) => SignUpScreen()),
                                          MaterialPageRoute(builder: (context) => LoginTabview()),
                                              (Route<dynamic> route) => false,);
                                      },
*/