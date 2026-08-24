part of 'app_themes.dart';

// ─── Brand palette (industrial field-service persona) ───────────
// Deep-saturation blue evokes trust + mechanical competence; teal
// serves as the technical accent (status indicators in service
// history); amber is reserved for the "due / overdue / reminder"
// semantic that Lalafen reserves for `kWarningColor`.
const kPrimaryColor = Color(0xFF1565C0);
const kSecondaryColor = Color(0xFF455A64);
const kTertiaryColor = Color(0xFF00838F);
const kQuaternaryColor = Color(0xFFD84315);

// ─── Semantic state (settled / paid / error / warning) ──────────
const kSuccessColor = Color(0xFF2E7D32);
const kSuccess2Color = Color(0xFF66BB6A);
const kWarningColor = Color(0xFFF9A825);
const kErrorColor = Color(0xFFD32F2F);

// ─── Neutrals + foreground ──────────────────────────────────────
const kTextPrimaryColor = Color(0xFF1A1F26);
const kBackgroundColor = Color(0xFFF5F6F8);
const kGrey1Color = Color(0xFF1A1F26);
const kGrey2Color = Color(0xFF52606D);
const kGrey3Color = Color(0xFF9AA5B1);
const kGrey4Color = Color(0xFFE4E7EB);

// ─── Translucent fills for chip / banner backgrounds ────────────
// Hex pattern `0x1F` = +5% opacity (31 / 255 ≈ 12%), the convention
// Lalafen uses for soft-tinted container fills.
const kBackgroundSuccess2Color = Color(0x1F66BB6A);
const kFailure = Color(0xFFC62828);
const kBackgroundFailureColor = Color(0x1FC62828);

// ─── Dashboard tokens ──────────────────────────────────────────
// The dashboard's "مجموع بدهکاران" card uses a vibrant blue
// gradient pulled straight from the approved design mockup.
const kDebtorsGradientStart = Color(0xFF2563EB);
const kDebtorsGradientEnd = Color(0xFF3B82F6);

// Translucent white used for the decorative wallet / chart artwork
// layered over the gradient card. Kept as a token so the artwork
// opacity is tuned in one place rather than per-widget.
const kDebtorsCardDecorationTint = Color(0x24FFFFFF);

// KPI-card accents for the "نمای کلی کسب‌وکار" section. Values are
// lifted from the existing dashboard / activity palette so the new
// cards stay visually consistent (soft blue / teal / purple) — no new
// saturated hue is introduced. Each pairs with the `0x1F` ≈ 12%
// opacity fill convention used by the activity chips.
const kKpiInvoice = Color(0xFF2563EB); // registered invoices — soft navy
const kKpiInvoiceBackground = Color(0x1F2563EB);
const kKpiCustomer = Color(0xFF00838F); // customers — soft teal
const kKpiCustomerBackground = Color(0x1F00838F);
const kKpiService = Color(0xFF8B5CF6); // registered services — muted purple
const kKpiServiceBackground = Color(0x1F8B5CF6);

// Recent-activity accent colours — one semantic per activity kind.
// NOTE: these are *activity* semantics (money-in / invoice / new
// customer), not debt-display semantics; the product keeps debtor
// amounts neutral, so no red is used for "owes money".
const kActivityIncome = Color(0xFF16A34A); // payment received
const kActivityInvoice = Color(0xFF2563EB); // invoice issued
const kActivityCustomer = Color(0xFF8B5CF6); // new customer
const kActivityOutflow = Color(0xFFDC2626); // reserved: refund/expense

// 12%-opacity chip fills (mirrors the `0x1F…` convention used above
// for soft-tinted container backgrounds).
const kActivityIncomeBackground = Color(0x1F16A34A);
const kActivityInvoiceBackground = Color(0x1F2563EB);
const kActivityCustomerBackground = Color(0x1F8B5CF6);
const kActivityOutflowBackground = Color(0x1FDC2626);


