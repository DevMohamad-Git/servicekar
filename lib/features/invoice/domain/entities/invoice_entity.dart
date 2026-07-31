/// Re-export of the Invoice domain entity from the customer
/// feature's domain folder.
///
/// The actual class lives in
/// `lib/features/customer/domain/entities/invoice_entity.dart`
/// because the schema foundation shipped all five domain entities
/// (Customer, Service, Invoice, Payment) there before the per-
/// feature split landed. This single re-export file is the
/// Invoice feature's stable touchpoint: imports of
/// `package:servicar/features/invoice/domain/entities/invoice_entity.dart`
/// stay valid even if a later refactor moves the concrete class
/// into `lib/features/invoice/domain/entities/`.
library;

export 'package:servicar/features/customer/domain/entities/invoice_entity.dart';
