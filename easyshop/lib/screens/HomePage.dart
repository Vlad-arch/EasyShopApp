import 'package:easyshop/auth.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> signOut()async{
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 140,
        title: Image.asset(
          'assets/icons/logo_app.png',
          height: 120,
        ),
        actions: [
          IconButton(onPressed: (){
            signOut();
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(

            )
          ],
        ), 
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){}),
    );
  }
}