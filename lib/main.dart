import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lic Payment Remaindar',
      home: MyHomePage(),
      theme: new ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.green[800],
          accentColor: Colors.cyan[600],
          fontFamily: 'Montserrat',
          textTheme: TextTheme(
            headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lic Payment Remaindar')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('lic').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: sortedRecords(snapshot, context),
//      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  List<Widget> sortedRecords(
      List<DocumentSnapshot> snapshot, BuildContext context) {
    List<Record> records =
        snapshot.map((data) => Record.fromSnapshot(data)).toList();
    records.sort(compare);
    return records.map((data) => _buildListItem(context, data)).toList();
  }

  int compare(a, b) {
//    int cur=new DateTime.now().month;
    int first = a.openDate.toDate().month + (a.due == 'HLY' ? 6 : 0);
    int second = b.openDate.toDate().month + (b.due == 'HLY' ? 6 : 0);
    first = first > 12 ? first - 12 : first;
    second = second > 12 ? second - 12 : second;
    return first.compareTo(second);
  }

  Widget _buildListItem(BuildContext context, Record record) {
    return Padding(
      key: ValueKey(record.policyNum),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text("${record.policyNum}"),
          trailing:
              Text(new DateFormat("MMM").format(record.openDate.toDate())),
          onTap: () => _viewDetails(record),
        ),
      ),
    );
  }

  _viewDetails(Record record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailedPage(record)),
    );
  }
}

class DetailedPage extends StatelessWidget {
  Record record;
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  DetailedPage(Record record) : this.record = record;

  @override
  Widget build(BuildContext context) {
    final Iterable<ListTile> tiles = record.toMap().entries.map(
      (MapEntry pair) {
        return new ListTile(
          title: new Text(
            "${pair.key}",
            style: _biggerFont,
          ),
          trailing: new Text(
            "${pair.value}",
            style: _biggerFont,
          ),
        );
      },
    );
    final List<Widget> divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return new Scaffold(
      appBar: new AppBar(
        title: Text("${record.policyNum}"),
      ),
      body: new ListView(children: divided),
    );
  }
}

class Record {
  final String policyNum;
  final String name;
  final Timestamp openDate;
  final String due;
  final Timestamp lastDue;
  final int amount;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['policyNum'] != null),
        assert(map['name'] != null),
        assert(map['due'] != null),
        assert(map['amount'] != null),
        assert(map['lastDue'] != null),
        policyNum = map['policyNum'],
        name = map['name'],
        openDate = map['openDate'],
        amount = map['amount'],
        lastDue = map['lastDue'],
        due = map['due'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map toMap() => {
        'policyNum': policyNum,
        'name': name,
        'amount': amount,
        'openDate': new DateFormat('MM-dd-yyyy').format(openDate.toDate()),
        'lastDue': new DateFormat('MM-dd-yyyy').format(lastDue.toDate()),
        'due': due
      };

  @override
  String toString() {
    return 'Record{policyNum: $policyNum, name: $name, openDate: ${openDate.toDate().month}, due: $due, lastDue: $lastDue, amount: $amount, reference: $reference}';
  }
}
