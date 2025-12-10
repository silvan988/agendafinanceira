import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:agendafinanceira/models/transacao.dart'; // seu modelo de transação
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExportUtils {
  Future<void> exportarPDF(List<Transacao> transacoes) async {
    final pdf = pw.Document();

    // 🔹 Recupera UID do usuário logado
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 🔹 Busca documento do usuário no Firestore
    final docUsuario = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    final dadosUsuario = docUsuario.data();
    final nomeUsuario = dadosUsuario?['nome'] ?? 'Usuário';

    // 🔹 Data atual formatada
    final dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final receitas = transacoes.where((t) => t.tipo == 'receita').toList();
    final despesas = transacoes.where((t) => t.tipo == 'despesa').toList();

    final reais = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dataBr = DateFormat('dd/MM/yy');

    final totalReceitas = receitas.fold<double>(0, (s, t) => s + t.valor);
    final totalDespesas = despesas.fold<double>(0, (s, t) => s + t.valor);
    final saldo = totalReceitas - totalDespesas;

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('Relatório Financeiro - $nomeUsuario - $dataAtual',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),

          // Receitas
          pw.Text('Receitas', style: pw.TextStyle(fontSize: 18, color: PdfColors.green)),
          pw.SizedBox(height: 8),

          pw.TableHelper.fromTextArray(
            headers: ['Data', 'Origem', 'Categoria', 'Valor'],
            data: receitas.map((t) => [
              dataBr.format(t.data),
              t.origem,
              t.categoria,
              reais.format(t.valor),
            ]).toList(),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight, // valores alinhados à direita
            },
          ),


          pw.SizedBox(height: 16),

          // Despesas
          pw.Text('Despesas', style: pw.TextStyle(fontSize: 18, color: PdfColors.red)),
          pw.SizedBox(height: 8),

          pw.TableHelper.fromTextArray(
            headers: ['Data', 'Origem', 'Categoria', 'Valor'],
            data: despesas.map((t) => [
              dataBr.format(t.data),
              t.origem,
              t.categoria,
              reais.format(t.valor),
            ]).toList(),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight, // valores alinhados à direita
            },
          ),

          pw.Divider(),

          // 🔹 Tabela de resumo no rodapé


          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              // Cabeçalho
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Align(alignment: pw.Alignment.center,
                      child: pw.Text('Receitas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Align(alignment: pw.Alignment.center,
                      child: pw.Text('Despesas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ),

                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Align(alignment: pw.Alignment.center,
                      child: pw.Text('Saldo Final', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              // Linha de totais
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Align(
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        reais.format(totalReceitas),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Align(
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        reais.format(totalDespesas),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red), // 🔴 vermelho
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Align(
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        reais.format(saldo),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: saldo >= 0 ? PdfColors.green : PdfColors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}