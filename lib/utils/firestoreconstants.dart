
import 'package:task_management/utils/constant.dart';

class FirestoreConstants {
  /* Firestore */
  static String pathUserCollection = "users_${Constant.appName.toLowerCase().replaceAll(" ", "")}";

  /* User */
  static const id = "id";
  static const userid = "userid";
  static const name = "name";
  static const email = "email";
  static const profileurl = "profileurl";
  static const createdAt = "createdAt";
  static const username = "username";


}
