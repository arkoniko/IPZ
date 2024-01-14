import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ipz_parkinghunter/Pages/BugReportView.dart';
import 'package:ipz_parkinghunter/Pages/UserDataView.dart';

class BurgerMenu extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;
  
  void SignUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void ReportBug(BuildContext context){
    //Open BugReport Page
    Navigator.push(context, 
    MaterialPageRoute(
      builder: (context)=>BugReportView()
      ),
      );
  }

void DataView(BuildContext context){
    //Open BugReport Page
    Navigator.push(context, 
    MaterialPageRoute(
      builder: (context)=>UserDataView(user.uid)
      ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader( // About user in sidebar
            decoration: BoxDecoration(color: Color.fromARGB(247, 15, 101, 158)),//login backgorund 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Circle cut and align "AA" to the left top
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      "AA",//profile icon 
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                Text(
                  user.email!,
                  style: TextStyle(color: Colors.white, fontSize: 26),
                )
              ],
            ),
          ),
          ListTile(
            onTap: () {
              // Onetap underline
              Navigator.pop(context); // Closes sidebar
              // TBD
            },
            leading: Icon(Icons.home),
            title: Text("Strona główna", style: TextStyle(fontSize: 16)),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              // TBD
            },
            leading: Icon(Icons.search),
            title: Text("Wyszukaj", style: TextStyle(fontSize: 16)),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              // TBD
            },
            leading: Icon(Icons.local_parking),
            title: Text("Parking", style: TextStyle(fontSize: 16)),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              // TBD
            },
            leading: Icon(Icons.access_time),
            title: Text("Historia płatności", style: TextStyle(fontSize: 16)),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              // TBD
            },
            leading: Icon(Icons.shopping_cart),
            title: Text("Kup Premium", style: TextStyle(fontSize: 16)),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              // TBD
            },
            leading: Icon(Icons.settings),
            title: Text("Ustawienia", style: TextStyle(fontSize: 16)),
          ),
          ListTile(
            onTap: () {
              DataView(context);
              // TBD
            },
            leading: Icon(Icons.person),
            title: Text("Moje Dane", style: TextStyle(fontSize: 16)),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              // TBD
            },
            leading: Icon(Icons.question_mark),
            title: Text("Pomoc", style: TextStyle(fontSize: 16)),
          ),
          Divider(
            color: Color.fromARGB(255, 107, 107, 107),
          ), // to separate main functions from help ones
          ListTile(
            onTap: () {
              ReportBug(context);
              // TBD
            },
            leading: Icon(Icons.bug_report),
            title: Text("Zgłoś błąd", style: TextStyle(fontSize: 16)),
          ),
          ListTile(
            onTap: () {
              SignUserOut();
              Navigator.pop(context);
            },
            leading: Icon(Icons.logout),
            title: Text("Wyloguj się", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}