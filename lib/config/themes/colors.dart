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
