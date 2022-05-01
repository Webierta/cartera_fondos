import 'package:flutter/material.dart';

import '../models/data_api.dart';
import '../models/fondo.dart';
import '../services/api_service.dart';

class PageFondo extends StatefulWidget {
  final Fondo fondo;
  const PageFondo({Key? key, required this.fondo}) : super(key: key);

  @override
  State<PageFondo> createState() => _PageFondoState();
}

class _PageFondoState extends State<PageFondo> {
  //late Future<Album> futureAlbum;
  DataApi? dataApi;
  late ApiService apiService;
  //late apiData;

  @override
  void initState() {
    apiService = ApiService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DETALLE FONDO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // actualizar VL
              var getDataApi = await apiService.getDataApi(widget.fondo.isin);
              if (getDataApi != null) {
                setState(() {
                  dataApi = getDataApi;
                  // TODO: CREATE TABLA ? E INSERT DATA
                  //widget.fondo.insertVL(dataApi?.epochSecs as int, dataApi?.price as double);
                });
                //print(dataApi?.price);
              } else {
                print('ERROR GET DATAAPI');
              }
            },
          ),
          PopupMenuButton<int>(
              color: Colors.blue,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.edit),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 10),
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.login),
                        SizedBox(width: 10),
                        Text('Aportar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.logout),
                        SizedBox(width: 10),
                        Text('Reembolsar'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 10),
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.download_rounded),
                        SizedBox(width: 10),
                        Text('Exportar'),
                      ],
                    ),
                  ),
                ];
              }),
        ],
      ),
      body: ListView(
        children: [
          Text(widget.fondo.name),
          Text(widget.fondo.isin),
          // TODO: recuperar datos de la tabla
          /*Card(
            child: ListTile(
              title: Text('${widget.fondo.historico.last.keys}'),
              subtitle: Text('${widget.fondo.historico.last.entries}'),
              //subtitle: Text('${dataApi?.price ?? 'nada'}'),
            ),
          ),*/
          // ÍNDICES DE RENTABILIDAD
          Card(),
          // GRÁFICO
          Card(),
          // HISTORICO DE VALORES
          // FECHA - VL
          Card(),
        ],
      ),
    );
  }
}
