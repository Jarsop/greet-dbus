import asyncio

from dbus_next import BusType
from dbus_next.aio import MessageBus
from dbus_next.constants import PropertyAccess
from dbus_next.service import ServiceInterface, dbus_property, method

BUS_NAME = "je.sappel.Greet"
MAIN_OBJ = "/je/sappel/Greet"
MAIN_IFACE = "je.sappel.Greet"


class GreetDBus(ServiceInterface):
    def __init__(self):
        super().__init__(MAIN_IFACE)
        self._name = "Groot"

    @dbus_property(access=PropertyAccess.READ)
    def Name(self) -> "s":
        return self._name

    @method()
    def Greet(self, source: "s"):
        self._name = source
        self.emit_properties_changed({"Name": self._name})


async def greet_service():
    try:
        bus = await MessageBus(bus_type=BusType.SESSION).connect()
        greet = GreetDBus()
        bus.export(MAIN_OBJ, greet)
        await bus.request_name(BUS_NAME)
        await bus.wait_for_disconnect()
    except Exception as e:
        print(f"Error setting up Greet D-Bus service: {e}")


def main():
    asyncio.get_event_loop().run_until_complete(greet_service())
