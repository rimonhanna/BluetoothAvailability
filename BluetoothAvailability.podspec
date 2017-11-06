Pod::Spec.new do |s|

  s.name         = "BluetoothAvailability"
  s.version      = "1.0.0"
  s.summary      = "BluetoothAvailability"
  s.description  = "BluetoothAvailability"
  s.homepage     = "https://github.com/rimonhanna/BluetoothAvailability"
  s.license      = "MIT"
  s.author       = { "Rimon Hanna" => "" }
  s.source       = { :git => "git@github.com:rimonhanna/BluetoothAvailability.git", :tag => "#{s.version}" }

  s.source_files         = "BluetoothAvailability/**/BluetoothAvailability.swift"
  s.frameworks           = "Foundation", "CoreBluetooth", "ExternalAccessory", "UIKit"
end
