import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:corn_addiction/models/the_user.dart';

// Define your provider somewhere, for example:
final userListProvider = Provider<List<TheUser>?>((ref) {
  // Replace with your actual logic to provide the user list
  return null;
});

class UserList extends ConsumerStatefulWidget {
  const UserList({ Key? key }) : super(key: key);

  @override
  ConsumerState<UserList> createState() => _UserListState();
}

class _UserListState extends ConsumerState<UserList> {
  @override
  Widget build(BuildContext context) {

    final users = ref.watch(userListProvider);
    // print(brews.docs);
    if (users != null) {
      // for (var doc in users.docs) {
      //   print('print #1:');
      //   print(doc.data());
      // }
    }

    return Container(
      
    );
  }
}
