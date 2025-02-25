// yikum_groceries_list.dart
// Mikael Yikum
// Grocery List Lab


import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:path_provider/path_provider.dart";

class BufState {
  List<String> groceryList;     // list of grocery items
  bool loaded;                  // state of the file

  BufState(this.groceryList, this.loaded);
}

class BufCubit extends Cubit<BufState> {
  BufCubit() : super(BufState([], false));

  // function tou update the grocery list
  void updateList(List<String> newList) {
    emit(BufState(newList, true));
  }

  // function to add an item to list
  void addItem(String item) {
    List<String> updatedList = List.from(state.groceryList)..add(item);
    emit(BufState(updatedList, true));
  }
}

void main() {
  runApp(FileStuff());
}

class FileStuff extends StatelessWidget {
  FileStuff({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Grocery List",
      home: BlocProvider<BufCubit>(
        create: (context) => BufCubit(),
        child: BlocBuilder<BufCubit, BufState>(
          builder: (context, state) => FileStuff2(),
        ),
      ),
    );
  }
}

class FileStuff2 extends StatelessWidget {
  FileStuff2({super.key});

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    BufCubit bc = BlocProvider.of<BufCubit>(context);
    BufState bs = bc.state;

    return Scaffold(
      appBar: AppBar(
        title: Text("Grocery List"),
      ),
      body: Column(
        children: [
            Container(
              height: 300,
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(width: 1),
              ),
              child: ListView.builder(
                itemCount: bs.groceryList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(bs.groceryList[index]),
                  );
                },
              ),
            ),

            Container(height: 20),

            Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                ),
                child: TextField(
                  controller: controller,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    hintText: "Add item",
                  ),
                ),
              ),

              Container(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(   
                        onPressed: () async {
                          List<String> contents = await readFile();
                          bc.updateList(contents);
                        },
                        child: Text("Load", style: TextStyle(fontSize: 20)),
                      ),

                      Container(width: 20),

                      FloatingActionButton(
                        onPressed: () {
                            bc.addItem(controller.text);
                          },
                          child: Text("Add", style: TextStyle(fontSize: 20)),
                        ),

                        Container(width: 20),

                        FloatingActionButton(
                          onPressed: () async {
                            await writeFile(bs.groceryList);
                          },
                          child: Text("Save", style: TextStyle(fontSize: 20)),
                        ),
                      
              ])
          
        ],
      ),
    );
  }

  
  Future<String> whereAmI() async {
  
      Directory mainDir = await getApplicationDocumentsDirectory();
      String mainDirPath = mainDir.path;
      print("MainDir path: $mainDirPath");
      return mainDirPath;
  }

  Future<void> writeFile(List<String> groceryList) async {
      String myDir  = await whereAmI();
      String filePath = "$myDir/grocery_list.txt";
      File file = File(filePath);
      await file.writeAsString(groceryList.join("\n"));

  }

  Future<List<String>> readFile() async {
    { await Future.delayed( const Duration(seconds:2) ); }

      String myDir = await whereAmI();
      String filePath = "$myDir/grocery_list.txt";

      File fodder = File(filePath);
      String contents = fodder.readAsStringSync();
      return contents.split("\n");

  }
}




