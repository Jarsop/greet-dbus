use std::future::pending;
use zbus::{dbus_interface, fdo::Result, Connection, SignalContext};

static BUS_NAME: &str = "je.sappel.Greet";
static MAIN_OBJ: &str = "/je/sappel/Greet";

struct Greet {
    name: String,
}

#[dbus_interface(name = "je.sappel.Greet")]
impl Greet {
    #[dbus_interface(property)]
    async fn name(&self) -> &str {
        &self.name
    }

    async fn greet(
        &mut self,
        name: &str,
        #[zbus(signal_context)] ctx: SignalContext<'_>,
    ) -> Result<()> {
        self.name = name.to_string();
        println!("Greeted with {name}");
        self.name_changed(&ctx).await?;
        Ok(())
    }
}

#[async_std::main]
async fn main() -> Result<()> {
    let greet = Greet {
        name: "Groot".to_string(),
    };
    let connection = Connection::session().await?;
    connection.object_server().at(MAIN_OBJ, greet).await?;
    connection.request_name(BUS_NAME).await?;

    loop {
        pending::<()>().await;
    }
}
