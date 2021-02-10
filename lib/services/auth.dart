import 'package:firebase_auth/firebase_auth.dart';
import 'package:predixinote/types/user.dart' ;
class AuthService{
  final _auth=FirebaseAuth.instance;


  PUser fromFirebaseUser(User firebaseUser){
    return firebaseUser==null?null:PUser(uid:firebaseUser.uid);
  }

  //listen auth state
  Stream<PUser> get user{
    return _auth.authStateChanges().map((User firebaseUser)=>fromFirebaseUser(firebaseUser));
  }
  Future signInAnon() async{
    try{
      var result=await _auth.signInAnonymously();
      User user=result.user;
      return user;
    }catch (e){
      print(e.toString());
      return null;
    }
  }


  Future signInEmailPass(String email,String password) async{
    try{
      var result=await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user=result.user;
      return fromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }


  Future signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      print(e);
      return null;

    }
  }

  Future createUser(PUser user,String password) async {
    try{
       var result= await _auth.createUserWithEmailAndPassword(email: user.username, password: password);
       return result.user;
    } catch(e){
      print(e);
      return null;
    }
  }
  Future<bool> isEmailVerified()async{
    User user=  _auth.currentUser;
    return user.emailVerified;
  }
  Future<void> sendVerificationEmail()async{
    User user=  _auth.currentUser;
    await user.sendEmailVerification();
  }




}