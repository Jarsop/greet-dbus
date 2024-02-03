#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <systemd/sd-bus.h>

static char name[256] = "Groot";

#define BUS_NAME "je.sappel.Greet"
#define MAIN_OBJ "/je/sappel/Greet"
#define MAIN_IFACE "je.sappel.Greet"
#define MAIN_PROP "Name"
#define MAIN_METHOD "Greet"

static int get_name(sd_bus *bus, const char *path, const char *interface,
                    const char *property, sd_bus_message *reply, void *userdata,
                    sd_bus_error *ret_error) {
  return sd_bus_message_append(reply, "s", name);
}

static int greet(sd_bus_message *m, void *userdata, sd_bus_error *ret_error) {
  const char *input;

  printf("Received method call for %s\n", MAIN_METHOD);

  int r = sd_bus_message_read(m, "s", &input);
  if (r < 0) {
    fprintf(stderr, "Failed to parse parameters: %s\n", strerror(-r));
    return r;
  }

  strncpy(name, input, sizeof(name));
  name[sizeof(name) - 1] = '\0';

  sd_bus_emit_properties_changed(sd_bus_message_get_bus(m), MAIN_OBJ,
                                 MAIN_IFACE, MAIN_PROP, NULL);

  printf("Greeted with %s\n", name);

  return sd_bus_reply_method_return(m, NULL, NULL);
}

static const sd_bus_vtable service_vtable[] = {
    SD_BUS_VTABLE_START(0),
    SD_BUS_PROPERTY(MAIN_PROP, "s", get_name, 0,
                    SD_BUS_VTABLE_PROPERTY_EMITS_CHANGE),
    SD_BUS_METHOD(MAIN_METHOD, "s", NULL, greet, SD_BUS_VTABLE_UNPRIVILEGED),
    SD_BUS_VTABLE_END};

int main(void) {
  sd_bus_slot *slot = NULL;
  sd_bus *bus = NULL;
  int r;

  r = sd_bus_open_user(&bus);
  if (r < 0) {
    fprintf(stderr, "Failed to connect to session bus: %s\n", strerror(-r));
    goto finish;
  }

  printf("Successfully connected to the session bus\n");

  r = sd_bus_add_object_vtable(bus, &slot, MAIN_OBJ, MAIN_IFACE, service_vtable,
                               NULL);

  if (r < 0) {
    fprintf(stderr, "Failed to issue method call: %s\n", strerror(-r));
    goto finish;
  }

  printf("Successfully added object to the bus\n");

  r = sd_bus_request_name(bus, BUS_NAME, 0);
  if (r < 0) {
    fprintf(stderr, "Failed to acquire service name: %s\n", strerror(-r));
    goto finish;
  }

  printf("Successfully acquired service name: %s\n", BUS_NAME);

  while (1) {
    r = sd_bus_process(bus, NULL);
    if (r < 0) {
      fprintf(stderr, "Failed to process bus: %s\n", strerror(-r));
      goto finish;
    }
    if (r > 0)
      continue;

    r = sd_bus_wait(bus, (uint64_t)-1);
    if (r < 0) {
      fprintf(stderr, "Failed to wait on bus: %s\n", strerror(-r));
      goto finish;
    }
  }

finish:
  sd_bus_slot_unref(slot);
  sd_bus_unref(bus);
  return r < 0 ? EXIT_FAILURE : EXIT_SUCCESS;
}
