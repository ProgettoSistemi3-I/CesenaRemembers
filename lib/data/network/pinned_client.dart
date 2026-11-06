// Su mobile/desktop (dart:io) usa il client con certificato fissato;
// su web ricade sul client standard del browser.
export 'pinned_client_stub.dart'
    if (dart.library.io) 'pinned_client_io.dart';
