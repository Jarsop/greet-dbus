const dbus = require("dbus-next");
const { Interface, method, property, ACCESS_READ } = dbus.interface;

class JeSappelGreet extends Interface {
  constructor(interfaceName) {
    super(interfaceName);
    this._name = "Groot";
  }

  @property({ signature: "s", access: ACCESS_READ })
  get Name() {
    return this._name;
  }

  @method({ inSignature: "s", outSignature: "" })
  Greet(name) {
    this._name = name;
    Interface.emitPropertiesChanged(this, {
      Name: name,
    }, []);
  }
}

async function main() {
  const bus = dbus.sessionBus();
  const serviceName = "je.sappel.Greet";
  const objectPath = "/je/sappel/Greet";
  const interfaceName = "je.sappel.Greet";

  try {
    const jeSappelGreet = new JeSappelGreet(interfaceName);
    await bus.requestName(serviceName, dbus.NameFlag.DO_NOT_QUEUE);

    bus.export(objectPath, jeSappelGreet);
    console.log(`Service ${serviceName} is running...`);
  } catch (err) {
    console.error(`Failed to create D-Bus service: ${err.message}`);
    bus.disconnect();
  }
}

main();
