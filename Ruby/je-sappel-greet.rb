#!/usr/bin/env ruby
# frozen_string_literal: true

require "dbus"
Thread.abort_on_exception = true

class JeSappelGreet < DBus::Object
  dbus_interface "je.sappel.Greet" do
    dbus_attr_reader :Name, "s"
    dbus_method :Greet, "in name:s" do |name|
      @name = name
      self.PropertiesChanged("je.sappel.Greet", { "Name" => @name }, [])
    end
  end

  def initialize(opath)
    super
    @Name = "Groot"
  end
end

bus = DBus::SessionBus.instance
bus.object_server.export(JeSappelGreet.new("/je/sappel/Greet"))
bus.request_name("je.sappel.Greet")
DBus::Main.new.tap { |m| m << bus }.run
