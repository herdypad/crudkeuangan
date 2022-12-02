import 'package:flutter/material.dart';
import 'package:kelolahuang/db/database_instance.dart';
import 'package:kelolahuang/model/transaksi_model.dart';
import 'package:kelolahuang/screens/create_screen.dart';
import 'package:kelolahuang/screens/update_screen.dart';

void main() {
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kelola Keuangan",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseInstance? databaseInstance;

  Future _refresh() async {
    setState(() {});
  }

  @override
  void initState() {
    databaseInstance = DatabaseInstance();
    initDatabase();
    super.initState();
  }

  Future initDatabase() async {
    await databaseInstance!.database();
    setState(() {});
  }

  Future<void> _showMyDialog(BuildContext contex, int idTransaksi) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Yakin Ingin Menghapus.'),
                Text('Data yg dihapus tidak akan bisa kembali'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                databaseInstance!.hapus(idTransaksi);
                Navigator.of(context).pop();
                _refresh();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home Kelola Duitku"),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context)
                    .push(
                        MaterialPageRoute(builder: (context) => CreateScreen()))
                    .then((value) {
                  setState(() {});
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _refresh();
              },
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: SafeArea(
              child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: databaseInstance!.totalPemasukan(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("-");
                    } else {
                      if (snapshot.hasData) {
                        return Text(
                            "Total pemasukan : Rp. ${snapshot.data.toString()}");
                      } else {
                        return Text("");
                      }
                    }
                  }),
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: databaseInstance!.totalPengeluaran(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("-");
                    } else {
                      if (snapshot.hasData) {
                        return Text(
                            "Total pengeluaran : Rp. ${snapshot.data.toString()}");
                      } else {
                        return Text("");
                      }
                    }
                  }),
              FutureBuilder<List<TransaksiModel>>(
                  future: databaseInstance!.getAll(),
                  builder: (context, snapshot) {
                    print('HASIL : ' + snapshot.data.toString());
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    } else {
                      if (snapshot.hasData) {
                        return Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                    title: Text(snapshot.data![index].name!),
                                    subtitle: Text(snapshot.data![index].total!
                                        .toString()),
                                    leading: snapshot.data![index].type == 1
                                        ? Icon(
                                            Icons.download,
                                            color: Colors.green,
                                          )
                                        : Icon(
                                            Icons.upload,
                                            color: Colors.red,
                                          ),
                                    trailing: Wrap(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          UpdateScreen(
                                                            transaksiMmodel:
                                                                snapshot.data![
                                                                    index],
                                                          )))
                                                  .then((value) {
                                                setState(() {});
                                              });
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.grey,
                                            )),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              _showMyDialog(context,
                                                  snapshot.data![index].id!);
                                            },
                                            icon: Icon(Icons.delete,
                                                color: Colors.red))
                                      ],
                                    ));
                              }),
                        );
                      } else {
                        print("Tidak ada Data");
                        return Text("Tidak ada Data");
                      }
                    }
                  }),
            ],
          )),
        ));
  }
}
