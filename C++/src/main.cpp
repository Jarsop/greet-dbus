#include <iostream>
#include <sdbus-c++/sdbus-c++.h>

constexpr const char *BUS_NAME = "je.sappel.Greet";
constexpr const char *MAIN_OBJ = "/je/sappel/Greet";
constexpr const char *MAIN_IFACE = "je.sappel.Greet";
constexpr const char *MAIN_PROP = "Name";
constexpr const char *MAIN_METHOD = "Greet";

class GreeterService {
public:
  GreeterService() : objectPath_(MAIN_OBJ) {
    connection_ = sdbus::createSessionBusConnection();
    object_ = sdbus::createObject(*connection_, objectPath_);
    object_->registerProperty(MAIN_PROP)
        .onInterface(MAIN_IFACE)
        .withGetter([this] { return getName(); });
    object_->registerMethod(MAIN_METHOD)
        .onInterface(MAIN_IFACE)
        .implementedAs([this](const std::string &name) { greet(name); });
    object_->finishRegistration();
  }

  void run() {
    connection_->requestName(BUS_NAME);
    while (true) {
      connection_->enterEventLoop();
    }
  }

private:
  std::string name_ = "Groot";
  std::unique_ptr<sdbus::IConnection> connection_;
  std::unique_ptr<sdbus::IObject> object_;
  std::string objectPath_;

  std::string getName() const { return name_; }

  void greet(const std::string &newName) {
    name_ = newName;
    object_->emitPropertiesChangedSignal(MAIN_IFACE, {MAIN_PROP});
    std::cout << "Greeted with " << name_ << std::endl;
  }
};

int main() {
  try {
    GreeterService service;
    service.run();
  } catch (const sdbus::Error &e) {
    std::cerr << "D-Bus error: " << e.what() << std::endl;
    return EXIT_FAILURE;
  } catch (const std::exception &e) {
    std::cerr << "An error occurred: " << e.what() << std::endl;
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
