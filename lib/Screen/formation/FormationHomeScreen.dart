import 'package:bakhbade/Services/api_service.dart';
import 'package:bakhbade/models/Formation.dart';
import 'package:flutter/material.dart';

class FormationListScreen extends StatefulWidget {
  @override
  _FormationListScreenState createState() => _FormationListScreenState();
}

class _FormationListScreenState extends State<FormationListScreen> {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<TypeFormation>>(
        future: apiService.fetchFormations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final formations = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: formations.length,
              itemBuilder: (context, index) {
                return FormationCard(formations[index]);
              },
            );
          } else {
            return const Center(child: Text('Aucune formation trouvée'));
          }
        },
      ),
    );
  }
}

class FormationCard extends StatelessWidget {
  final TypeFormation typeFormation;

  FormationCard(this.typeFormation);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        title: Text(
          typeFormation.nom,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        children: typeFormation.formations.map((formation) {
          return ListTile(
            title: Text(formation.nom),
            subtitle: Text('Coût: ${formation.coutMin} CFA'),
            trailing: Text(
              formation.modePaiementTranches
                  ? 'Payable par tranches'
                  : 'Paiement unique',
              style: TextStyle(
                  color: formation.modePaiementTranches
                      ? Colors.green
                      : Colors.red),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormationDetailScreen(formation),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class FormationDetailScreen extends StatelessWidget {
  final Formation formation;

  const FormationDetailScreen(this.formation, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formation.nom),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formation.nom,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(formation.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text('Coût: ${formation.coutMin} CFA',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              formation.modePaiementTranches
                  ? 'Payable par tranches'
                  : 'Paiement unique',
              style: TextStyle(
                fontSize: 18,
                color:
                    formation.modePaiementTranches ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
