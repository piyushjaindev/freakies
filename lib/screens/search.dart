import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freakies/db/userservice.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:freakies/screens/profile.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _commentTextController = TextEditingController();
  String _searchTerm;
  UserService userService;
  CurrentUser user;

  @override
  void initState() {
    userService = UserService();
    user = Provider.of<CurrentUser>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: TextField(
            controller: _commentTextController,
            decoration: InputDecoration(
              hintText: 'Search users',
              contentPadding:
                  EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              focusedBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              suffixIcon: Icon(
                Icons.search,
              ),
            ),
            onChanged: (val) {
              String search = val.trim();
              if (search.isEmpty ||
                  search.length < 3 ||
                  search == null ||
                  search == '') {
                setState(() {
                  _searchTerm = null;
                });
              } else {
                setState(() {
                  _searchTerm = search.toLowerCase();
                });
              }
            }),
      ),
      body: _searchTerm == null
          ? Text('')
          : FutureBuilder(
              future: userService.searchUsers(_searchTerm),
              builder: (context, snapshot) {
//          if(snapshot.connectionState == ConnectionState.waiting)
//            return Loader();
                if (snapshot.hasData) {
                  Map<String, DocumentSnapshot> documentMap = snapshot.data;
                  List<DocumentSnapshot> documentList =
                      documentMap.values.toList();
                  return ListView.builder(
                      itemCount: documentList.length,
                      itemBuilder: (context, index) {
                        User user = User.create(documentList[index].data);
                        user.countFollow(userService);
                        user.setFollow(userService, user.id);
                        return Card(
                          elevation: 6.0,
                          margin: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          color: Colors.white,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Profile(
                                            user: user,
                                          )));
                            },
                            leading: CircleAvatar(
                              radius: 25.0,
                              backgroundImage: NetworkImage(user.dpURL),
                            ),
                            title: Text("@${user.username}"),
                            subtitle: Text(user.fullName),
                          ),
                        );
                      });
                }
                return Text('');
              },
            ),
    );
  }
}
