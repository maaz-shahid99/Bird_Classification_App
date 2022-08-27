import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  File? _image;
  List? _outputs;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );

    setState(() {
      _loading = false;
      _outputs = output;
    });
    print('image sent classify image executed');
    print(Text(_outputs![0]["label"]));
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future getImage({required ImageSource source}) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    final imageTemporary = File(image.path);

    setState(() {
      this._image = imageTemporary;
      _loading = true;
    });

    classifyImage(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bird Classification'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              _image == null
                  ? Image.asset('assets/default_bird.png')
                  : Image.file(
                      _image!,
                      width: 0.8 * (MediaQuery.of(context).size.width),
                      height: 0.6 * (MediaQuery.of(context).size.height),
                      fit: BoxFit.fill,
                    ),
              SizedBox(
                height: 20,
              ),
              _image == null
                  ? Container()
                  : _outputs != null
                      ? Text(
                          _outputs![0]["label"],
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        )
                      : Container(child: Text("")),
              SizedBox(
                height: 10,
              ),
              CustomButton(
                title: 'Pick image from gallery',
                icon: Icons.image_outlined,
                onClick: () => getImage(source: ImageSource.gallery),
              ),
              CustomButton(
                title: 'Take picture',
                icon: Icons.camera_alt_outlined,
                onClick: () => getImage(source: ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget CustomButton({
  required String title,
  required IconData icon,
  required VoidCallback onClick,
}) {
  return Container(
    width: 280,
    child: ElevatedButton(
      onPressed: onClick,
      child: Row(
        children: [
          Icon(icon),
          SizedBox(
            width: 20,
          ),
          Text(title),
        ],
      ),
    ),
  );
}
