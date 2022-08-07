import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:haicom/widgets/button_widget.dart';
import 'package:haicom/widgets/image_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _textFieldController = TextEditingController();
  List _data = [];

  Future<void> readJson() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/data.json');
      final String response = await file.readAsString();
      final data = await json.decode(response);
      setState(() {
        _data = data["data"];
      });
    } catch (e) {
      // print("Couldn't read file");
    }
  }

  Future<void> writeJson(XFile image) async {
    final String path = (await getApplicationDocumentsDirectory()).path;
    await image.saveTo('$path/${_textFieldController.text.trim()}');
    String uuid = generateRandomString(15);
    _data.insert(
      0,
      {
        "id": uuid,
        "title": _textFieldController.text.trim(),
        "image": '$path/${_textFieldController.text.trim()}',
        "order": ""
      },
    );
    final File file = File('$path/data.json');
    file.writeAsStringSync(json.encode({"data": _data}));
    setState(() {});
  }

  Future<void> _showTextInputDialog(
    BuildContext context,
    XFile image,
  ) {
    Size size = MediaQuery.of(context).size;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Preview'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(image.path),
                fit: BoxFit.cover,
                height: size.height * 0.3,
                width: size.width * 0.8,
              ),
              TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: "Enter image name"),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () async {
                Navigator.pop(context);
                writeJson(image);
              },
            ),
          ],
        );
      },
    );
  }

  String generateRandomString(int len) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  @override
  void initState() {
    readJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Drag & Drop Gridview"),
      ),
      body: _data.isEmpty
          ? const Center(
              child: Text(
                "Nothing to show.\nAdd image",
                textAlign: TextAlign.center,
              ),
            )
          : ReorderableGridView.count(
              crossAxisCount: (size.width / 150).ceil(),
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 8.0,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              onReorder: (oldIndex, newIndex) async {
                setState(() {
                  final element = _data.removeAt(oldIndex);
                  _data.insert(newIndex, element);
                });
                final String path =
                    (await getApplicationDocumentsDirectory()).path;
                final File file = File('$path/data.json');
                file.writeAsStringSync(json.encode({"data": _data}));
              },
              children: [
                for (int i = 0; i < _data.length; i++)
                  ImageCard(
                    _data[i],
                    key: ValueKey(_data[i]["id"]),
                  )
              ],
            ),
      bottomNavigationBar: Row(
        children: [
          ButtonWidget(
            () async {
              final ImagePicker picker = ImagePicker();
              // Pick an image
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                _textFieldController.text = image.name;
                // ignore: use_build_context_synchronously
                _showTextInputDialog(context, image);
              }
            },
            "Image",
          ),
          const SizedBox(width: 1),
          ButtonWidget(
            () async {
              final ImagePicker picker = ImagePicker();
              // Capture a photo
              final XFile? image =
                  await picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                _textFieldController.text = image.path.split("/").last;
                // ignore: use_build_context_synchronously
                _showTextInputDialog(context, image);
              }
            },
            "Camera",
          ),
        ],
      ),
    );
  }
}
