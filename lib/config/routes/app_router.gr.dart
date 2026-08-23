// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CreateCustomerPage]
class CreateCustomerRoute extends PageRouteInfo<CreateCustomerRouteArgs> {
  CreateCustomerRoute({
    Key? key,
    CreateCustomerDraft? initialDraft,
    ProfileImagePicker? profileImagePicker,
    List<PageRouteInfo>? children,
  }) : super(
         CreateCustomerRoute.name,
         args: CreateCustomerRouteArgs(
           key: key,
           initialDraft: initialDraft,
           profileImagePicker: profileImagePicker,
         ),
         initialChildren: children,
       );

  static const String name = 'CreateCustomerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateCustomerRouteArgs>(
        orElse: () => const CreateCustomerRouteArgs(),
      );
      return CreateCustomerPage(
        key: args.key,
        initialDraft: args.initialDraft,
        profileImagePicker: args.profileImagePicker,
      );
    },
  );
}

class CreateCustomerRouteArgs {
  const CreateCustomerRouteArgs({
    this.key,
    this.initialDraft,
    this.profileImagePicker,
  });

  final Key? key;

  final CreateCustomerDraft? initialDraft;

  final ProfileImagePicker? profileImagePicker;

  @override
  String toString() {
    return 'CreateCustomerRouteArgs{key: $key, initialDraft: $initialDraft, profileImagePicker: $profileImagePicker}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateCustomerRouteArgs) return false;
    return key == other.key &&
        initialDraft == other.initialDraft &&
        profileImagePicker == other.profileImagePicker;
  }

  @override
  int get hashCode =>
      key.hashCode ^ initialDraft.hashCode ^ profileImagePicker.hashCode;
}

/// generated route for
/// [CustomerDetailsPage]
class CustomerDetailsRoute extends PageRouteInfo<CustomerDetailsRouteArgs> {
  CustomerDetailsRoute({
    Key? key,
    required String customerId,
    List<PageRouteInfo>? children,
  }) : super(
         CustomerDetailsRoute.name,
         args: CustomerDetailsRouteArgs(key: key, customerId: customerId),
         initialChildren: children,
       );

  static const String name = 'CustomerDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomerDetailsRouteArgs>();
      return CustomerDetailsPage(key: args.key, customerId: args.customerId);
    },
  );
}

class CustomerDetailsRouteArgs {
  const CustomerDetailsRouteArgs({this.key, required this.customerId});

  final Key? key;

  final String customerId;

  @override
  String toString() {
    return 'CustomerDetailsRouteArgs{key: $key, customerId: $customerId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomerDetailsRouteArgs) return false;
    return key == other.key && customerId == other.customerId;
  }

  @override
  int get hashCode => key.hashCode ^ customerId.hashCode;
}

/// generated route for
/// [CustomerListPage]
class CustomerListRoute extends PageRouteInfo<CustomerListRouteArgs> {
  CustomerListRoute({
    Key? key,
    CustomerListDisplayState? displayState,
    List<PageRouteInfo>? children,
  }) : super(
         CustomerListRoute.name,
         args: CustomerListRouteArgs(key: key, displayState: displayState),
         initialChildren: children,
       );

  static const String name = 'CustomerListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomerListRouteArgs>(
        orElse: () => const CustomerListRouteArgs(),
      );
      return CustomerListPage(key: args.key, displayState: args.displayState);
    },
  );
}

class CustomerListRouteArgs {
  const CustomerListRouteArgs({this.key, this.displayState});

  final Key? key;

  final CustomerListDisplayState? displayState;

  @override
  String toString() {
    return 'CustomerListRouteArgs{key: $key, displayState: $displayState}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomerListRouteArgs) return false;
    return key == other.key && displayState == other.displayState;
  }

  @override
  int get hashCode => key.hashCode ^ displayState.hashCode;
}

/// generated route for
/// [EditCustomerPage]
class EditCustomerRoute extends PageRouteInfo<EditCustomerRouteArgs> {
  EditCustomerRoute({
    Key? key,
    required String customerId,
    List<PageRouteInfo>? children,
  }) : super(
         EditCustomerRoute.name,
         args: EditCustomerRouteArgs(key: key, customerId: customerId),
         initialChildren: children,
       );

  static const String name = 'EditCustomerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditCustomerRouteArgs>();
      return EditCustomerPage(key: args.key, customerId: args.customerId);
    },
  );
}

class EditCustomerRouteArgs {
  const EditCustomerRouteArgs({this.key, required this.customerId});

  final Key? key;

  final String customerId;

  @override
  String toString() {
    return 'EditCustomerRouteArgs{key: $key, customerId: $customerId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditCustomerRouteArgs) return false;
    return key == other.key && customerId == other.customerId;
  }

  @override
  int get hashCode => key.hashCode ^ customerId.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [ServiceEntryPage]
class ServiceEntryRoute extends PageRouteInfo<ServiceEntryRouteArgs> {
  ServiceEntryRoute({
    Key? key,
    ServicePhotoPicker? photoPicker,
    List<PageRouteInfo>? children,
  }) : super(
         ServiceEntryRoute.name,
         args: ServiceEntryRouteArgs(key: key, photoPicker: photoPicker),
         initialChildren: children,
       );

  static const String name = 'ServiceEntryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ServiceEntryRouteArgs>(
        orElse: () => const ServiceEntryRouteArgs(),
      );
      return ServiceEntryPage(key: args.key, photoPicker: args.photoPicker);
    },
  );
}

class ServiceEntryRouteArgs {
  const ServiceEntryRouteArgs({this.key, this.photoPicker});

  final Key? key;

  final ServicePhotoPicker? photoPicker;

  @override
  String toString() {
    return 'ServiceEntryRouteArgs{key: $key, photoPicker: $photoPicker}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ServiceEntryRouteArgs) return false;
    return key == other.key && photoPicker == other.photoPicker;
  }

  @override
  int get hashCode => key.hashCode ^ photoPicker.hashCode;
}
