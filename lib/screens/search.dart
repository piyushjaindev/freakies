import 'package:flutter/material.dart';
import 'package:freakies/db/userservice.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:freakies/screens/profile.dart';
import 'package:freakies/widgets/loader.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _commentTextController;
  String _searchTerm;
  UserService userService;
  CurrentUser user;

  @override
  void initState() {
    userService = UserService();
    _commentTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<CurrentUser>(context);
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
            onSubmitted: (val) {
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
              future: userService.searchUsers(
                  searchTerm: _searchTerm, cid: user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Loader();
                else if (snapshot.hasData) {
                  List<User> users = snapshot.data;

                  return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
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
                                            user: users[index],
                                          )));
                            },
                            leading: CircleAvatar(
                              radius: 25.0,
                              backgroundImage: NetworkImage(users[index].dpURL),
                            ),
                            title: Text("@${users[index].username}"),
                            subtitle: Text(users[index].fullName),
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
