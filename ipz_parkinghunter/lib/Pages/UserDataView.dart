import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class UserDataView extends StatelessWidget {
  final String documentID;
  final user = FirebaseAuth.instance.currentUser!;
  UserDataView(this.documentID);
  final firestore = FirebaseFirestore.instance;
  var imie;
  var nazwisko;
  var phone_number;
  var creditcard;
  var plate;
  var email;
  get data => null;
 

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('UserData');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentID).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text('Brak bazy');
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          this.imie = data['imie'];
          this.nazwisko = data['nazwisko'];
          this.phone_number=data['nrtel'];
          this.creditcard=data['creditcard'];
          this.plate=data['plate'];
          //return Text("imie ${data['imie']} ${data['nazwisko']}");
        }
        return Scaffold(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Color.fromARGB(247, 15, 101, 158),
            title: Text('Moje Dane'),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //name
                  TextFormField(
                    //controller: nameController,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: imie,
                        border: OutlineInputBorder(),
                      )
                  ),
                  SizedBox(height: 16),
                  //last name
                  TextFormField(
                    //controller: nameController,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: nazwisko,
                        border: OutlineInputBorder(),
                      )
                  ),
                  SizedBox(height: 16),
                  //phone number
                  TextFormField(
                    //controller: nameController,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: phone_number,
                        border: OutlineInputBorder(),
                      )
                  ),
                  //email
                 SizedBox(height: 16),
                  TextFormField(
                    //controller: nameController,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText:user.email! ,
                        border: OutlineInputBorder(),
                      )
                  ),
                  //card number
                  SizedBox(height: 16),
                  TextFormField(
                    //controller: nameController,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: creditcard,
                        border: OutlineInputBorder(),
                      )
                  ),
                  //plate number
                  SizedBox(height: 16),
                  TextFormField(
                    //controller: nameController,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: plate,
                        border: OutlineInputBorder(),
                      )
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                      //saving data button, need to be sure all fields are filled
                      onPressed: () => Navigator.pop(context),
                      child: Text('Zapisz')
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
