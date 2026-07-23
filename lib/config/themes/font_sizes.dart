part of 'app_themes.dart';

const kAppbarHeight = 56.0;

// ─── Typographic scale ──────────────────────────────────────────
// Calibrated for ServiceKar's target users — field-service
// technicians who work in basements, boiler rooms, and dim
// customer sites per README § "Key Features" / Target Users.
// The README explicitly requires "Large and Readable User
// Interface". Sizes below track Lalafen's ten-tier scale, lifted
// 2–4 logical pixels at the body / label tier to satisfy the
// low-light legibility requirement, and pinned so widgets read
// `kTextSizeXxx` directly from this file.

const kTextSizeLabelSmall = 11.0;
const kTextSizeBodySmall = 15.0;
const kTextSizeBodyLarge = 18.0;
const kTextSizeLabelMedium = 16.0;
const kTextSizeLabelLarge = 22.0;
const kTextSizeTitleSmall = 24.0;
const kTextSizeTitleMedium = 28.0;
const kTextSizeTitleLarge = 34.0;
const kTextSizeHeadline = 44.0;
