import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:predixinote/types/plant.dart';

import 'package:predixinote/types/parameter.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/constants.dart';
import 'package:predixinote/types/plant_group.dart';
import 'package:predixinote/types/project.dart';
import 'package:predixinote/types/user.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:predixinote/widgets/quick_calc.dart';

class PlantExporter {
  final Plant plant;

  PlantExporter(this.plant);

  pw.TableRow metaInfoRow(String title, String value) {
    return pw.TableRow(children: <pw.Widget>[
      pw.Container(
        padding: pw.EdgeInsets.all(5),
        child:
            pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ),
      pw.Container(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(value == null ? "" : value))
    ]);
  }

  pw.TableRow paramInfoRow(Parameter param) {
    return pw.TableRow(children: <pw.Widget>[
      pw.Container(
        padding: pw.EdgeInsets.all(5),
        child: pw.Text(param.name.toUpperCase(),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ),
      pw.Container(
        padding: pw.EdgeInsets.all(5),
        child: pw.Text(param.value.toString()),
      ),
      pw.Container(
          padding: pw.EdgeInsets.all(5), child: pw.Text(units[param.type])),
    ]);
  }

  Future exportPlantReportAsPDF() async {
    //get parameters
    final List<Parameter> parameters = (await DatabaseService()
            .parametersCollection
            .where('plantId', isEqualTo: plant.uid)
            .orderBy("index")
            .get())
        .docs
        .map((doc) => Parameter.fromJson(doc.data()))
        .toList();
    //re init calc db
    for (Parameter param in parameters) {
      updateCalcDB(param, plant);
    }
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    final PUser _user =
        await DatabaseService().getUserInformation(plant.userId);
    final PlantGroup plantGroup =
        await DatabaseService().getPlantGroupById(plant.groupId);
    final Project project =
        await DatabaseService().getProjectById(plantGroup.projectId);
    final fontTheme = pw.ThemeData.withFont(
        base: pw.Font.ttf(
            await rootBundle.load("assets/fonts/Roboto-Regular.ttf")),
        bold:
            pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf")),
        italic: pw.Font.ttf(
            await rootBundle.load("assets/fonts/Roboto-Italic.ttf")),
        boldItalic: pw.Font.ttf(
            await rootBundle.load("assets/fonts/Roboto-BoldItalic.ttf")));
    print("fonts loaded");
    final pw.Document doc = pw.Document();

    new Directory(appDocDirectory.path + '/' + 'dir').create(recursive: true)
// The created directory is returned as a Future.
        .then((Directory directory) {
      doc.addPage(pw.MultiPage(
          theme: fontTheme,
          pageFormat:
              PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          header: (pw.Context context) {
            if (context.pageNumber == 1) {
              return null;
            }
            return pw.Container(
                alignment: pw.Alignment.centerRight,
                margin:
                    const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                padding:
                    const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
                decoration: const pw.BoxDecoration(
                    border: pw.BoxBorder(
                        bottom: true, width: 0.5, color: PdfColors.grey)),
                child: pw.Text('Created by AquaNote',
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.grey)));
          },
          footer: (pw.Context context) {
            return pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                child: pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.grey)));
          },
          build: (pw.Context context) => <pw.Widget>[
                pw.Header(text: "ÖLÇÜM NOKTASI BİLGİLERİ"),
                pw.Table(
                    columnWidths: {
                      0: pw.FlexColumnWidth(1),
                      1: pw.FlexColumnWidth(2),
                    },
                    border: const pw.TableBorder(),
                    tableWidth: pw.TableWidth.max,
                    children: <pw.TableRow>[
                      metaInfoRow("PROJE ADI", project.name),
                      metaInfoRow("NOKTA ADI", plantGroup.name),
                      metaInfoRow("ÖLÇÜM ADI", plant.name.toUpperCase()),
                      metaInfoRow("TÜR", plant.type.toUpperCase()),
                      metaInfoRow(
                          "OLUŞTURULMA TARİHİ", plant.dateCreated.toString()),
                      metaInfoRow(
                          "ENLEM", plant.locationData.latitude.toString()),
                      metaInfoRow(
                          "BOYLAM", plant.locationData.longitude.toString()),
                      metaInfoRow(
                          "RAKIM", plant.locationData.altitude.toString()),
                      metaInfoRow("KONUM HASSASİYETİ",
                          plant.locationData.accuracy.toString()),
                      metaInfoRow(
                          "YETKİLİ KİŞİ",
                          _user == null
                              ? plant.userId
                              : "${_user.name} ${_user.surname}".toUpperCase()),
                    ]),
                pw.Table(
                    border: const pw.TableBorder(),
                    tableWidth: pw.TableWidth.max,
                    columnWidths: {
                      0: pw.FlexColumnWidth(1),
                      1: pw.FlexColumnWidth(1),
                      2: pw.FlexColumnWidth(1),
                    },
                    children: parameters
                        .map((param) => paramInfoRow(param))
                        .toList()),
                pw.Table(
                    border: const pw.TableBorder(),
                    tableWidth: pw.TableWidth.max,
                    columnWidths: {
                      0: pw.FlexColumnWidth(1),
                      1: pw.FlexColumnWidth(1),
                      2: pw.FlexColumnWidth(1),
                    },
                    children: <pw.TableRow>[
                      paramInfoRow(Parameter.of(
                          name: "TOPLAM GÜÇ",
                          value: calcDB["TP"],
                          type: "power")),
                      paramInfoRow(Parameter.of(
                          name: "BASMA YÜKSEKLİĞİ",
                          value: calcDB["HM"],
                          type: "hm")),
                      paramInfoRow(Parameter.of(
                          name: "HİDROLİK VERİM",
                          value: calcDB["NPUMP"],
                          type: "percentage")),
                    ]),
                pw.Header(
                  text: "AÇIKLAMA",
                ),
                (plant.additionalInfo == null)
                    ? pw.Paragraph(text: "Açıklama eklenmedi.")
                    : pw.Paragraph(text: plant.additionalInfo)
              ]));

      new Directory(appDocDirectory.path + '/' + 'dir').create(recursive: true)
// The created directory is returned as a Future.
          .then((Directory directory) {
        final File file = File(
            '${directory.path}/${plant.groupId}_${plant.name.toUpperCase()}.pdf'
                .replaceAll(' ', '_'));
        file.writeAsBytesSync(doc.save());
        print('Path of New Dir: ' + directory.path);
        OpenFile.open(file.path);
      });
    });
  }
}

class ProjectExporter {
  final Project project;
  final Map<String, PlantGroup> groupData;
  final Map<String, Plant> plantData;

  ProjectExporter(this.project, this.groupData, this.plantData);

  pw.TableRow plantRow(Plant plant, Map<String, double> data) {
    return pw.TableRow(

        children: [
      pw.Container(
        padding: pw.EdgeInsets.all(3),
          child: pw.Text(plant.name,)),
      pw.Container(padding: pw.EdgeInsets.all(3),child: pw.Text(plant.type)),
          pw.Container(padding: pw.EdgeInsets.all(3),child: pw.Text("${(data["Debi"]??0).toStringAsFixed(3)}")),
          pw.Container(padding: pw.EdgeInsets.all(3),child: pw.Text("${data["Toplam güç"].toStringAsFixed(3)}")),
      pw.Container(padding: pw.EdgeInsets.all(3),child: pw.Text("${data["Basma yüksekliği"].toStringAsFixed(3)}")),
      pw.Container(padding: pw.EdgeInsets.all(3),child: pw.Text("${data["Hidrolik verim"].toStringAsFixed(3)}")),
      pw.Container(padding: pw.EdgeInsets.all(3),child: pw.Text("${data["Su hızı"].toStringAsFixed(3)}")),
    ]);
  }


  Future<pw.Table> groupTable(PlantGroup plantGroup) async {
    List<pw.TableRow> rows=List<pw.TableRow>();

    //rows.add(pw.TableRow(children: [pw.Text(plantGroup.name)]));
    rows.add(pw.TableRow(
      verticalAlignment: pw.TableCellVerticalAlignment.middle,

        children: [
          pw.Padding(child:           pw.Text("Ölçüm adı",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,),), padding: pw.EdgeInsets.all(3)),
          pw.Padding(child:           pw.Text("Tür",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),), padding: pw.EdgeInsets.all(3)),
          pw.Padding(child:           pw.Text("Debi (m\u00B3/h)",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),), padding: pw.EdgeInsets.all(3)),
          pw.Padding(child:           pw.Text("Toplam güç (kW)",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),), padding: pw.EdgeInsets.all(3)),
          pw.Padding(child:           pw.Text("Hm (mSS)",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),), padding: pw.EdgeInsets.all(3)),
          pw.Padding(child:           pw.Text("Hidrolik verim (%)",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),padding: pw.EdgeInsets.all(3)),
          pw.Padding(child:           pw.Text("Su hızı (m/s)",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),), padding: pw.EdgeInsets.all(3)),
        ]
    ));
    await Future.forEach(plantData.values.where((plant) => plant.groupId==plantGroup.uid), (element) => QuickCalcOffline(element).getSummary().then((value) => rows.add(plantRow(element,value))));

    return pw.Table(
      border: pw.TableBorder(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(5 ),
              child:         pw.Text(plantGroup.name,style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center),

            ),
          ]
        ),
        pw.TableRow(
          children:[
            pw.Table(

                border: pw.TableBorder(),
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,

                columnWidths: {
                  0:pw.FlexColumnWidth(4),//plant title
                  1:pw.FlexColumnWidth(2),//plant type
                  2:pw.FlexColumnWidth(3),//debi
                  3:pw.FlexColumnWidth(3),//total power
                  4:pw.FlexColumnWidth(3),//hm
                  5:pw.FlexColumnWidth(3),//nPump
                  6:pw.FlexColumnWidth(3),//water speed
                },
                children: rows
            )
          ]
        )


      ]
    );
  }

  String plantAsCSVLine(Plant plant,Map<String, double> data){
    return "${plant.name},${plant.type},${data["Debi"]??0},${data["Debi"]??0},${data["Toplam güç"]??0},${data["Basma yüksekliği"]??0},${data["Hidrolik verim"]??0},${data["Su hızı"]??0};";
  }

  ///plantname,planttype,flow,totalPower,hm,nPump,waterSpeed;
  Future exportAsExcel()async{
    String res="";
    await Future.forEach(groupData.values, (plantGroup) => Future.forEach(plantData.values.where((plant) => plant.groupId==plantGroup.uid), (element) => QuickCalcOffline(element).getSummary().then((value) => res+=plantAsCSVLine(element, value)+";")));
    var excel = Excel.createExcel();
    Sheet sheetObject = excel["AQUAGUIDE"];
    CellStyle cellStyle = CellStyle(backgroundColorHex: "#1AFF1A", fontFamily : getFontFamily(FontFamily.Calibri));







    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    await new Directory(appDocDirectory.path + '/' + 'aquaguide_reports')
        .create(recursive: true).then((Directory directory){

      final File file = File(
          '${directory.path}/${project.name}_report.csv'
              .replaceAll(' ', '_'));
      file.writeAsStringSync(res);
      print('Path of New Dir: ' + directory.path);
      OpenFile.open(file.path);
    });







  }

  Future exportAsPDF() async {
    //prepare font theme
    final fontTheme = pw.ThemeData.withFont(
        base: pw.Font.ttf(
            await rootBundle.load("assets/fonts/Roboto-Regular.ttf")),
        bold:
            pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf")),
        italic: pw.Font.ttf(
            await rootBundle.load("assets/fonts/Roboto-Italic.ttf")),
        boldItalic: pw.Font.ttf(
            await rootBundle.load("assets/fonts/Roboto-BoldItalic.ttf")));
    print("fonts loaded");

    //get temp directory
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    //create a document
    final pw.Document doc = pw.Document();
    //add cover page
    doc.addPage(pw.Page(
      theme: fontTheme,
      pageFormat:
      PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      build: (pw.Context context) =>
        pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                  project.name,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 24,)
              ),
              pw.Text(
                  "Kuyu ve Terfi istasyonları raporu",style: pw.TextStyle(fontSize: 18,)
              ),
            ]
          )
        ),

    ));
    List<pw.Widget> groupTables=new List<pw.Widget>();
    await Future.forEach(groupData.values, (element) => groupTable(element).then((value) => groupTables.add(value)));

    doc.addPage(pw.MultiPage(
      
        theme: fontTheme,
        pageFormat:
        PdfPageFormat.a4.copyWith(marginBottom: 1.0 * PdfPageFormat.cm,marginTop: 1.0*PdfPageFormat.cm),
        build:(pw.Context context) =>groupTables

    ));


    final directory=await new Directory(appDocDirectory.path + '/' + 'aquaguide_reports')
        .create(recursive: true);
    if(directory==null)return;
    final File file = File(
        '${directory.path}/${project.name}_report.pdf'
            .replaceAll(' ', '_'));
    file.writeAsBytesSync(doc.save());
    print('Path of New Dir: ' + directory.path);

    return await OpenFile.open(file.path);



  }
}
