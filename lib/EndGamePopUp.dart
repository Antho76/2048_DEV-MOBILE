import 'package:flutter/material.dart';


class SimpleAppBarPopupMenuButton extends StatelessWidget {
  const SimpleAppBarPopupMenuButton({super.key});

  // definition of the dialog
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert!!"),
          content: const Text("You are awesome!"),
          actions: [
            MaterialButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // MaterialApp  with debugShowCheckedModeBanner
    // false and title.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AppBar Popup Menu Button',
      // scaffold with appbar
      home: Scaffold(
        // appbar with title text
        appBar: AppBar(
          title: const Text('AppBar Popup Menu Button'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          // in action widget we have PopupMenuButton
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) => [
                // PopupMenuItem 1
                PopupMenuItem(
                  value: 1,
                  // row with 2 children
                  child: Row(
                    children: [
                      const Icon(Icons.star),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text("Get The App")
                    ],
                  ),
                ),
                // PopupMenuItem 2
                PopupMenuItem(
                  value: 2,
                  // row with two children
                  child: Row(
                    children: [
                      const Icon(Icons.chrome_reader_mode),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text("About")
                    ],
                  ),
                ),
              ],
              offset: const Offset(0, 100),
              color: Colors.green,
              elevation: 2,
              // on selected we show the dialog box
              onSelected: (value) {
                // if value 1 show dialog
                if (value == 1) {
                  _showDialog(context);
                  // if value 2 show dialog
                } else if (value == 2) {
                  _showDialog(context);
                }
              },
            ),
          ],
        ),
        // body with centered text
        body: const Center(
          child: Text("Press the 3 Point Button Up!"),
        ),
      ),
    );
  }
}